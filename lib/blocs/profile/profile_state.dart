import '../../domain/models/user_profile.dart';

class ProfileState {
  final bool loading;
  final UserProfile? profile;
  final String? error;

  ProfileState({this.loading = false, this.profile, this.error});

  ProfileState copyWith({bool? loading, UserProfile? profile, String? error}) => ProfileState(
    loading: loading ?? this.loading,
    profile: profile ?? this.profile,
    error: error,
  );
}
