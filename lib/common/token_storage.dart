import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Secure storage for authentication tokens using platform secure storage
/// (Keychain on iOS, Keystore on Android, Credential Manager on Windows)
class TokenStorage {
  static const _accessKey = 'chefkit_access_token';
  static const _refreshKey = 'chefkit_refresh_token';
  static const _userIdKey = 'chefkit_user_id';

  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
  );

  /// Save refresh token securely
  Future<void> saveRefreshToken(String refreshToken) async {
    await _storage.write(key: _refreshKey, value: refreshToken);
  }

  /// Read stored refresh token
  Future<String?> readRefreshToken() async {
    return await _storage.read(key: _refreshKey);
  }

  /// Delete refresh token
  Future<void> deleteRefreshToken() async {
    await _storage.delete(key: _refreshKey);
  }

  /// Save access token (optional - can keep in memory only)
  Future<void> saveAccessToken(String accessToken) async {
    await _storage.write(key: _accessKey, value: accessToken);
  }

  /// Read stored access token
  Future<String?> readAccessToken() async {
    return await _storage.read(key: _accessKey);
  }

  /// Delete access token
  Future<void> deleteAccessToken() async {
    await _storage.delete(key: _accessKey);
  }

  /// Save user ID
  Future<void> saveUserId(String userId) async {
    await _storage.write(key: _userIdKey, value: userId);
  }

  /// Read stored user ID
  Future<String?> readUserId() async {
    return await _storage.read(key: _userIdKey);
  }

  /// Delete user ID
  Future<void> deleteUserId() async {
    await _storage.delete(key: _userIdKey);
  }

  /// Clear all stored tokens
  Future<void> clearAll() async {
    await Future.wait([
      deleteAccessToken(),
      deleteRefreshToken(),
      deleteUserId(),
    ]);
  }
}
