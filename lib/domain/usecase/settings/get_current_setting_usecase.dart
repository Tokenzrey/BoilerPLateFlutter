import 'package:boilerplate/core/domain/error/failures.dart';
import 'package:boilerplate/core/domain/usecase/use_case.dart';
import 'package:boilerplate/domain/entity/user/setting.dart';
import 'package:boilerplate/domain/repository/user/setting_repository.dart';
import 'package:fpdart/fpdart.dart';

class GetCurrentSettingsUseCase extends NoParamsUseCase<SettingsEntity?> {
  final SettingsRepository repository;
  const GetCurrentSettingsUseCase(this.repository);

  @override
  Future<Either<Failure, SettingsEntity?>> execute(NoParams params) {
    return repository.getCurrentSettings();
  }
}
