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
    final response = await http.get(Uri.parse('$baseUrl/api/users'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.where((json) => json['user_is_chef'] == true).map((json) => Chef.fromJson(json)).toList();
    }
    throw Exception('Failed to load chefs');
  }

  Future<Chef?> getChefById(String id) async {
    final response = await http.get(Uri.parse('$baseUrl/api/chefs/$id'));
    if (response.statusCode == 200) {
      return Chef.fromJson(json.decode(response.body));
    }
    return null;
  }

  Future<Chef> toggleFollow(String id, {String? accessToken}) async {
    if (accessToken == null) {
      throw Exception('Authentication required to follow chefs');
    }
    
    final response = await http.post(
      Uri.parse('$baseUrl/api/chefs/$id/follow'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      // Fetch updated chef data
      final chef = await getChefById(id);
      if (chef == null) throw Exception('Chef not found');
      return chef.copyWith(
        isFollowed: data['is_following'] ?? !chef.isFollowed,
        followersCount: data['followers_count'] ?? chef.followersCount,
      );
    }
    throw Exception('Failed to toggle follow');
  }

  Future<List<Chef>> fetchChefsOnFire() async {
    final response = await http.get(Uri.parse('$baseUrl/api/chefs/on-fire'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Chef.fromJson(json)).toList();
    }
    throw Exception('Failed to load chefs on fire');
  }
}
