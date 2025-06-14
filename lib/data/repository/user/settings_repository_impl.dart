import 'package:boilerplate/core/domain/error/failures.dart';
import 'package:boilerplate/data/local/datasources/user/setting_datasource.dart';
import 'package:boilerplate/data/local/models/settings_model.dart';
import 'package:boilerplate/data/sharedpref/shared_preference_helper.dart';
import 'package:boilerplate/domain/entity/user/setting.dart';
import 'package:boilerplate/domain/repository/user/setting_repository.dart';
import 'package:fpdart/fpdart.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final SettingLocalDataSource localDataSource;
  final SharedPreferenceHelper sharedPrefsHelper;

  SettingsRepositoryImpl({
    required this.localDataSource,
    required this.sharedPrefsHelper,
  });

  @override
  Future<Either<Failure, Unit>> saveSettings(SettingsEntity settings) async {
    try {
      final model = SettingsModelX.fromEntity(settings);
      await localDataSource.saveSettings(model);
      return right(unit);
    } catch (e) {
      return left(CacheFailure('Failed to save settings: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<SettingsEntity>>> getAllSettings() async {
    try {
      final models = await localDataSource.getAllSettings();
      final entities = models.map((m) => m.toEntity()).toList();
      return right(entities);
    } catch (e) {
      return left(CacheFailure('Failed to get all settings: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, SettingsEntity?>> findById(String id) async {
    try {
      final model = await localDataSource.findById(id);
      return right(model?.toEntity());
    } catch (e) {
      return left(CacheFailure('Failed to find settings: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteById(String id) async {
    try {
      await localDataSource.deleteById(id);
      return right(unit);
    } catch (e) {
      return left(CacheFailure('Failed to delete settings: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Unit>> clearAll() async {
    try {
      await localDataSource.clearAll();
      return right(unit);
    } catch (e) {
      return left(
          CacheFailure('Failed to clear all settings: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Unit>> saveCurrentSettings(
      SettingsEntity settings) async {
    try {
      final model = SettingsModelX.fromEntity(settings);
      await sharedPrefsHelper.saveCurrentSettings(model);
      return right(unit);
    } catch (e) {
      return left(
          CacheFailure('Failed to save current settings: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, SettingsEntity?>> getCurrentSettings() async {
    try {
      final model = await sharedPrefsHelper.getCurrentSettings();
      return right(model?.toEntity());
    } catch (e) {
      return left(
          CacheFailure('Failed to get current settings: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Unit>> removeCurrentSettings() async {
    try {
      await sharedPrefsHelper.removeCurrentSettings();
      return right(unit);
    } catch (e) {
      return left(
          CacheFailure('Failed to remove current settings: ${e.toString()}'));
    }
  }
}
