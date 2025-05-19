import 'package:fpdart/fpdart.dart';
import 'package:boilerplate/core/domain/error/failures.dart';
import 'package:boilerplate/core/domain/usecase/use_case.dart';
import 'package:boilerplate/domain/entity/user/user.dart';
import 'package:boilerplate/domain/repository/auth/auth_firebase_repository.dart';

class RegisterParams {
  final String email;
  final String password;
  final String username;
  final String fullName;

  const RegisterParams({
    required this.email,
    required this.password,
    required this.username,
    required this.fullName,
  });

  @override
  String toString() {
    return 'RegisterParams(email: $email, username: $username, fullName: $fullName)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RegisterParams &&
        other.email == email &&
        other.password == password &&
        other.username == username &&
        other.fullName == fullName;
  }

  @override
  int get hashCode {
    return email.hashCode ^
        password.hashCode ^
        username.hashCode ^
        fullName.hashCode;
  }
}

class RegisterUseCase extends UseCase<User, RegisterParams> {
  final AuthFirebaseRepository repository;

  const RegisterUseCase(this.repository);

  @override
  Future<Either<Failure, User>> execute(RegisterParams params) {
    return repository.register(
      params.email,
      params.password,
      params.username,
      params.fullName,
    );
  }
}
