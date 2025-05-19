/// JWT Service for mobile-only authentication
///
/// This service provides comprehensive JWT (JSON Web Token) implementation for
/// mobile applications without requiring a backend server. Features include:
///
/// - Generation of access and refresh tokens
/// - Token validation and signature verification
/// - Token refresh mechanism
/// - Token revocation tracking
/// - Secure storage of JWT secrets
///
/// All cryptographic operations use industry-standard algorithms:
/// - HMAC-SHA256 for token signatures
/// - Fortuna CSPRNG for secure random number generation
/// - Secure storage for persistent keys
library;

import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:boilerplate/data/local/models/auth_token_model.dart';
import 'package:boilerplate/core/logging/logger.dart';
import 'package:boilerplate/di/service_locator.dart';
import 'package:boilerplate/domain/entity/user/user.dart';
import 'package:boilerplate/domain/repository/user/user_repository.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pointycastle/api.dart' show KeyParameter;
import 'package:pointycastle/random/fortuna_random.dart';
import 'package:boilerplate/constants/strings.dart';

enum JwtResult {
  success,
  invalidSignature,
  tokenExpired,
  invalidIssuer,
  tokenRevoked,
  malformedToken,
  internalError,
}

class JwtService {
  final FlutterSecureStorage _secureStorage;
  final UserRepository _userRepository;

  late final Logger _logger;

  static const _storageKey = Strings.secretJwtKey;
  static const _revokedTokensKey = Strings.revokedTokenKey;
  static const _issuer = Strings.issuerJwt;
  static const _accessTtl = Duration(hours: 1);
  static const _refreshTtl = Duration(days: 30);

  final bool enableLogging;

  JwtService(this._secureStorage, this._userRepository,
      {this.enableLogging = false}) {
    if (enableLogging) {
      _logger = getIt<Logger>().withTag('[JwtService]');
    }
  }

  Future<String> _getSecretKey() async {
    final existing = await _secureStorage.read(key: _storageKey);
    if (existing != null) {
      _log('Using existing JWT secret key');
      return existing;
    }

    _log('Generating new JWT secret key');
    final bytes = _generateSecureRandomBytes(32);
    final encoded = base64Url.encode(bytes);
    await _secureStorage.write(key: _storageKey, value: encoded);
    return encoded;
  }

  Uint8List _generateSecureRandomBytes(int length) {
    final seed = Uint8List(32);
    final rnd = Random.secure();
    for (var i = 0; i < seed.length; i++) {
      seed[i] = rnd.nextInt(256);
    }

    final fortuna = FortunaRandom()..seed(KeyParameter(seed));
    final output = Uint8List(length);
    for (var i = 0; i < length; i++) {
      output[i] = fortuna.nextUint8();
    }
    return output;
  }

  Future<AuthTokenModel> generateToken(User user) async {
    final secret = await _getSecretKey();
    final nowUtc = DateTime.now().toUtc();
    final accessExp = nowUtc.add(_accessTtl);
    final refreshExp = nowUtc.add(_refreshTtl);

    _log('Generating tokens for user ${user.id}');

    final accessPayload = <String, dynamic>{
      'sub': user.id,
      'iss': _issuer,
      'iat': nowUtc.millisecondsSinceEpoch ~/ 1000,
      'exp': accessExp.millisecondsSinceEpoch ~/ 1000,
      'nbf': nowUtc.millisecondsSinceEpoch ~/ 1000,
      'email': user.email,
      'username': user.username,
      'roles': user.roles,
      'jti': _generateJti(),
    };

    final refreshPayload = <String, dynamic>{
      'sub': user.id,
      'iss': _issuer,
      'iat': nowUtc.millisecondsSinceEpoch ~/ 1000,
      'exp': refreshExp.millisecondsSinceEpoch ~/ 1000,
      'nbf': nowUtc.millisecondsSinceEpoch ~/ 1000,
      'jti': _generateJti(),
    };

    return AuthTokenModel(
      accessToken: _encodeJwt(accessPayload, secret),
      refreshToken: _encodeJwt(refreshPayload, secret),
      expiresAt: accessExp,
      userId: user.id,
    );
  }

  Future<(AuthTokenModel?, JwtResult)> refreshToken(String refreshToken) async {
    final secret = await _getSecretKey();
    final (payload, result) = _verifyAndDecodeJwt(refreshToken, secret);

    if (result != JwtResult.success || payload == null) {
      _log('Refresh token validation failed: $result');
      return (null, result);
    }

    if (await _isTokenRevoked(payload['jti'] as String?)) {
      _log('Refresh token has been revoked');
      return (null, JwtResult.tokenRevoked);
    }

    final userId = payload['sub'] as String?;
    if (userId == null) {
      _log('Missing subject (sub) in refresh token');
      return (null, JwtResult.malformedToken);
    }

    _log('Creating new access token for user $userId');

    final userResult = await _userRepository.getUser(userId);

    return userResult.fold(
      (failure) => (null, JwtResult.tokenExpired),
      (user) {
        final nowUtc = DateTime.now().toUtc();
        final accessExp = nowUtc.add(_accessTtl);
        final jti = _generateJti();

        final newPayload = {
          'sub': userId,
          'iss': _issuer,
          'iat': nowUtc.millisecondsSinceEpoch ~/ 1000,
          'exp': accessExp.millisecondsSinceEpoch ~/ 1000,
          'nbf': nowUtc.millisecondsSinceEpoch ~/ 1000,
          'email': user.email,
          'username': user.username,
          'roles': user.roles,
          'jti': jti,
        };

        return (
          AuthTokenModel(
            accessToken: _encodeJwt(newPayload, secret),
            refreshToken: refreshToken,
            expiresAt: accessExp,
            userId: userId,
          ),
          JwtResult.success
        );
      },
    );
  }

