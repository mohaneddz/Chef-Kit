import 'dart:async';
import '../models/user_profile.dart';

class ProfileRepository {
  UserProfile _profile = UserProfile(
    id: 'u1',
    name: 'Chef Ramsay',
    email: 'chef.ramsay@chefkit.com',
    avatarUrl: 'assets/images/chefs/chef_1.png',
    recipesCount: 24,
    favoritesCount: 48,
    savedCount: 12,
  );

  Future<UserProfile> fetchProfile() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _profile;
  }

  Future<UserProfile> updateProfile(UserProfile profile) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _profile = profile;
    return _profile;
  }

  Future<UserProfile> incrementRecipes() async {
    _profile = _profile.copyWith(recipesCount: _profile.recipesCount + 1);
    return _profile;
  }
}
