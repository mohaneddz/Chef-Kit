import 'dart:async';
import 'dart:convert';
import 'package:chefkit/domain/models/user_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:chefkit/domain/offline_provider.dart';
import 'package:chefkit/common/token_storage.dart';
import 'package:chefkit/common/firebase_messaging_service.dart';

class AuthState {
  final UserModel? user;
  final String? error;
  final bool loading;
  final Map<String, String?> fieldErrors;
  final String? accessToken;
  final String? userId;
  final bool signedUp;
  final bool needsOtp;

  AuthState({
    this.user,
    this.error,
    this.loading = false,
    this.fieldErrors = const {},
    this.accessToken,
    this.userId,
    this.signedUp = false,
    this.needsOtp = false,
  });

  AuthState copyWith({
    UserModel? user,
    String? error,
    bool? loading,
    Map<String, String?>? fieldErrors,
    String? accessToken,
    String? userId,
    bool? signedUp,
    bool? needsOtp,
  }) {
    return AuthState(
      user: user ?? this.user,
      error: error,
      loading: loading ?? this.loading,
      fieldErrors: fieldErrors ?? this.fieldErrors,
      accessToken: accessToken ?? this.accessToken,
      userId: userId ?? this.userId,
      signedUp: signedUp ?? this.signedUp,
      needsOtp: needsOtp ?? this.needsOtp,
    );
  }
}

class AuthCubit extends Cubit<AuthState> {
  AuthCubit({required this.baseUrl, required OfflineProvider offline})
    : _offline = offline,
      _tokenStorage = TokenStorage(),
      super(AuthState());

  final String baseUrl;
  final OfflineProvider _offline;
  final TokenStorage _tokenStorage;
  String? pendingEmail;

  void updateProfile({
    required String fullName,
    required String email,
    required String phoneNumber,
    required String bio,
  }) {
    if (state.user == null) return;

    final updatedUser = UserModel(
      fullName: fullName,
      email: email,
      phoneNumber: phoneNumber,
      bio: bio,
    );

    emit(state.copyWith(user: updatedUser));
  }

