import 'package:chefkit/domain/models/user_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthState {
  final UserModel? user;
  final String? error;
  final bool loading;
  final Map<String, String?> fieldErrors;

  AuthState({this.user, this.error, this.loading = false, this.fieldErrors = const {},});

  AuthState copyWith({
    UserModel? user,
    String? error,
    bool? loading,
    Map<String, String?>? fieldErrors,
  }) {
    return AuthState(
      user: user ?? this.user,
      error: error,
      loading: loading ?? this.loading,
      fieldErrors: fieldErrors ?? this.fieldErrors,
    );
  }
}

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthState());

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


  void login(String email, String password) async {
    emit(state.copyWith(loading: true, error: null));

    await Future.delayed(const Duration(milliseconds: 600));

    if (!_validateEmail(email)) {
      emit(state.copyWith(
        loading: false,
        fieldErrors: {"email": "Invalid email format"},
      ));
      return;
    }

    if (password.length < 6) {
      emit(state.copyWith(
        loading: false,
        fieldErrors: {"password": "Password too short"},
      ));
      return;
    }

    emit(AuthState(
      user: UserModel(fullName: "User", email: email, phoneNumber: "to be fetched from database", bio: "to be fetched from database"),
      loading: false,
    ));
  }

  void signup(String name, String email, String password, String confirm) async {
    emit(state.copyWith(loading: true, error: null));

    await Future.delayed(const Duration(milliseconds: 600));

    if (name.trim().length < 3) {
      emit(state.copyWith(
        loading: false,
        fieldErrors: {"name": "Full name is too short"},
      ));
      return;
    }

    if (!_validateEmail(email)) {
      emit(state.copyWith(
        loading: false,
        fieldErrors: {"email": "Invalid email"},
      ));
      return;
    }

    if (password.length < 8) {
      emit(state.copyWith(
        loading: false,
        fieldErrors: {"password": "Password must be 8+ chars"},
      ));
      return;
    }

    if (password != confirm) {
      emit(state.copyWith(
        loading: false,
        fieldErrors: {"confirm": "Passwords don’t match"},
      ));
      return;
    }

    emit(AuthState(
      // TODO: do we add phone number in sign up ? or we let him add it later if he wants
      user: UserModel(fullName: name, email: email, phoneNumber: "Add your phone number ...", bio: "Add your bio ..."),
      loading: false,
    ));
  }

  bool _validateEmail(String email) {
    return RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$").hasMatch(email);
  }
}
