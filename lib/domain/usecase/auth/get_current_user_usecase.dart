import 'package:boilerplate/core/domain/error/failures.dart';
import 'package:boilerplate/domain/repository/auth/auth_repository.dart';
import 'package:boilerplate/domain/repository/user/user_repository.dart';
import 'package:boilerplate/domain/usecase/auth/refresh_token_usecase.dart';
import 'package:boilerplate/domain/usecase/user/logout_usecase.dart';
import 'package:fpdart/fpdart.dart';

import '../../../core/domain/usecase/use_case.dart';
import '../../entity/user/user.dart';

class GetCurrentUserUseCase extends NoParamsUseCase<User?> {
  final AuthRepository _authRepository;
  final UserRepository _userRepository;
  final LogoutUseCase _logoutUseCase;
  final RefreshTokenUseCase _refreshTokenUseCase;

  GetCurrentUserUseCase(
    this._authRepository,
    this._userRepository,
    this._logoutUseCase,
    this._refreshTokenUseCase,
  );

  @override
  Future<Either<Failure, User?>> execute(NoParams params) async {
    try {
      final currentUserResult = await _authRepository.getCurrentUser();

      return await currentUserResult.fold(
        (_) => _handleTokenRefresh(),

        (user) async {
          if (user != null) {
            return await _saveUserAndReturnSuccess(user);
          } else {
            return await _handleTokenRefresh();
          }
        },
      );
    } catch (e) {
      return await _handleFailureAndLogout(
          'Unexpected error getting current user: ${e.toString()}');
    }
  }

  Future<Either<Failure, User?>> _handleTokenRefresh() async {
    final refreshResult = await _refreshTokenUseCase.execute(NoParams());

    return await refreshResult.fold(
      (failure) async => await _handleFailureAndLogout(
          'Token refresh failed: ${failure.message}'),

      (_) async {
        final retryUserResult = await _authRepository.getCurrentUser();

        return await retryUserResult.fold(
          (failure) async => await _handleFailureAndLogout(
              'Failed to get user after token refresh: ${failure.message}'),

          (user) async {
            if (user == null) {
              return await _handleFailureAndLogout(
                  'User not found after token refresh');
            }
            return await _saveUserAndReturnSuccess(user);
          },
        );
      },
    );
  }

  Future<Either<Failure, User?>> _saveUserAndReturnSuccess(User user) async {
    await _userRepository.saveUserData(user);
    await _userRepository.saveIsLoggedIn(true);
    return right(user);
  }

  Future<Either<Failure, User?>> _handleFailureAndLogout(String message) async {
    await _logoutUseCase.execute(NoParams());
    return left(UnexpectedFailure(message));
  }
}
