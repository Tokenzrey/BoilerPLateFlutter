import 'package:fpdart/fpdart.dart';
import 'package:boilerplate/core/domain/error/failures.dart';
import 'package:boilerplate/core/domain/usecase/use_case.dart';
import 'package:boilerplate/domain/repository/auth/auth_firebase_repository.dart';

class DeleteAccountParams {
  final String password;

  const DeleteAccountParams({
    required this.password,
  });

  @override
  String toString() {
    return 'DeleteAccountParams(password: ****)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DeleteAccountParams && other.password == password;
  }

  @override
  int get hashCode => password.hashCode;
}

class DeleteAccountUseCase extends UseCase<void, DeleteAccountParams> {
  final AuthFirebaseRepository repository;

  const DeleteAccountUseCase(this.repository);

  @override
  Future<Either<Failure, void>> execute(DeleteAccountParams params) {
    return repository.deleteAccount(params.password);
  }
}

class DeleteAccountByIdParams {
  final String uid;

  const DeleteAccountByIdParams({
    required this.uid,
  });

  @override
  String toString() {
    return 'DeleteAccountByIdParams(uid: $uid)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DeleteAccountByIdParams && other.uid == uid;
  }

  @override
  int get hashCode => uid.hashCode;
}

class DeleteAccountByIdUseCase extends UseCase<void, DeleteAccountByIdParams> {
  final AuthFirebaseRepository repository;

  const DeleteAccountByIdUseCase(this.repository);

  @override
  Future<Either<Failure, void>> execute(DeleteAccountByIdParams params) {
    return repository.deleteAccountById(params.uid);
  }
}
