import 'package:boilerplate/core/domain/error/failures.dart';
import 'package:boilerplate/core/domain/usecase/use_case.dart';
import 'package:boilerplate/domain/entity/user/setting.dart';
import 'package:boilerplate/domain/repository/user/setting_repository.dart';
import 'package:fpdart/fpdart.dart';

class FindSettingsByIdParams {
  final String id;
  const FindSettingsByIdParams(this.id);
}

class FindSettingsByIdUseCase
    extends UseCase<SettingsEntity?, FindSettingsByIdParams> {
  final SettingsRepository repository;
  const FindSettingsByIdUseCase(this.repository);

  @override
  Future<Either<Failure, SettingsEntity?>> execute(
      FindSettingsByIdParams params) {
    return repository.findById(params.id);
  }
}