  Future<void> signup(
    String name,
    String email,
    String password,
    String confirm,
  ) async {
    emit(
      state.copyWith(
        loading: true,
        error: null,
        fieldErrors: {},
        signedUp: false,
      ),
    );

    if (name.trim().length < 3) {
      emit(
        state.copyWith(
          loading: false,
          fieldErrors: {"name": "Full name is too short"},
        ),
      );
      return;
    }
    if (!_validateEmail(email)) {
      emit(
        state.copyWith(loading: false, fieldErrors: {"email": "Invalid email"}),
      );
      return;
    }
    if (password.length < 8) {
      emit(
        state.copyWith(
          loading: false,
          fieldErrors: {"password": "Password must be 8+ chars"},
        ),
      );
      return;
    }
    if (password != confirm) {
      emit(
        state.copyWith(
          loading: false,
          fieldErrors: {"confirm": "Passwords don’t match"},
        ),
      );
      return;
    }

    try {
      final signupUrl = Uri.parse('$baseUrl/auth/signup');
      // print('[AuthCubit] signup POST $signupUrl');
      final resp = await http
          .post(
            signupUrl,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'email': email,
              'password': password,
              'full_name': name,
            }),
          )
          .timeout(const Duration(seconds: 10));
      if (resp.statusCode == 200) {
        // With OTP/email token, after signup we require verification
        emit(state.copyWith(loading: false, signedUp: true, needsOtp: true));
      } else if (resp.statusCode == 409) {
        // Email already exists
        emit(
          state.copyWith(
            loading: false,
            fieldErrors: {"email": "Email already registered"},
          ),
        );
      } else {
        String errorMessage = 'An unknown error occurred';
        try {
          final errorData = jsonDecode(resp.body) as Map<String, dynamic>;
          errorMessage =
              errorData['error'] as String? ?? 'An error occurred (no details)';
        } catch (_) {
          // If JSON decoding fails, use the raw body as the error
          errorMessage = resp.body.isNotEmpty
              ? resp.body
              : 'Request failed with status ${resp.statusCode}';
        }
        emit(state.copyWith(loading: false, error: errorMessage));
      }
    } on TimeoutException {
      emit(
        state.copyWith(
          loading: false,
          error: 'Connection timed out. Please check your internet connection.',
        ),
      );
    } catch (e) {
      final errorMsg =
          e.toString().contains('Connection') ||
              e.toString().contains('SocketException')
          ? 'Unable to connect to server. Please check your internet connection.'
          : e.toString();
      emit(state.copyWith(loading: false, error: errorMsg));
    }
  }

  Future<void> login(String email, String password) async {
    emit(state.copyWith(loading: true, error: null, fieldErrors: {}));

    if (!_validateEmail(email)) {
      emit(
        state.copyWith(
          loading: false,
          fieldErrors: {"email": "Invalid email format"},
        ),
      );
      return;
    }
    if (password.length < 6) {
      emit(
        state.copyWith(
          loading: false,
          fieldErrors: {"password": "Password too short"},
        ),
      );
      return;
    }

    try {
      // Get FCM token if available (for push notifications)
      String? deviceToken;
      if (isFirebaseSupported) {
        deviceToken = FirebaseMessagingService().fcmToken;
        // print('[AuthCubit] Firebase supported: true');
        // print('[AuthCubit] FCM token available: ${deviceToken != null}');
        if (deviceToken != null) {
          // print(
          // '[AuthCubit] FCM token (first 30 chars): ${deviceToken.substring(0, deviceToken.length > 30 ? 30 : deviceToken.length)}...',
          // );
        }
      } else {
        // print('[AuthCubit] Firebase NOT supported on this platform');
      }

      // print(
      // '[AuthCubit] Sending login request with device_token: ${deviceToken != null}',
      // );

      final requestBody = {
        'email': email,
        'password': password,
        if (deviceToken != null) 'device_token': deviceToken,
      };
      // print('[AuthCubit] Request body keys: ${requestBody.keys.toList()}');

      final resp = await http
          .post(
            Uri.parse('$baseUrl/auth/login'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(requestBody),
          )
          .timeout(const Duration(seconds: 10));

      // print('[AuthCubit] Response status: ${resp.statusCode}');

      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body) as Map<String, dynamic>;
        final accessToken = data['access_token'] as String?;
        final refreshToken = data['refresh_token'] as String?;
        final user = data['user'] as Map<String, dynamic>?;
        final userId = user != null ? (user['id'] as String?) : null;

        // Save tokens securely
        if (userId != null && refreshToken != null) {
          await _offline.saveRefreshToken(
            userId: userId,
            refreshToken: refreshToken,
          );
          await _tokenStorage.saveRefreshToken(refreshToken);
          await _tokenStorage.saveUserId(userId);
        }
        if (accessToken != null) {
          await _tokenStorage.saveAccessToken(accessToken);
        }

        // Note: FCM token is now sent with the login request (device_token param)

        emit(
          state.copyWith(
            loading: false,
            accessToken: accessToken,
            userId: userId,
            needsOtp: false,
            user: user != null
                ? UserModel(
                    // Try multiple possible field names from backend
                    fullName:
                        user['full_name'] ??
                        user['user_full_name'] ??
                        user['name'] ??
                        'User',
                    email: user['email'] ?? email,
                    phoneNumber:
                        user['phone_number'] ?? user['phoneNumber'] ?? '',
                    bio: user['bio'] ?? '',
                  )
                : state.user,
          ),
        );
      } else if (resp.statusCode == 403 && resp.body.contains('unverified')) {
        // Unverified email: set needsOtp and remember email
        pendingEmail = email;
        emit(state.copyWith(loading: false, error: null, needsOtp: true));
      } else if (resp.statusCode == 401) {
        // Wrong credentials
        emit(
          state.copyWith(
            loading: false,
            fieldErrors: {"password": "Invalid email or password"},
            needsOtp: false,
          ),
        );
      } else {
        emit(state.copyWith(loading: false, error: resp.body, needsOtp: false));
      }
    } on TimeoutException {
      emit(
        state.copyWith(
          loading: false,
          error: 'Connection timed out. Please check your internet connection.',
        ),
      );
    } catch (e) {
      final errorMsg =
          e.toString().contains('Connection') ||
              e.toString().contains('SocketException')
          ? 'Unable to connect to server. Please check your internet connection.'
          : e.toString();
      emit(state.copyWith(loading: false, error: errorMsg));
    }
  }

  Future<void> verifyOtp(String email, String token) async {
    emit(state.copyWith(loading: true, error: null));
    try {
      final resp = await http.post(
        Uri.parse('$baseUrl/auth/verify'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'token': token}),
      );
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body) as Map<String, dynamic>;
        final user = data['user'] as Map<String, dynamic>?;
        emit(
          state.copyWith(
            loading: false,
            needsOtp: false,
            userId: user?['id'] as String?,
          ),
        );
      } else {
        emit(state.copyWith(loading: false, error: resp.body));
      }
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }

  Future<void> restoreSessionOnStart() async {
    emit(state.copyWith(loading: true));
    try {
      final storedRefreshToken = await _tokenStorage.readRefreshToken();
      final storedAccessToken = await _tokenStorage.readAccessToken();
      final storedUserId = await _tokenStorage.readUserId();

      if (storedRefreshToken == null || storedUserId == null) {
        emit(state.copyWith(loading: false));
        return;
      }

      final resp = await http.post(
        Uri.parse('$baseUrl/auth/refresh'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refresh_token': storedRefreshToken}),
      );

      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body) as Map<String, dynamic>;
        final newAccess = data['access_token'] as String?;
        final newRefresh = data['refresh_token'] as String?;

        if (newRefresh != null) {
          await _tokenStorage.saveRefreshToken(newRefresh);
          await _offline.saveRefreshToken(
            userId: storedUserId,
            refreshToken: newRefresh,
          );
        }
        if (newAccess != null) {
          await _tokenStorage.saveAccessToken(newAccess);
        }

        emit(
          state.copyWith(
            loading: false,
            accessToken: newAccess ?? storedAccessToken,
            userId: storedUserId,
            needsOtp: false,
          ),
        );

        // Register FCM token with backend after session restore (only on supported platforms)
        if (isFirebaseSupported) {
          await FirebaseMessagingService().registerTokenWithBackend();
        }
      } else {
        await _tokenStorage.clearAll();
        emit(state.copyWith(loading: false));
      }
    } catch (e) {
      await _tokenStorage.clearAll();
      emit(state.copyWith(loading: false));
    }
  }

  Future<void> logout() async {
    emit(state.copyWith(loading: true, error: null));

    // Clear tokens immediately (optimistic)
    try {
      if (state.userId != null) {
        await _offline.deleteRefreshToken(state.userId!);
      }
      await _tokenStorage.clearAll();
    } catch (e) {
      // Continue even if local cleanup fails
    }

    // Notify backend (fire and forget)
    try {
      await http.post(
        Uri.parse('$baseUrl/auth/logout'),
        headers: _authHeaders(),
      );
    } catch (e) {
      // Ignore backend errors - user is logged out locally
    }

    // Unregister FCM token on logout (only on supported platforms)
    if (isFirebaseSupported) {
      await FirebaseMessagingService().unregisterToken();
    }

    // Emit logged out state
    emit(AuthState(loading: false));
  }

  Future<void> refreshToken() async {
    if (state.userId == null) return;
    try {
      final refreshToken = await _offline.getRefreshToken(state.userId!);
      if (refreshToken == null) return;
      final resp = await http.post(
        Uri.parse('$baseUrl/auth/refresh'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refresh_token': refreshToken}),
      );
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body) as Map<String, dynamic>;
        final newAccess = data['access_token'] as String?;
        final newRefresh = data['refresh_token'] as String?;
        if (newRefresh != null && state.userId != null) {
          await _offline.saveRefreshToken(
            userId: state.userId!,
            refreshToken: newRefresh,
          );
          await _tokenStorage.saveRefreshToken(newRefresh);
        }
        if (newAccess != null) {
          await _tokenStorage.saveAccessToken(newAccess);
        }
        emit(state.copyWith(accessToken: newAccess));
      } else {
        emit(state.copyWith(error: resp.body));
      }
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  bool _validateEmail(String email) {
    return RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$").hasMatch(email);
  }

  /// Clear field errors and general error state
  void clearAuthFieldErrors() {
    emit(state.copyWith(fieldErrors: {}, error: null));
  }

  /// Reset OTP and signup state
  void resetOtpAndSignupState() {
    emit(
      state.copyWith(
        needsOtp: false,
        signedUp: false,
        fieldErrors: {},
        error: null,
      ),
    );
    pendingEmail = null;
  }

  Map<String, String> _authHeaders() {
    final headers = <String, String>{'Content-Type': 'application/json'};
    if (state.accessToken != null) {
      headers['Authorization'] = 'Bearer ${state.accessToken}';
    }
    return headers;
  }
}
