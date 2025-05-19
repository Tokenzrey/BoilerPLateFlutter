import 'package:fpdart/fpdart.dart';
import 'package:boilerplate/core/domain/error/failures.dart';
import 'package:boilerplate/core/domain/usecase/use_case.dart';
import 'package:boilerplate/domain/repository/auth/auth_firebase_repository.dart';

class UpdatePasswordParams {
  final String currentPassword;
  final String newPassword;

  const UpdatePasswordParams({
    required this.currentPassword,
    required this.newPassword,
  });

  @override
  String toString() => 'UpdatePasswordParams()';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UpdatePasswordParams &&
        other.currentPassword == currentPassword &&
        other.newPassword == newPassword;
  }

  @override
  int get hashCode => currentPassword.hashCode ^ newPassword.hashCode;
}

class UpdatePasswordUseCase extends UnitUseCase<UpdatePasswordParams> {
  final AuthFirebaseRepository repository;

  const UpdatePasswordUseCase(this.repository);

  @override
  Future<Either<Failure, Unit>> execute(UpdatePasswordParams params) async {
    final result = await repository.updatePassword(
      params.currentPassword,
      params.newPassword,
    );

    return result.fold(
      (failure) => Left(failure),
      (_) => const Right(unit),
    );
  }
}
