import 'dart:async';
import 'package:fpdart/fpdart.dart';

import 'package:boilerplate/core/domain/error/failures.dart';

import '../../entity/user/user.dart';
import '../../entity/auth/auth_token.dart';

abstract class AuthRepository {
  Future<Either<Failure, AuthToken>> generateToken(User user);
  Future<Either<Failure, AuthToken>> refreshToken(String refreshToken);
  Future<Either<Failure, bool>> validateToken(String token);
  Future<Either<Failure, AuthToken?>> getCurrentToken();
  Future<Either<Failure, User?>> getCurrentUser();
  Future<Either<Failure, Unit>> saveToken(AuthToken token);
  Future<Either<Failure, Unit>> clearToken();
  Future<Either<Failure, Unit>> revokeToken(String token);
}
