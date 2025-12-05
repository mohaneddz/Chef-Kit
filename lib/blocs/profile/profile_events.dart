abstract class ProfileEvent {}

class LoadProfile extends ProfileEvent {
  final String userId;
  LoadProfile({required this.userId});
}

class IncrementProfileRecipes extends ProfileEvent {}
