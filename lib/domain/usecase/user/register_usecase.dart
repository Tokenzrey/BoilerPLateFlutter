import 'package:boilerplate/core/domain/error/failures.dart';
import 'package:boilerplate/core/domain/usecase/use_case.dart';
import 'package:boilerplate/domain/entity/user/user.dart';
import 'package:boilerplate/domain/repository/user/user_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';

class RegisterParams extends Equatable {
  final String email;
  final String username;
  final String password;
  final String fullName;

  const RegisterParams({
    required this.email,
    required this.username,
    required this.password,
    required this.fullName,
  });

  @override
  List<Object?> get props => [email, username, password, fullName];
}

class RegisterUseCase extends UseCase<User, RegisterParams> {
  final UserRepository _userRepository;

  RegisterUseCase(this._userRepository);

  @override
  Future<Either<Failure, User>> execute(RegisterParams params) async {
    return await _userRepository.register(params);
  }
}
