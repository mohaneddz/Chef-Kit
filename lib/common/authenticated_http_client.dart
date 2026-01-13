import 'dart:async';
import 'dart:convert';
import 'dart:io' show SocketException;
import 'package:http/http.dart' as http;
import 'token_storage.dart';
import 'config.dart';

/// A singleton HTTP client that automatically refreshes JWT tokens on 401 errors.
class AuthenticatedHttpClient {
  static final AuthenticatedHttpClient _instance =
      AuthenticatedHttpClient._internal();
  factory AuthenticatedHttpClient() => _instance;
  AuthenticatedHttpClient._internal();

  final TokenStorage _tokenStorage = TokenStorage();
  bool _isRefreshing = false;
  final List<Completer<void>> _refreshQueue = [];

  /// Get headers with current access token
  Future<Map<String, String>> _getHeaders() async {
    final token = await _tokenStorage.readAccessToken();
    if (token != null) {
      return {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };
    }
    return {'Content-Type': 'application/json'};
  }

  /// Refresh the access token using stored refresh token
  Future<bool> _refreshToken() async {
    // If already refreshing, wait for it to complete
    if (_isRefreshing) {
      final completer = Completer<void>();
      _refreshQueue.add(completer);
      await completer.future;
      return true;
    }

    _isRefreshing = true;
    try {
      final refreshToken = await _tokenStorage.readRefreshToken();
      if (refreshToken == null) {
        return false;
      }

      final baseUrl = AppConfig.baseUrl;
      final response = await http
          .post(
            Uri.parse('$baseUrl/auth/refresh'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'refresh_token': refreshToken}),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final newAccessToken = data['access_token'] as String?;
        final newRefreshToken = data['refresh_token'] as String?;

        if (newAccessToken != null) {
          await _tokenStorage.saveAccessToken(newAccessToken);
        }
        if (newRefreshToken != null) {
          await _tokenStorage.saveRefreshToken(newRefreshToken);
        }

        // Notify all waiting requests
        for (final completer in _refreshQueue) {
          completer.complete();
        }
        _refreshQueue.clear();
        return true;
      } else {
        // Refresh failed - clear tokens
        await _tokenStorage.clearAll();
        return false;
      }
    } catch (e) {
      return false;
    } finally {
      _isRefreshing = false;
    }
  }

  /// Check if response indicates token expiry
  bool _isTokenExpired(http.Response response) {
    final body = response.body.toLowerCase();
    // Check for JWT expiry in body (backend may return 200 with error in body)
    if (body.contains('pgrst303') ||
        body.contains('jwt expired') ||
        (body.contains('jwt') && body.contains('expired'))) {
      return true;
    }
    // Also check traditional 401/403 status codes
    if (response.statusCode == 401 || response.statusCode == 403) {
      return body.contains('jwt') ||
          body.contains('expired') ||
          body.contains('token');
    }
    return false;
  }

  /// Perform authenticated GET request with automatic token refresh
  Future<http.Response> get(
    Uri uri, {
    Map<String, String>? additionalHeaders,
    int maxRetries = 3,
    Duration timeout = const Duration(seconds: 10),
  }) async {
    var headers = await _getHeaders();
    if (additionalHeaders != null) {
      headers.addAll(additionalHeaders);
    }

    int attempts = 0;
    while (true) {
      attempts++;
      try {
        final response = await http.get(uri, headers: headers).timeout(timeout);

        // Check for token expiry and refresh if needed
        if (_isTokenExpired(response) && attempts == 1) {
          final refreshed = await _refreshToken();
          if (refreshed) {
            headers = await _getHeaders();
            if (additionalHeaders != null) {
              headers.addAll(additionalHeaders);
            }
            continue;
          }
        }

        return response;
      } on TimeoutException {
        if (attempts < maxRetries) {
          await Future.delayed(Duration(milliseconds: 500 * attempts));
          continue;
        }
        throw Exception('Connection timed out. Please check your connection.');
      } catch (e) {
        final isConnectionError =
            e is SocketException ||
            e.toString().contains('Connection closed') ||
            e.toString().contains('ClientException');

        if (isConnectionError && attempts < maxRetries) {
          await Future.delayed(Duration(milliseconds: 100 * attempts));
          continue;
        }
        rethrow;
      }
    }
  }

  /// Perform authenticated POST request with automatic token refresh
  Future<http.Response> post(
    Uri uri, {
    Object? body,
    Map<String, String>? additionalHeaders,
    Duration timeout = const Duration(seconds: 10),
  }) async {
    var headers = await _getHeaders();
    if (additionalHeaders != null) {
      headers.addAll(additionalHeaders);
    }

    int attempts = 0;
    while (attempts < 2) {
      attempts++;
      try {
        final response = await http
            .post(
              uri,
              headers: headers,
              body: body is String
                  ? body
                  : (body != null ? jsonEncode(body) : null),
            )
            .timeout(timeout);

        // Check for token expiry
        if (_isTokenExpired(response) && attempts == 1) {
          final refreshed = await _refreshToken();
          if (refreshed) {
            headers = await _getHeaders();
            if (additionalHeaders != null) {
              headers.addAll(additionalHeaders);
            }
            continue;
          }
        }

        return response;
      } on TimeoutException {
        throw Exception('Connection timed out. Please check your connection.');
      }
    }
    throw Exception('Request failed after retry');
  }
}
