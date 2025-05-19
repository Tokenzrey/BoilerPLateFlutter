import 'dart:async';
import 'package:fpdart/fpdart.dart';

import 'package:boilerplate/core/domain/error/failures.dart';
import 'package:boilerplate/domain/usecase/user/login_usecase.dart';
import 'package:boilerplate/domain/usecase/user/register_usecase.dart';
import '../../entity/user/user.dart';

abstract class UserRepository {
  Future<Either<Failure, User>> getUser(String id);
  Future<Either<Failure, List<User>>> getAllUsers();
  Future<Either<Failure, User>> updateUser(User user);
  Future<Either<Failure, Unit>> deleteUser(String id);
  Future<Either<Failure, User>> login(LoginParams params);
  Future<Either<Failure, Unit>> updatePassword(
      User user, String currentPassword, String newPassword);
  Future<Either<Failure, User>> register(RegisterParams params);
  Future<Either<Failure, Unit>> saveIsLoggedIn(bool value);
  Future<Either<Failure, bool>> get isLoggedIn;
  Future<Either<Failure, Unit>> saveUserData(User? userData);
}
