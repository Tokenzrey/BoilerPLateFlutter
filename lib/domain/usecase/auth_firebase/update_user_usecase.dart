import 'package:fpdart/fpdart.dart';
import 'package:boilerplate/core/domain/error/failures.dart';
import 'package:boilerplate/core/domain/usecase/use_case.dart';
import 'package:boilerplate/domain/entity/user/user.dart';
import 'package:boilerplate/domain/repository/auth/auth_firebase_repository.dart';

class UpdateUserDataParams {
  final String fullName;
  final String username;
  final String? photoUrl;

  const UpdateUserDataParams({
    required this.fullName,
    required this.username,
    this.photoUrl,
  });

  @override
  String toString() {
    return 'UpdateUserDataParams(fullName: $fullName, username: $username, photoUrl: $photoUrl)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UpdateUserDataParams &&
        other.fullName == fullName &&
        other.username == username &&
        other.photoUrl == photoUrl;
  }

  @override
  int get hashCode {
    return fullName.hashCode ^ username.hashCode ^ photoUrl.hashCode;
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
      params.photoUrl,
    );
  }
}
