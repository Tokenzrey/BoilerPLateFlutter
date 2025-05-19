import 'package:boilerplate/core/domain/error/failures.dart';
import 'package:boilerplate/domain/repository/auth/auth_repository.dart';
import 'package:boilerplate/domain/usecase/user/logout_usecase.dart';
import 'package:fpdart/fpdart.dart';

import '../../../core/domain/usecase/use_case.dart';

class RefreshTokenUseCase extends NoParamsUnitUseCase {
  final AuthRepository _authRepository;
  final LogoutUseCase _logoutUseCase;

  RefreshTokenUseCase(
    this._authRepository,
    this._logoutUseCase,
  );

  @override
  Future<Either<Failure, Unit>> execute(NoParams params) async {
    try {
      final tokenEither = await _authRepository.getCurrentToken();

      return await tokenEither.fold(
        (failure) async {
          await _logoutUseCase.execute(NoParams());
          return left(AuthFailure('No valid token found: ${failure.message}'));
        },
        (token) async {
          if (token == null || token.refreshToken.isEmpty) {
            await _logoutUseCase.execute(NoParams());
            return left(const AuthFailure('No active session found'));
          }

          final refreshResult =
              await _authRepository.refreshToken(token.refreshToken);

          return await refreshResult.fold(
            (failure) async {
              await _logoutUseCase.execute(NoParams());
              return left(
                  AuthFailure('Token refresh failed: ${failure.message}'));
            },
            (newToken) async {
              final saveTokenResult = await _authRepository.saveToken(newToken);

              if (saveTokenResult.isLeft()) {
                await _logoutUseCase.execute(NoParams());
                return left(
                    const AuthFailure('Failed to save refreshed token'));
              }
              return right(unit);
            },
          );
        },
      );
    } catch (e) {
      await _logoutUseCase.execute(NoParams());
      return left(UnexpectedFailure('Refresh token error: ${e.toString()}'));
    }
  }
}
