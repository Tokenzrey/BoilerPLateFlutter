import 'package:fpdart/fpdart.dart';
import 'package:boilerplate/core/domain/error/failures.dart';
import 'package:boilerplate/core/domain/usecase/use_case.dart';
import 'package:boilerplate/domain/entity/user/user.dart';
import 'package:boilerplate/domain/repository/auth/auth_firebase_repository.dart';

class LoginParams {
  final String email;
  final String password;

  const LoginParams({
    required this.email,
    required this.password,
  });

  @override
  String toString() => 'LoginParams(email: $email)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LoginParams &&
        other.email == email &&
        other.password == password;
  }

  @override
  int get hashCode => email.hashCode ^ password.hashCode;
}

class LoginUseCase extends UseCase<User, LoginParams> {
  final AuthFirebaseRepository repository;

  const LoginUseCase(this.repository);

  @override
  Future<Either<Failure, User>> execute(LoginParams params) {
    return repository.login(params.email, params.password);
  }
}
