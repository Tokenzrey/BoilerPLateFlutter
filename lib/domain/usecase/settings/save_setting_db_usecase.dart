import 'package:boilerplate/core/domain/error/failures.dart';
import 'package:boilerplate/core/domain/usecase/use_case.dart';
import 'package:boilerplate/domain/entity/user/setting.dart';
import 'package:boilerplate/domain/repository/user/setting_repository.dart';
import 'package:fpdart/fpdart.dart';

class SaveSettingsUseCase extends UseCase<Unit, SettingsEntity> {
  final SettingsRepository repository;
  const SaveSettingsUseCase(this.repository);

  @override
  Future<Either<Failure, Unit>> execute(SettingsEntity params) {
    return repository.saveSettings(params);
  }
}
