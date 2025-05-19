import 'package:fpdart/fpdart.dart';
import 'package:boilerplate/core/domain/error/failures.dart';
import 'package:boilerplate/core/domain/usecase/use_case.dart';
import 'package:boilerplate/domain/repository/auth/auth_firebase_repository.dart';

class IsLoggedInUseCase extends NoParamsUseCase<bool> {
  final AuthFirebaseRepository repository;

  const IsLoggedInUseCase(this.repository);

  @override
  Future<Either<Failure, bool>> execute(NoParams params) async {
    return await repository.isLoggedIn;
  }
}
