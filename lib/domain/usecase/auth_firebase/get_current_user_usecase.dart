import 'package:fpdart/fpdart.dart';
import 'package:boilerplate/core/domain/error/failures.dart';
import 'package:boilerplate/core/domain/usecase/use_case.dart';
import 'package:boilerplate/domain/entity/user/user.dart';
import 'package:boilerplate/domain/repository/auth/auth_firebase_repository.dart';

class GetCurrentUserUseCase extends NoParamsUseCase<User?> {
  final AuthFirebaseRepository repository;

  const GetCurrentUserUseCase(this.repository);

  @override
  Future<Either<Failure, User?>> execute(NoParams params) async {
    try {
      final currentUser = await repository.getCurrentUser();
      return currentUser;
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }
}
