/// Offline provider stub.
///
/// There is currently no local database implementation. This
/// class defines the same surface area as the online provider
/// would need, but methods are left intentionally empty so the
/// app can compile while you design offline storage.
class OfflineProvider {
  const OfflineProvider();

  // Example methods that mirror the online provider responsibilities.
  // Implement them later when you add a local database (e.g. Hive,
  // Isar, sqflite, or Drift). For now they return `Future<void>` or
  // simple types and do nothing.

  /// Load cached user profile by ID.
  Future<void> loadUserProfile(String userId) async {
    // TODO: Implement offline user profile load.
  }

  /// Save user profile cache.
  Future<void> saveUserProfile(Map<String, dynamic> userJson) async {
    // TODO: Implement offline user profile save.
  }

  /// Load cached recipes list.
  Future<void> loadRecipes() async {
    // TODO: Implement offline recipes load.
  }

  /// Save recipes cache.
  Future<void> saveRecipes(List<Map<String, dynamic>> recipesJson) async {
    // TODO: Implement offline recipes save.
  }

  /// Load cached ingredients list.
  Future<void> loadIngredients() async {
    // TODO: Implement offline ingredients load.
  }

  /// Save ingredients cache.
  Future<void> saveIngredients(List<Map<String, dynamic>> ingredientsJson) async {
    // TODO: Implement offline ingredients save.
  }

  /// Clear all local cached data.
  Future<void> clearCache() async {
    // TODO: Implement offline cache clear.
  }

  // =============================
  // Refresh Tokens (local table)
  // =============================
  // NOTE: In absence of a real local DB, we keep an in-memory
  // map to simulate a `refresh_tokens` table. Replace this later
  // with Hive/Isar/Drift as needed.

  static final Map<String, String> _refreshTokens = <String, String>{};

  /// Save a refresh token for a user locally.
  Future<void> saveRefreshToken({required String userId, required String refreshToken}) async {
    _refreshTokens[userId] = refreshToken;
  }

  /// Read the stored refresh token for a user.
  Future<String?> getRefreshToken(String userId) async {
    return _refreshTokens[userId];
  }

  /// Delete a stored refresh token for a user.
  Future<void> deleteRefreshToken(String userId) async {
    _refreshTokens.remove(userId);
  }
}
