import '../../domain/models/user_profile.dart';

class ProfileState {
  final bool loading;
  final bool saving;
  final UserProfile? profile;
  final String? error;

  ProfileState({this.loading = false, this.saving = false, this.profile, this.error});

  ProfileState copyWith({bool? loading, bool? saving, UserProfile? profile, String? error}) => ProfileState(
    loading: loading ?? this.loading,
    saving: saving ?? this.saving,
    profile: profile ?? this.profile,
    error: error,
  );
}
