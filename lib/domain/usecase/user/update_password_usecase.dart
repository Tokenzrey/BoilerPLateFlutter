import 'package:boilerplate/core/domain/error/failures.dart';
import 'package:boilerplate/domain/repository/user/user_repository.dart';
import 'package:boilerplate/domain/usecase/auth/get_current_user_usecase.dart';
import 'package:fpdart/fpdart.dart';
import 'package:equatable/equatable.dart';

import '../../../core/domain/usecase/use_case.dart';

class UpdatePasswordParams extends Equatable {
  final String currentPassword;
  final String newPassword;

  const UpdatePasswordParams(
      {required this.currentPassword, required this.newPassword});

  @override
  List<Object?> get props => [currentPassword, newPassword];
}

class UpdatePasswordUseCase extends UnitUseCase<UpdatePasswordParams> {
  final UserRepository _userRepository;
  final GetCurrentUserUseCase _getCurrentUserUseCase;
  UpdatePasswordUseCase(this._userRepository, this._getCurrentUserUseCase);

  @override
  Future<Either<Failure, Unit>> execute(
      UpdatePasswordParams updatePasswordParams) async {
    final userResult = await _getCurrentUserUseCase.execute(NoParams());
    return userResult.fold(
      (failure) => left(failure),
      (user) async {
        if (user != null) {
          final updateResult = await _userRepository.updatePassword(
              user,
              updatePasswordParams.currentPassword,
              updatePasswordParams.newPassword);
          return updateResult.fold(
            (failure) => left(failure),
            (_) async {
              return right(unit);
            },
          );
        } else {
          return left(const AuthFailure('No active session found'));
        }
      },
    );
  }
}
