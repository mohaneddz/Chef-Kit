class UserProfile {
  final String id;
  final String name;
  final String email;
  final String avatarUrl;
  final int recipesCount;
  final int favoritesCount;
  final int savedCount;

  UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.avatarUrl,
    required this.recipesCount,
    required this.favoritesCount,
    required this.savedCount,
  });

  UserProfile copyWith({
    String? name,
    String? email,
    String? avatarUrl,
    int? recipesCount,
    int? favoritesCount,
    int? savedCount,
  }) {
    return UserProfile(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      recipesCount: recipesCount ?? this.recipesCount,
      favoritesCount: favoritesCount ?? this.favoritesCount,
      savedCount: savedCount ?? this.savedCount,
    );
  }
}
