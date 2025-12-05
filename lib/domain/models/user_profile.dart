class UserProfile {
  final String id;
  final String name;
  final String email;
  final String avatarUrl;
  final int recipesCount;
  final int followingCount;
  final int followersCount;
  final bool isChef;
  final String? bio;
  final List<String>? specialties;

  UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.avatarUrl,
    required this.recipesCount,
    required this.followingCount,
    required this.followersCount,
    required this.isChef,
    this.bio,
    this.specialties,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    print('=== UserProfile.fromJson ===');
    print('Raw JSON: $json');
    print('user_full_name: ${json['user_full_name']}');
    print('user_avatar: ${json['user_avatar']}');
    
    // If no full name, extract username from email
    String displayName = json['user_full_name'] ?? 'Unknown';
    if (displayName == 'Unknown' || displayName.isEmpty) {
      final email = json['user_email'] as String?;
      if (email != null && email.contains('@')) {
        displayName = email.split('@')[0];
      }
    }
    
    final profile = UserProfile(
      id: json['user_id'] ?? '',
      name: displayName,
      email: json['user_email'] ?? '',
      avatarUrl: json['user_avatar'] ?? '',
      recipesCount: (json['user_recipes_count'] as num?)?.toInt() ?? 0,
      followingCount: (json['user_following_count'] as num?)?.toInt() ?? 0,
      followersCount: (json['user_followers_count'] as num?)?.toInt() ?? 0,
      isChef: json['user_is_chef'] ?? false,
      bio: json['user_bio'],
      specialties: json['user_specialties'] != null 
          ? List<String>.from(json['user_specialties']) 
          : null,
    );
    
    print('Parsed name: ${profile.name}');
    print('Parsed avatarUrl: ${profile.avatarUrl}');
    print('========================');
    
    return profile;
  }

  UserProfile copyWith({
    String? name,
    String? email,
    String? avatarUrl,
    int? recipesCount,
    int? followingCount,
    int? followersCount,
    bool? isChef,
    String? bio,
    List<String>? specialties,
  }) {
    return UserProfile(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      recipesCount: recipesCount ?? this.recipesCount,
      followingCount: followingCount ?? this.followingCount,
      followersCount: followersCount ?? this.followersCount,
      isChef: isChef ?? this.isChef,
      bio: bio ?? this.bio,
      specialties: specialties ?? this.specialties,
    );
  }
}
