import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_profile.dart';

class ProfileRepository {
  final String baseUrl;
  final String? accessToken;

  ProfileRepository({required this.baseUrl, this.accessToken});

  Future<UserProfile> fetchProfile(String userId) async {
    try {
      print('=== ProfileRepository.fetchProfile ===');
      print('Fetching profile for userId: $userId');
      print('URL: $baseUrl/api/users/$userId');
      
      final response = await http.get(
        Uri.parse('$baseUrl/api/users/$userId'),
        headers: {
          'Content-Type': 'application/json',
          if (accessToken != null) 'Authorization': 'Bearer $accessToken',
        },
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Decoded JSON data: $data');
        return UserProfile.fromJson(data);
      } else {
        throw Exception('Failed to load profile: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching profile: $e');
      throw Exception('Failed to fetch profile: $e');
    }
  }

  Future<UserProfile> updateProfile(UserProfile profile) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return profile;
  }

  Future<UserProfile> incrementRecipes() async {
    await Future.delayed(const Duration(milliseconds: 200));
    throw UnimplementedError('incrementRecipes not implemented yet');
  }
}
