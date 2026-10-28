import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TokenStorage {
  static const _storage = FlutterSecureStorage();

  static const String _keyToken = 'auth_token';
  static const String _keyUserId = 'auth_user_id';
  static const String _keyUserRole = 'auth_user_role';
  static const String _keyProviderId = 'auth_provider_id';

  /// Save token securely
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyToken, token);
    try {
      await _storage.write(key: _keyToken, value: token);
    } catch (_) {}
  }

  /// Retrieve token securely
  static Future<String?> getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cached = prefs.getString(_keyToken);
      if (cached != null && cached.isNotEmpty) return cached;
    } catch (_) {}
    try {
      return await _storage.read(key: _keyToken);
    } catch (_) {
      return null;
    }
  }

  /// Save user session info
  static Future<void> saveUserSession({
    required String token,
    required String userId,
    required String role,
    String? providerProfileId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyToken, token);
    await prefs.setString(_keyUserId, userId);
    await prefs.setString(_keyUserRole, role);
    if (providerProfileId != null) {
      await prefs.setString(_keyProviderId, providerProfileId);
    } else {
      await prefs.remove(_keyProviderId);
    }
    try {
      await _storage.write(key: _keyToken, value: token);
      await _storage.write(key: _keyUserId, value: userId);
      await _storage.write(key: _keyUserRole, value: role);
      if (providerProfileId != null) {
        await _storage.write(key: _keyProviderId, value: providerProfileId);
      }
    } catch (_) {}
  }

  /// Read current role
  static Future<String?> getUserRole() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cached = prefs.getString(_keyUserRole);
      if (cached != null && cached.isNotEmpty) return cached;
    } catch (_) {}
    try {
      return await _storage.read(key: _keyUserRole);
    } catch (_) {
      return null;
    }
  }

  /// Read user id
  static Future<String?> getUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cached = prefs.getString(_keyUserId);
      if (cached != null && cached.isNotEmpty) return cached;
    } catch (_) {}
    try {
      return await _storage.read(key: _keyUserId);
    } catch (_) {
      return null;
    }
  }

  /// Clear auth session credentials on logout without wiping shared app data
  static Future<void> clear() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyToken);
      await prefs.remove(_keyUserId);
      await prefs.remove(_keyUserRole);
      await prefs.remove(_keyProviderId);
    } catch (_) {}
    try {
      await _storage.deleteAll();
    } catch (_) {}
  }
}
