import 'package:boilerplate/core/domain/error/failures.dart';
import 'package:boilerplate/domain/entity/user/user.dart';
import 'package:boilerplate/domain/repository/user/user_repository.dart';
import 'package:boilerplate/domain/usecase/auth/get_current_user_usecase.dart';
import 'package:fpdart/fpdart.dart';

import '../../../core/domain/usecase/use_case.dart';

class UpdateUserUseCase extends UseCase<User, User> {
  final UserRepository _userRepository;
  final GetCurrentUserUseCase _getCurrentUserUseCase;
  UpdateUserUseCase(this._userRepository, this._getCurrentUserUseCase);

  @override
  Future<Either<Failure, User>> execute(User user) async {
    final userResult = await _getCurrentUserUseCase.execute(NoParams());
    return userResult.fold(
      (failure) => left(failure),
      (currentUser) async {
        if (currentUser != null &&
            currentUser.id == user.id &&
            currentUser.email == user.email &&
            currentUser.username == user.username) {
          final updateResult = await _userRepository.updateUser(user);
          return updateResult.fold(
            (failure) => left(failure),
            (updatedUser) async {
              return right(updatedUser);
            },
          );
        } else {
          return left(const AuthFailure('No active session found'));
        }
      },
    );
  }
}
