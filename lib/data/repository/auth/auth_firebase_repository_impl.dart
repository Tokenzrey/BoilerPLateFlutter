import 'package:boilerplate/data/local/models/user_firebase_model.dart';
import 'package:fpdart/fpdart.dart';
import 'package:boilerplate/core/domain/error/failures.dart';
import 'package:boilerplate/domain/entity/user/user.dart';
import 'package:boilerplate/domain/repository/auth/auth_firebase_repository.dart';
import 'package:boilerplate/data/sharedpref/shared_preference_helper.dart';
import 'package:boilerplate/data/local/datasources/auth/auth_firebase_datasource.dart';

class AuthFirebaseRepositoryImpl implements AuthFirebaseRepository {
  final AuthFirebaseDataSource dataSource;
  final SharedPreferenceHelper sharedPrefsHelper;

  AuthFirebaseRepositoryImpl(
      {required this.dataSource, required this.sharedPrefsHelper});

  @override
  Future<Either<Failure, User>> register(
      String email, String password, String username, String fullName) async {
    try {
      final userModel =
          await dataSource.register(email, password, username, fullName);
      return Right(_mapFirebaseUserToUser(userModel));
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> login(String email, String password) async {
    try {
      final userModel = await dataSource.login(email, password);
      final user = _mapFirebaseUserToUser(userModel);

      await sharedPrefsHelper.saveIsLoggedIn(true);
      await sharedPrefsHelper.setUserData(user);
      return Right(user);
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> updateUserData(
      String fullName, String username, String? photoUrl) async {
    try {
      final userModel =
          await dataSource.updateUserData(fullName, username, photoUrl);
      final user = _mapFirebaseUserToUser(userModel);

      await sharedPrefsHelper.setUserData(user);
      return Right(user);
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updatePassword(
      String currentPassword, String newPassword) async {
    try {
      await dataSource.updatePassword(currentPassword, newPassword);
      return const Right(null);
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await dataSource.logout();
      await sharedPrefsHelper.saveIsLoggedIn(false);
      await sharedPrefsHelper.removeUserData();
      return const Right(null);
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User?>> getCurrentUser() async {
    try {
      final userModel = await dataSource.getCurrentUser();
      return Right(
          userModel != null ? _mapFirebaseUserToUser(userModel) : null);
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> saveIsLoggedIn(bool value) async {
    try {
      await sharedPrefsHelper.saveIsLoggedIn(value);
      return right(unit);
    } catch (e) {
      return left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> saveUserData(User? userData) async {
    try {
      if (userData == null) {
        await sharedPrefsHelper.removeUserData();
      } else {
        await sharedPrefsHelper.setUserData(userData);
      }
      return right(unit);
    } catch (e) {
      return left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> get isLoggedIn async {
    try {
      final isLoggedIn = sharedPrefsHelper.isLoggedIn;
      return right(await isLoggedIn);
    } catch (e) {
      return left(CacheFailure(e.toString()));
    }
  }

  User _mapFirebaseUserToUser(FirebaseUserModel model) {
    return User(
      id: model.id,
      email: model.email,
      username: model.username,
      fullName: model.fullName,
      createdAt: model.createdAt,
      lastLogin: model.lastLogin,
      roles: model.roles,
    );
  }
}
