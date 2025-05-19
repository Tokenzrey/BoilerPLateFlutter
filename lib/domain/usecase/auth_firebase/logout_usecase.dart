import 'package:fpdart/fpdart.dart';
import 'package:boilerplate/core/domain/error/failures.dart';
import 'package:boilerplate/core/domain/usecase/use_case.dart';
import 'package:boilerplate/domain/repository/auth/auth_firebase_repository.dart';

class LogoutUseCase extends NoParamsUnitUseCase {
  final AuthFirebaseRepository repository;

  const LogoutUseCase(this.repository);

  @override
  Future<Either<Failure, Unit>> execute(NoParams params) async {
    final result = await repository.logout();

    return result.fold(
      (failure) => Left(failure),
      (_) => const Right(unit),
    );
  }
}
