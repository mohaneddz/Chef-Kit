import 'dart:convert';

class LocalUserModel {
  final String userId;
  final String userFullName;
  final String userEmail;
  final String userPhoneNumber;
  final String userPassword;
  final String userAvatar;
  final List<String> userInventory;
  final List<String> userFavouriteRecipes;
  final List<String> userNotificationsHistory;
  final bool userNotificationsEnabled;
  final bool userDarkModeEnabled;
  final String userLanguage;
  final int userFollowingCount;
  final int userRecipesCount;
  final int userFollowersCount;
  final bool userIsChef;
  final bool userIsOnFire;
  final String userBio;
  final List<String> userSpecialties;
  final List<String> userRecipes;
  final String userDevices;
  final String userCreationDate;
  final String userChefDate;

  LocalUserModel({
    required this.userId,
    required this.userFullName,
    required this.userEmail,
    required this.userPhoneNumber,
    required this.userPassword,
    required this.userAvatar,
    required this.userInventory,
    required this.userFavouriteRecipes,
    required this.userNotificationsHistory,
    required this.userNotificationsEnabled,
    required this.userDarkModeEnabled,
    required this.userLanguage,
    required this.userFollowingCount,
    required this.userRecipesCount,
    required this.userFollowersCount,
    required this.userIsChef,
    required this.userIsOnFire,
    required this.userBio,
    required this.userSpecialties,
    required this.userRecipes,
    required this.userDevices,
    required this.userCreationDate,
    required this.userChefDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'user_full_name': userFullName,
      'user_email': userEmail,
      'user_phone_number': userPhoneNumber,
      'user_password': userPassword,
      'user_avatar': userAvatar,
      'user_inventory': jsonEncode(userInventory),
      'user_favourite_recipes': jsonEncode(userFavouriteRecipes),
      'user_notifications_history': jsonEncode(userNotificationsHistory),
      'user_notifications_enabled': userNotificationsEnabled ? 1 : 0,
      'user_dark_mode_enabled': userDarkModeEnabled ? 1 : 0,
      'user_language': userLanguage,
      'user_following_count': userFollowingCount,
      'user_recipes_count': userRecipesCount,
      'user_followers_count': userFollowersCount,
      'user_is_chef': userIsChef ? 1 : 0,
      'user_is_on_fire': userIsOnFire ? 1 : 0,
      'user_bio': userBio,
      'user_specialties': jsonEncode(userSpecialties),
      'user_recipes': jsonEncode(userRecipes),
      'user_devices': userDevices,
      'user_creation_date': userCreationDate,
      'user_chef_date': userChefDate,
    };
  }

  factory LocalUserModel.fromMap(Map<String, dynamic> map) {
    return LocalUserModel(
      userId: map['user_id'],
      userFullName: map['user_full_name'],
      userEmail: map['user_email'],
      userPhoneNumber: map['user_phone_number'],
      userPassword: map['user_password'],
      userAvatar: map['user_avatar'],
      userInventory: List<String>.from(jsonDecode(map['user_inventory'])),
      userFavouriteRecipes: List<String>.from(
        jsonDecode(map['user_favourite_recipes']),
      ),
      userNotificationsHistory: List<String>.from(
        jsonDecode(map['user_notifications_history']),
      ),
      userNotificationsEnabled: map['user_notifications_enabled'] == 1,
      userDarkModeEnabled: map['user_dark_mode_enabled'] == 1,
      userLanguage: map['user_language'],
      userFollowingCount: map['user_following_count'],
      userRecipesCount: map['user_recipes_count'],
      userFollowersCount: map['user_followers_count'],
      userIsChef: map['user_is_chef'] == 1,
      userIsOnFire: map['user_is_on_fire'] == 1,
      userBio: map['user_bio'],
      userSpecialties: List<String>.from(jsonDecode(map['user_specialties'])),
      userRecipes: List<String>.from(jsonDecode(map['user_recipes'])),
      userDevices: map['user_devices'],
      userCreationDate: map['user_creation_date'],
      userChefDate: map['user_chef_date'],
    );
  }
}
