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
      final response = await http.get(
        Uri.parse('$baseUrl/api/users/$userId'),
        headers: {
          'Content-Type': 'application/json',
          if (accessToken != null) 'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return UserProfile.fromJson(data);
      } else {
        throw Exception('Failed to load profile: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch profile: $e');
    }
  }

  Future<UserProfile> updatePersonalInfo({
    required String userId,
    required String fullName,
    required String bio,
    required String story,
    required List<String> specialties,
  }) async {
    try {
      final payload = <String, dynamic>{
        'user_full_name': fullName,
        'user_bio': bio,
        'user_story': story,
        'user_specialties': specialties,
      };

      final response = await http.put(
        Uri.parse('$baseUrl/api/users/$userId'),
        headers: {
          'Content-Type': 'application/json',
          if (accessToken != null) 'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return UserProfile.fromJson(data);
      }

      throw Exception(
        'Failed to update profile: ${response.statusCode} ${response.body}',
      );
    } catch (e) {
      throw Exception('Failed to update personal info: $e');
    }
  }

  Future<UserProfile> incrementRecipes() async {
    await Future.delayed(const Duration(milliseconds: 200));
    throw UnimplementedError('incrementRecipes not implemented yet');
  }
}
