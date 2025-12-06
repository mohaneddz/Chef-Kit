class Chef {
  final String id;
  final String name;
  final String imageUrl;
  final String? bio;
  final String? story;
  final List<String> specialties;
  final bool isOnFire;
  final bool isChef;
  final bool isFollowed;
  final int followersCount;
  final int followingCount;
  final int recipesCount;

  Chef({
    required this.id,
    required this.name,
    required this.imageUrl,
    this.bio,
    this.story,
    this.specialties = const [],
    this.isOnFire = false,
    this.isChef = false,
    this.isFollowed = false,
    this.followersCount = 0,
    this.followingCount = 0,
    this.recipesCount = 0,
  });

  factory Chef.fromJson(Map<String, dynamic> json) {
    try {
      // Safely parse specialties array
      final List<String> specialties = [];
      if (json['user_specialties'] != null) {
        try {
          final rawSpecialties = json['user_specialties'];
          if (rawSpecialties is List) {
            for (var item in rawSpecialties) {
              if (item != null) {
                specialties.add(item.toString());
              }
            }
          }
        } catch (e) {
          print('Error parsing specialties: $e');
        }
      }
      
      // Safely parse count fields
      int followersCount = 0;
      final rawFollowers = json['user_followers_count'];
      if (rawFollowers != null) {
        if (rawFollowers is int) {
          followersCount = rawFollowers;
        } else if (rawFollowers is String) {
          followersCount = int.tryParse(rawFollowers) ?? 0;
        }
      }
      
      int followingCount = 0;
      final rawFollowing = json['user_following_count'];
      if (rawFollowing != null) {
        if (rawFollowing is int) {
          followingCount = rawFollowing;
        } else if (rawFollowing is String) {
          followingCount = int.tryParse(rawFollowing) ?? 0;
        }
      }
      
      int recipesCount = 0;
      final rawRecipes = json['user_recipes_count'];
      if (rawRecipes != null) {
        if (rawRecipes is int) {
          recipesCount = rawRecipes;
        } else if (rawRecipes is String) {
          recipesCount = int.tryParse(rawRecipes) ?? 0;
        }
      }
      
      return Chef(
        id: json['user_id']?.toString() ?? '',
        name: json['user_full_name']?.toString() ?? 'Unknown',
        imageUrl: json['user_avatar']?.toString() ?? 'https://via.placeholder.com/250',
        bio: json['user_bio']?.toString(),
        story: json['user_story']?.toString(),
        specialties: specialties,
        isOnFire: json['user_is_on_fire'] == true,
        isChef: json['user_is_chef'] == true,
        isFollowed: false,
        followersCount: followersCount,
        followingCount: followingCount,
        recipesCount: recipesCount,
      );
    } catch (e, stackTrace) {
      print('Error parsing Chef from JSON: $e');
      print('JSON data: $json');
      print('Stack trace: $stackTrace');
      
      // Return a default chef to prevent crash
      return Chef(
        id: json['user_id']?.toString() ?? 'error',
        name: 'Error Loading Chef',
        imageUrl: 'https://via.placeholder.com/250',
      );
    }
  }

  Chef copyWith({
    String? id,
    String? name,
    String? imageUrl,
    String? bio,
    String? story,
    List<String>? specialties,
    bool? isOnFire,
    bool? isChef,
    bool? isFollowed,
    int? followersCount,
    int? followingCount,
    int? recipesCount,
  }) {
    return Chef(
      id: id ?? this.id,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      bio: bio ?? this.bio,
      story: story ?? this.story,
      specialties: specialties ?? this.specialties,
      isOnFire: isOnFire ?? this.isOnFire,
      isChef: isChef ?? this.isChef,
      isFollowed: isFollowed ?? this.isFollowed,
      followersCount: followersCount ?? this.followersCount,
      followingCount: followingCount ?? this.followingCount,
      recipesCount: recipesCount ?? this.recipesCount,
    );
  }
}
