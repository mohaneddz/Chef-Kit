import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/chef.dart';
import 'package:flutter/foundation.dart';
import 'dart:io' show Platform;

class ChefRepository {
  late final String baseUrl;

  ChefRepository() {
    if (kIsWeb) {
      baseUrl = 'http://localhost:5000';
    } else if (Platform.isAndroid) {
      baseUrl = 'http://10.0.2.2:5000';
    } else {
      baseUrl = 'http://localhost:5000';
    }
  }

  Future<List<Chef>> fetchAllChefs() async {
    final response = await http
        .get(Uri.parse('$baseUrl/api/users'))
        .timeout(const Duration(seconds: 10));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data
          .where((json) => json['user_is_chef'] == true)
          .map((json) => Chef.fromJson(json))
          .toList();
    }
    throw Exception('Failed to load chefs');
  }

  Future<Chef?> getChefById(String id, {String? accessToken}) async {
    final headers = <String, String>{};
    if (accessToken != null) {
      headers['Authorization'] = 'Bearer $accessToken';
    }

    final response = await http.get(
      Uri.parse('$baseUrl/api/chefs/$id'),
      headers: headers.isNotEmpty ? headers : null,
    );

    if (response.statusCode == 200) {
      return Chef.fromJson(json.decode(response.body));
    }
    return null;
  }

  Future<Chef> toggleFollow(String id, {String? accessToken}) async {
    print('\n🔶 ChefRepository.toggleFollow START');
    print('Chef ID: $id');
    print(
      'Access Token: ${accessToken != null ? "PROVIDED (${accessToken.substring(0, 20)}...)" : "NULL"}',
    );

    if (accessToken == null) {
      print('❌ ERROR: No access token provided');
      throw Exception('Authentication required to follow chefs');
    }

    final url = '$baseUrl/api/chefs/$id/follow';
    print('Making POST request to: $url');

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print('✅ Follow toggle successful');
      print('New follow status: ${data['is_following']}');
      print('New followers count: ${data['followers_count']}');

      // Fetch updated chef data
      print('Fetching updated chef data...');
      final chef = await getChefById(id, accessToken: accessToken);
      if (chef == null) {
        print('❌ ERROR: Chef not found after toggle');
        throw Exception('Chef not found');
      }

      print('Chef fetched, creating updated copy...');
      final updatedChef = chef.copyWith(
        isFollowed: data['is_following'] ?? !chef.isFollowed,
        followersCount: data['followers_count'] ?? chef.followersCount,
      );
      print(
        '✅ Updated chef created: isFollowed=${updatedChef.isFollowed}, followers=${updatedChef.followersCount}',
      );
      print('🔶 ChefRepository.toggleFollow END\n');
      return updatedChef;
    }

    print('❌ ERROR: Failed to toggle follow - Status ${response.statusCode}');
    print('Response: ${response.body}');
    print('🔶 ChefRepository.toggleFollow END (ERROR)\n');
    throw Exception(
      'Failed to toggle follow: ${response.statusCode} - ${response.body}',
    );
  }

  Future<List<Chef>> fetchChefsOnFire() async {
    final response = await http
        .get(Uri.parse('$baseUrl/api/chefs/on-fire'))
        .timeout(const Duration(seconds: 10));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Chef.fromJson(json)).toList();
    }
    throw Exception('Failed to load chefs on fire');
  }
}
