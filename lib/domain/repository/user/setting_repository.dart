import 'package:boilerplate/core/domain/error/failures.dart';
import 'package:boilerplate/domain/entity/user/setting.dart';
import 'package:fpdart/fpdart.dart';

abstract class SettingsRepository {
  /// Save or update settings
  Future<Either<Failure, Unit>> saveSettings(SettingsEntity settings);

  /// Get all settings
  Future<Either<Failure, List<SettingsEntity>>> getAllSettings();

  /// Find settings by ID
  Future<Either<Failure, SettingsEntity?>> findById(String id);

  /// Delete settings by ID
  Future<Either<Failure, Unit>> deleteById(String id);

  /// Delete all settings
  Future<Either<Failure, Unit>> clearAll();

  /// Save or update currently active settings (SharedPreferences)
  Future<Either<Failure, Unit>> saveCurrentSettings(SettingsEntity settings);

  /// Get currently active settings (SharedPreferences)
  Future<Either<Failure, SettingsEntity?>> getCurrentSettings();

  /// Remove currently active settings (SharedPreferences)
  Future<Either<Failure, Unit>> removeCurrentSettings();
}
