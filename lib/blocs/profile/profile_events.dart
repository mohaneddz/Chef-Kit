abstract class ProfileEvent {}

class LoadProfile extends ProfileEvent {
  final String userId;
  LoadProfile({required this.userId});
}

class IncrementProfileRecipes extends ProfileEvent {}

class UpdatePersonalInfo extends ProfileEvent {
  final String userId;
  final String fullName;
  final String bio;
  final String story;
  final List<String> specialties;

  UpdatePersonalInfo({
    required this.userId,
    required this.fullName,
    required this.bio,
    required this.story,
    required this.specialties,
  });
}
