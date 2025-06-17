import 'package:fpdart/fpdart.dart';
import 'package:boilerplate/core/domain/error/failures.dart';
import 'package:boilerplate/core/domain/usecase/use_case.dart';
import 'package:boilerplate/domain/entity/user/user.dart';
import 'package:boilerplate/domain/repository/auth/auth_firebase_repository.dart';

class UpdateUserDataParams {
  final String fullName;
  final String username;
  final String avatar;

  const UpdateUserDataParams({
    required this.fullName,
    required this.username,
    required this.avatar,
  });

  @override
  String toString() {
    return 'UpdateUserDataParams(fullName: $fullName, username: $username, avatar: $avatar)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UpdateUserDataParams &&
        other.fullName == fullName &&
        other.username == username &&
        other.avatar == avatar;
  }

  @override
  int get hashCode {
    return fullName.hashCode ^ username.hashCode ^ avatar.hashCode;
  }
}

class UpdateUserUseCase extends UseCase<User, UpdateUserDataParams> {
  final AuthFirebaseRepository repository;

  const UpdateUserUseCase(this.repository);

  @override
  Future<Either<Failure, User>> execute(UpdateUserDataParams params) {
    return repository.updateUserData(
      params.fullName,
      params.username,
      params.avatar,
    );
  }
}
