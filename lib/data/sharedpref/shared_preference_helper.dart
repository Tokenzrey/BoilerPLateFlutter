import 'dart:async';
import 'dart:convert';

import 'package:boilerplate/data/local/models/user_model.dart';
import 'package:boilerplate/domain/entity/user/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'constants/preferences.dart';

class SharedPreferenceHelper {
  // shared pref instance
  final SharedPreferences _sharedPreference;

  // constructor
  SharedPreferenceHelper(this._sharedPreference);

  // General Methods: ----------------------------------------------------------
  Future<String?> get authToken async {
    return _sharedPreference.getString(Preferences.authToken);
  }

  Future<bool> saveAuthToken(String authToken) async {
    return _sharedPreference.setString(Preferences.authToken, authToken);
  }

  Future<bool> removeAuthToken() async {
    return _sharedPreference.remove(Preferences.authToken);
  }

  // User:---------------------------------------------------------------------
  Future<bool> setUserData(User userData) async {
    final userModel = UserModel.fromEntity(userData);
    final userJson = userModel.toJson();
    final userJsonString = json.encode(userJson);
    return _sharedPreference.setString(Preferences.userData, userJsonString);
  }

  Future<bool> removeUserData() async {
    return _sharedPreference.remove(Preferences.userData);
  }

  Future<String?> get userData async {
    return _sharedPreference.getString(Preferences.userData);
  }

  Future<User?> getUserData() async {
    final userJsonString = await userData;

    if (userJsonString == null || userJsonString.isEmpty) {
      return null;
    }

    try {
      final Map<String, dynamic> userJson = json.decode(userJsonString);
      final UserModel userModel = UserModel.fromJson(userJson);
      return userModel.toEntity();
    } catch (e) {
      return null;
    }
  }

  // Login:---------------------------------------------------------------------
  Future<bool> get isLoggedIn async {
    return _sharedPreference.getBool(Preferences.isLoggedIn) ?? false;
  }

  Future<bool> saveIsLoggedIn(bool value) async {
    return _sharedPreference.setBool(Preferences.isLoggedIn, value);
  }

  // Theme:------------------------------------------------------
  bool get isDarkMode {
    return _sharedPreference.getBool(Preferences.isDarkMode) ?? false;
  }

  Future<void> changeBrightnessToDark(bool value) {
    return _sharedPreference.setBool(Preferences.isDarkMode, value);
  }

  // Language:---------------------------------------------------
  String? get currentLanguage {
    return _sharedPreference.getString(Preferences.currentLanguage);
  }

  Future<void> changeLanguage(String language) {
    return _sharedPreference.setString(Preferences.currentLanguage, language);
  }

  // Clear all network cache entries
  Future<bool> clearNetworkCache() async {
    final keyPrefix = 'network_cache_';
    final keys = _sharedPreference.getKeys();
    bool allSuccess = true;

    for (final key in keys) {
      if (key.startsWith(keyPrefix)) {
        final success = await _sharedPreference.remove(key);
        if (!success) allSuccess = false;
      }
    }

    return allSuccess;
  }

  // Cache:------------------------------------------------------
  // Get cache usage statistics
  Future<Map<String, dynamic>> getNetworkCacheStats() async {
    final keyPrefix = 'network_cache_';
    final keys = _sharedPreference
        .getKeys()
        .where((key) => key.startsWith(keyPrefix))
        .toList();

    int totalSize = 0;
    DateTime? oldestEntry;
    DateTime? newestEntry;

    for (final key in keys) {
      final value = _sharedPreference.getString(key);
      if (value != null) {
        totalSize += value.length;

        try {
          final json = jsonDecode(value) as Map<String, dynamic>;
          final createdAt = DateTime.parse(json['createdAt'] as String);

          if (oldestEntry == null || createdAt.isBefore(oldestEntry)) {
            oldestEntry = createdAt;
          }

          if (newestEntry == null || createdAt.isAfter(newestEntry)) {
            newestEntry = createdAt;
          }
        } catch (_) {}
      }
    }

    return {
      'entryCount': keys.length,
      'totalSizeBytes': totalSize,
      'oldestEntry': oldestEntry?.toIso8601String(),
      'newestEntry': newestEntry?.toIso8601String(),
    };
  }
}
