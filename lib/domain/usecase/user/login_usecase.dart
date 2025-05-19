import 'package:boilerplate/core/domain/error/failures.dart';
import 'package:boilerplate/domain/repository/auth/auth_repository.dart';
import 'package:boilerplate/domain/repository/user/user_repository.dart';
import 'package:fpdart/fpdart.dart';

import '../../../core/domain/usecase/use_case.dart';
import '../../entity/user/user.dart';
import 'package:equatable/equatable.dart';

class LoginParams extends Equatable {
  final String email;
  final String password;

  const LoginParams({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

class LoginUseCase extends UseCase<User, LoginParams> {
  final UserRepository _userRepository;
  final AuthRepository _authRepository;

  LoginUseCase(this._userRepository, this._authRepository);

  @override
  Future<Either<Failure, User>> execute(LoginParams params) async {
    final loginResult = await _userRepository.login(params);

    return loginResult.fold(
      (failure) => left(failure),
      (user) async {
        final saveUserResult = await _userRepository.saveUserData(user);

        if (saveUserResult.isLeft()) {
          return saveUserResult.fold(
            (failure) => left(failure),
            (_) => right(user),
          );
        }

        final tokenResult = await _authRepository.generateToken(user);

        if (tokenResult.isLeft()) {
          return tokenResult.fold(
            (failure) => left(failure),
            (_) => right(user),
          );
        }

        final token = tokenResult.getRight().toNullable()!;
        final saveTokenResult = await _authRepository.saveToken(token);

        if (saveTokenResult.isLeft()) {
          return saveTokenResult.fold(
            (failure) => left(failure),
            (_) => right(user),
          );
        }

        final loginStatusResult = await _userRepository.saveIsLoggedIn(true);
        return loginStatusResult.fold(
          (failure) => left(failure),
          (_) => right(user),
        );
      },
    );
  }
}
