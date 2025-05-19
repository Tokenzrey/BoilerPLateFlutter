import 'package:boilerplate/core/domain/error/failures.dart';
import 'package:boilerplate/data/local/datasources/user/user_datasource.dart';
import 'package:boilerplate/data/local/models/user_model.dart';
import 'package:boilerplate/data/sharedpref/shared_preference_helper.dart';
import 'package:boilerplate/domain/entity/user/user.dart';
import 'package:boilerplate/domain/repository/user/user_repository.dart';
import 'package:boilerplate/domain/usecase/user/login_usecase.dart';
import 'package:boilerplate/domain/usecase/user/register_usecase.dart';
import 'package:fpdart/fpdart.dart';

class UserRepositoryImpl implements UserRepository {
  final UserLocalDataSource userLocalDataSource;
  final SharedPreferenceHelper sharedPrefsHelper;

  UserRepositoryImpl({
    required this.userLocalDataSource,
    required this.sharedPrefsHelper,
  });

  @override
  Future<Either<Failure, User>> login(LoginParams params) async {
    try {
      final userModel = await userLocalDataSource.login(params);
      return right(userModel.toEntity());
    } catch (e) {
      return left(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> register(RegisterParams params) async {
    try {
      final userModel = await userLocalDataSource.register(params);
      return right(userModel.toEntity());
    } catch (e) {
      return left(DatabaseFailure(e.toString()));
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
        // Simpan user data jika tidak null
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

  @override
  Future<Either<Failure, User>> getUser(String id) async {
    try {
      final result = await userLocalDataSource.getUser(id);
      return right(result!.toEntity());
    } catch (e) {
      return left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<User>>> getAllUsers() async {
    try {
      final models = await userLocalDataSource.getAllUsers();
      return right(models.map((model) => model.toEntity()).toList());
    } catch (e) {
      return left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> updateUser(User user) async {
    try {
      final userModel = UserModel.fromEntity(user);
      final result = await userLocalDataSource.updateUserData(userModel);
      return right(result.toEntity());
    } catch (e) {
      return left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> updatePassword(
      User user, String currentPassword, String newPassword) async {
    try {
      final userModel = UserModel.fromEntity(user);
      await userLocalDataSource.updatePassword(
          userModel.id, currentPassword, newPassword);
      return right(unit);
    } catch (e) {
      return left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteUser(String id) async {
    try {
      await userLocalDataSource.deleteUser(id);
      return right(unit);
    } catch (e) {
      return left(DatabaseFailure(e.toString()));
    }
  }
}
