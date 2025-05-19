import 'dart:async';
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:boilerplate/data/local/models/auth_token_model.dart';
import 'package:boilerplate/constants/strings.dart';

class AuthLocalDataSource {
  final FlutterSecureStorage secureStorage;
  static const String tokenKey = Strings.tokenKey;

  AuthLocalDataSource(this.secureStorage);

  Future<void> saveToken(AuthTokenModel token) async {
    final tokenJson = jsonEncode(token.toJson());
    await secureStorage.write(key: tokenKey, value: tokenJson);
  }

  Future<AuthTokenModel?> getToken() async {
    final tokenJson = await secureStorage.read(key: tokenKey);
    if (tokenJson == null) return null;

    try {
      final Map<String, dynamic> tokenMap = jsonDecode(tokenJson);
      return AuthTokenModel.fromJson(tokenMap);
    } catch (e) {
      await secureStorage.delete(key: tokenKey);
      return null;
    }
  }

  Future<void> deleteToken() async {
    await secureStorage.delete(key: tokenKey);
  }
}
