import 'dart:convert';
import 'package:http/http.dart' as http;

class SecurityRepository {
  final String baseUrl;
  final String? accessToken;

  SecurityRepository({required this.baseUrl, this.accessToken});

  Map<String, String> _headers() {
    final headers = <String, String>{'Content-Type': 'application/json'};
    if (accessToken != null && accessToken!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $accessToken';
    }
    return headers;
  }

  Future<void> requestEmailChange({required String newEmail}) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/email/change/request'),
      headers: _headers(),
      body: jsonEncode({'new_email': newEmail}),
    );

    if (response.statusCode != 200) {
      throw Exception(_extractError(response));
    }
  }

  Future<void> verifyEmailChange({required String newEmail, required String otp}) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/email/change/verify'),
      headers: _headers(),
      body: jsonEncode({'new_email': newEmail, 'otp': otp}),
    );

    if (response.statusCode != 200) {
      throw Exception(_extractError(response));
    }
  }

  Future<void> requestPasswordChange({required String currentPassword, required String newPassword}) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/password/change/request'),
      headers: _headers(),
      body: jsonEncode({
        'current_password': currentPassword,
        'new_password': newPassword,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(_extractError(response));
    }
  }

  Future<void> verifyPasswordChange({required String newPassword, required String otp}) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/password/change/verify'),
      headers: _headers(),
      body: jsonEncode({'new_password': newPassword, 'otp': otp}),
    );

    if (response.statusCode != 200) {
      throw Exception(_extractError(response));
    }
  }

  String _extractError(http.Response response) {
    try {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final error = data['error'];
      if (error is String && error.isNotEmpty) {
        return error;
      }
      if (error is Map<String, dynamic>) {
        final message = error['message'];
        if (message is String && message.isNotEmpty) {
          return message;
        }
      }
    } catch (_) {
      // Ignore JSON errors and fall back to body
    }
    if (response.body.isNotEmpty) {
      return 'Request failed: ${response.body}';
    }
    return 'Request failed with status ${response.statusCode}';
  }
}
