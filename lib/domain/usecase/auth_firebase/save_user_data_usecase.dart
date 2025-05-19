import 'package:fpdart/fpdart.dart';
import 'package:boilerplate/core/domain/error/failures.dart';
import 'package:boilerplate/core/domain/usecase/use_case.dart';
import 'package:boilerplate/domain/entity/user/user.dart';
import 'package:boilerplate/domain/repository/auth/auth_firebase_repository.dart';

class SaveUserDataParams {
  final User? userData;

  const SaveUserDataParams({this.userData});

  @override
  String toString() => 'SaveUserDataParams(userData: $userData)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SaveUserDataParams && other.userData == userData;
  }

  @override
  int get hashCode => userData.hashCode;
}

class SaveUserDataUseCase extends UnitUseCase<SaveUserDataParams> {
  final AuthFirebaseRepository repository;

  const SaveUserDataUseCase(this.repository);

  @override
  Future<Either<Failure, Unit>> execute(SaveUserDataParams params) async {
    return await repository.saveUserData(params.userData);
  }
}