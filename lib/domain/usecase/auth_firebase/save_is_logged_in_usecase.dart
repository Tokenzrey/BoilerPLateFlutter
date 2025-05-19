import 'package:fpdart/fpdart.dart';
import 'package:boilerplate/core/domain/error/failures.dart';
import 'package:boilerplate/core/domain/usecase/use_case.dart';
import 'package:boilerplate/domain/repository/auth/auth_firebase_repository.dart';

class SaveLoginStatusParams {
  final bool isLoggedIn;

  const SaveLoginStatusParams({required this.isLoggedIn});

  @override
  String toString() => 'SaveLoginStatusParams(isLoggedIn: $isLoggedIn)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SaveLoginStatusParams && other.isLoggedIn == isLoggedIn;
  }

  @override
  int get hashCode => isLoggedIn.hashCode;
}

class SaveLoginStatusUseCase extends UnitUseCase<SaveLoginStatusParams> {
  final AuthFirebaseRepository repository;

  const SaveLoginStatusUseCase(this.repository);

  @override
  Future<Either<Failure, Unit>> execute(SaveLoginStatusParams params) async {
    return await repository.saveIsLoggedIn(params.isLoggedIn);
  }
}
