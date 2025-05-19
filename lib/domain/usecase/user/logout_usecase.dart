import 'package:boilerplate/core/domain/usecase/use_case.dart';
import 'package:boilerplate/domain/repository/auth/auth_repository.dart';
import 'package:boilerplate/domain/repository/user/user_repository.dart';
import 'package:fpdart/fpdart.dart';

import '../../../core/domain/error/failures.dart';

/// Use case for handling the logout process.
///
/// Handles clearing authentication tokens, user data, and user login state.
/// Returns success [Unit] or a [Failure] if any step fails.
class LogoutUseCase extends NoParamsUnitUseCase {
  final AuthRepository _authRepository;
  final UserRepository _userRepository;

  LogoutUseCase(this._authRepository, this._userRepository);

  @override
  Future<Either<Failure, Unit>> execute(NoParams params) async {
    try {
      final tokenResult = await _authRepository.clearToken();
      if (tokenResult.isLeft()) {
        return tokenResult;
      }

      final userResult = await _userRepository.saveUserData(null);
      if (userResult.isLeft()) {
        return userResult;
      }

      return await _userRepository.saveIsLoggedIn(false);
    } catch (e) {
      return left(UnexpectedFailure('Logout failed: ${e.toString()}'));
    }
  }
}
