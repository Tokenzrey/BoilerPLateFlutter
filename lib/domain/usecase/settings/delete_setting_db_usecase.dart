import 'package:boilerplate/core/domain/error/failures.dart';
import 'package:boilerplate/core/domain/usecase/use_case.dart';
import 'package:boilerplate/domain/repository/user/setting_repository.dart';
import 'package:fpdart/fpdart.dart';

class DeleteSettingsByIdParams {
  final String id;
  const DeleteSettingsByIdParams(this.id);
}

class DeleteSettingsByIdUseCase
    extends UseCase<Unit, DeleteSettingsByIdParams> {
  final SettingsRepository repository;
  const DeleteSettingsByIdUseCase(this.repository);

  @override
  Future<Either<Failure, Unit>> execute(DeleteSettingsByIdParams params) {
    return repository.deleteById(params.id);
  }
}
