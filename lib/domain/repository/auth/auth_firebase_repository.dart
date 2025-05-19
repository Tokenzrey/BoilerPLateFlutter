import 'package:fpdart/fpdart.dart';
import 'package:boilerplate/domain/entity/user/user.dart';
import 'package:boilerplate/core/domain/error/failures.dart';

abstract class AuthFirebaseRepository {
  Future<Either<Failure, User>> register(
      String email, String password, String username, String fullName);
  Future<Either<Failure, User>> login(String email, String password);
  Future<Either<Failure, User>> updateUserData(
      String fullName, String username, String? photoUrl);
  Future<Either<Failure, void>> updatePassword(
      String currentPassword, String newPassword);
  Future<Either<Failure, void>> logout();
  User? getCurrentUser();
  Future<Either<Failure, Unit>> saveIsLoggedIn(bool value);
  Future<Either<Failure, Unit>> saveUserData(User? userData);
  Future<Either<Failure, bool>> get isLoggedIn;
}
