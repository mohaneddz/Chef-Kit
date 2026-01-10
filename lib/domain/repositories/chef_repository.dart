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

    try {
      final response = await http
          .post(
            Uri.parse(url),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $accessToken',
            },
          )
          .timeout(const Duration(seconds: 10));

      // Even if parsing fails, we treat status 200 as success and fallback to existing data
      bool? isFollowing;
      int? followersCount;
      if (response.statusCode == 200) {
        try {
          final data = json.decode(response.body);
          isFollowing = data['is_following'] as bool?;
          followersCount = data['followers_count'] is int
              ? data['followers_count'] as int
              : int.tryParse(data['followers_count']?.toString() ?? '');
        } catch (_) {
          // ignore parse errors, will fallback below
        }
      } else {
        throw Exception(
          'Failed to toggle follow: ${response.statusCode} - ${response.body}',
        );
      }

      // Fetch updated chef data (best effort)
      final chef = await getChefById(id, accessToken: accessToken);
      if (chef == null) {
        // If we can't fetch, return minimal info with toggled flag
        return Chef(
          id: id,
          name: 'Chef',
          imageUrl: 'https://via.placeholder.com/250',
          isFollowed: isFollowing ?? true,
          followersCount: followersCount ?? 0,
        );
      }

      return chef.copyWith(
        isFollowed: isFollowing ?? !chef.isFollowed,
        followersCount: followersCount ?? chef.followersCount,
      );
    } catch (e) {
      throw Exception('Failed to toggle follow: ${e.toString()}');
    }
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
