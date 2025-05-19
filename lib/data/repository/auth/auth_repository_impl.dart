import 'dart:async';

import 'package:fpdart/fpdart.dart';

import 'package:boilerplate/core/data/jwt/jwt_service.dart';
import 'package:boilerplate/core/domain/error/failures.dart';
import 'package:boilerplate/data/local/datasources/auth/auth_datasource.dart';
import 'package:boilerplate/data/local/datasources/user/user_datasource.dart';
import 'package:boilerplate/data/local/models/auth_token_model.dart';
import 'package:boilerplate/domain/entity/auth/auth_token.dart';
import 'package:boilerplate/domain/entity/user/user.dart';
import 'package:boilerplate/domain/repository/auth/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthLocalDataSource authLocalDataSource;
  final UserLocalDataSource userLocalDataSource;
  final JwtService jwtService;

  AuthRepositoryImpl({
    required this.authLocalDataSource,
    required this.userLocalDataSource,
    required this.jwtService,
  });

  @override
  Future<Either<Failure, AuthToken>> generateToken(User user) async {
    try {
      final tokenModel = await jwtService.generateToken(user);
      return right(tokenModel.toEntity());
    } catch (e) {
      return left(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthToken>> refreshToken(String refreshToken) async {
    try {
      final (tokenModel, result) = await jwtService.refreshToken(refreshToken);
      switch (result) {
        case JwtResult.success:
          if (tokenModel != null) {
            final AuthToken tokenModelEntity = tokenModel.toEntity();
            return right(tokenModelEntity);
          }
          return left(
              const AuthFailure('Token refresh successful but model is null'));

        case JwtResult.tokenExpired:
          return left(AuthFailure('Token expired'));

        case JwtResult.tokenRevoked:
          return left(AuthFailure('Token get revoked'));

        case JwtResult.invalidSignature:
          return left(AuthFailure('Token invalid signature'));

        case JwtResult.malformedToken:
          return left(AuthFailure('Malformed token'));

        default:
          return left(AuthFailure('Failed to refresh token'));
      }
    } catch (e) {
      return left(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> validateToken(String token) async {
    try {
      final (isValid, result) = await jwtService.validateToken(token);
      return right(isValid);
    } catch (e) {
      return left(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthToken?>> getCurrentToken() async {
    try {
      final tokenModel = await authLocalDataSource.getToken();
      return right(tokenModel?.toEntity());
    } catch (e) {
      return left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User?>> getCurrentUser() async {
    try {
      final tokenResult = await getCurrentToken();

      return await tokenResult.fold(
        (failure) => left(failure),
        (token) async {
          if (token == null) {
            return right(null);
          }

          final validationResult = await validateToken(token.accessToken);

          return await validationResult.fold(
            (failure) => left(failure),
            (isValid) async {
              if (!isValid) {
                return right(null);
              }
              final userModel = await userLocalDataSource.getUser(token.userId);

              if (userModel == null) {
                return right(null);
              } else {
                return right(userModel.toEntity());
              }
            },
          );
        },
      );
    } catch (e) {
      return left(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> saveToken(AuthToken token) async {
    try {
      await authLocalDataSource.saveToken(AuthTokenModel.fromEntity(token));
      return right(unit);
    } catch (e) {
      return left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> clearToken() async {
    try {
      await authLocalDataSource.deleteToken();
      return right(unit);
    } catch (e) {
      return left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> revokeToken(String token) async {
    try {
      final isSuccesRevoked = await jwtService.revokeToken(token);
      if (!isSuccesRevoked) {
        return left(AuthFailure('Failed to revoke token'));
      }
      return right(unit);
    } catch (e) {
      return left(CacheFailure(e.toString()));
    }
  }
}
