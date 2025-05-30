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
}
