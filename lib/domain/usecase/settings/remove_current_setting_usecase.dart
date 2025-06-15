import 'package:boilerplate/core/domain/error/failures.dart';
import 'package:boilerplate/core/domain/usecase/use_case.dart';
import 'package:boilerplate/domain/repository/user/setting_repository.dart';
import 'package:fpdart/fpdart.dart';

class RemoveCurrentSettingsUseCase extends NoParamsUseCase<Unit> {
  final SettingsRepository repository;
  const RemoveCurrentSettingsUseCase(this.repository);

  @override
  Future<Either<Failure, Unit>> execute(NoParams params) {
    return repository.removeCurrentSettings();
  }
}