  Future<(bool, JwtResult)> validateToken(String token) async {
    final secret = await _getSecretKey();
    final (payload, result) = _verifyAndDecodeJwt(token, secret);

    if (result != JwtResult.success || payload == null) {
      _log('Token validation failed: $result');
      return (false, result);
    }

    if (await _isTokenRevoked(payload['jti'] as String?)) {
      _log('Token has been revoked');
      return (false, JwtResult.tokenRevoked);
    }

    _log('Token is valid');
    return (true, JwtResult.success);
  }

  Future<bool> revokeToken(String token) async {
    try {
      final secret = await _getSecretKey();
      final (payload, result) = _verifyAndDecodeJwt(token, secret);

      if (result != JwtResult.success || payload == null) {
        _log('Cannot revoke invalid token: $result');
        return false;
      }

      final jti = payload['jti'] as String?;
      if (jti == null) {
        _log('Token lacks JTI claim, cannot revoke');
        return false;
      }

      await _addRevokedToken(jti);
      _log('Token revoked successfully: $jti');
      return true;
    } catch (e) {
      _log('Error revoking token: $e');
      return false;
    }
  }

  String _encodeJwt(Map<String, dynamic> payload, String secret) {
    final header = {'alg': 'HS256', 'typ': 'JWT'};
    final hdr =
        base64Url.encode(utf8.encode(jsonEncode(header))).replaceAll('=', '');
    final pl =
        base64Url.encode(utf8.encode(jsonEncode(payload))).replaceAll('=', '');
    final data = '$hdr.$pl';
    final sig =
        Hmac(sha256, utf8.encode(secret)).convert(utf8.encode(data)).bytes;
    final encSig = base64Url.encode(sig).replaceAll('=', '');
    return '$data.$encSig';
  }

  (Map<String, dynamic>?, JwtResult) _verifyAndDecodeJwt(
      String token, String secret) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) {
        return (null, JwtResult.malformedToken);
      }

      final data = '${parts[0]}.${parts[1]}';
      final expected = base64Url
          .encode(Hmac(sha256, utf8.encode(secret))
              .convert(utf8.encode(data))
              .bytes)
          .replaceAll('=', '');

      if (parts[2] != expected) {
        return (null, JwtResult.invalidSignature);
      }

      final payloadJson =
          utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
      final payload = jsonDecode(payloadJson) as Map<String, dynamic>;

      if (payload['iss'] != _issuer) {
        return (null, JwtResult.invalidIssuer);
      }

      final expUtc =
          DateTime.fromMillisecondsSinceEpoch((payload['exp'] as int) * 1000);
      if (DateTime.now().toUtc().isAfter(expUtc)) {
        return (null, JwtResult.tokenExpired);
      }

      if (payload.containsKey('nbf')) {
        final nbfUtc =
            DateTime.fromMillisecondsSinceEpoch((payload['nbf'] as int) * 1000);
        if (DateTime.now().toUtc().isBefore(nbfUtc)) {
          return (null, JwtResult.invalidSignature);
        }
      }

      return (payload, JwtResult.success);
    } catch (e) {
      _log('Error decoding JWT: $e');
      return (null, JwtResult.internalError);
    }
  }

  String _generateJti() {
    final bytes = _generateSecureRandomBytes(16);
    return base64Url.encode(bytes).replaceAll('=', '');
  }

  Future<bool> _isTokenRevoked(String? jti) async {
    if (jti == null) return false;

    final revokedStr = await _secureStorage.read(key: _revokedTokensKey);
    if (revokedStr == null) return false;

    try {
      final revokedList = jsonDecode(revokedStr) as List;

      if (revokedList.contains(jti)) return true;

      final userId = jti.startsWith('user:') ? jti : null;
      if (userId != null && revokedList.any((item) => item == userId)) {
        return true;
      }

      return false;
    } catch (e) {
      _log('Error checking revoked tokens: $e');
      return false;
    }
  }

  Future<void> _addRevokedToken(String jti) async {
    List<dynamic> revokedList = [];

    final revokedStr = await _secureStorage.read(key: _revokedTokensKey);
    if (revokedStr != null) {
      try {
        revokedList = jsonDecode(revokedStr) as List;
      } catch (e) {
        _log('Error parsing revoked tokens: $e, creating new list');
      }
    }

    if (!revokedList.contains(jti)) {
      revokedList.add(jti);
    }

    if (revokedList.length > 100) {
      revokedList = revokedList.sublist(revokedList.length - 100);
    }

    await _secureStorage.write(
        key: _revokedTokensKey, value: jsonEncode(revokedList));
  }

  void _log(String message) {
    if (enableLogging) {
      _logger.debug(message);
    }
  }

  Future<void> clearRevokedTokens() async {
    await _secureStorage.delete(key: _revokedTokensKey);
    _log('Cleared all revoked tokens');
  }
}
