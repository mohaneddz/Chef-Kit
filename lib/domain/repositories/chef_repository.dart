import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/chef.dart';
import '../../common/config.dart';

class ChefRepository {
  late final String baseUrl;

  ChefRepository() {
    baseUrl = AppConfig.baseUrl;
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
    if (accessToken == null) {
      throw Exception('Authentication required to follow chefs');
    }

    final url = '$baseUrl/api/chefs/$id/follow';

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      // Fetch updated chef data
      final chef = await getChefById(id, accessToken: accessToken);
      if (chef == null) {
        throw Exception('Chef not found');
      }

      final updatedChef = chef.copyWith(
        isFollowed: data['is_following'] ?? !chef.isFollowed,
        followersCount: data['followers_count'] ?? chef.followersCount,
      );
      return updatedChef;
    }

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
