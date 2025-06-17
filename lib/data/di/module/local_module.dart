import 'dart:async';
import 'package:boilerplate/data/local/datasources/auth/auth_firebase_datasource.dart';
import 'package:boilerplate/data/local/datasources/user/setting_datasource.dart';
import 'package:boilerplate/data/local/models/settings_model.dart';
import 'package:boilerplate/domain/repository/user/user_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart'; // <-- Tambahkan untuk debugPrint
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:boilerplate/core/data/jwt/jwt_service.dart';
import 'package:boilerplate/core/data/local/hive/config/database_config.dart';
import 'package:boilerplate/core/data/local/hive/config/database_service.dart';
import 'package:boilerplate/core/data/local/hive/hive_encryption.dart';
import 'package:boilerplate/core/data/local/hive/hive_service.dart';
import 'package:boilerplate/data/local/datasources/auth/auth_datasource.dart';
import 'package:boilerplate/data/local/datasources/user/user_datasource.dart';
import 'package:boilerplate/data/local/models/user_model.dart';
import 'package:boilerplate/data/sharedpref/shared_preference_helper.dart';
import '../../../di/service_locator.dart';

class LocalModule {
  static Future<void> configureLocalModuleInjection() async {
    debugPrint('[LocalModule] Starting DI configuration...');
    await _configureStorageServices();
    await _configurePreferences();
    await _configureHiveDatabase();
    await _registerBusinessServices();
    await _registerDataSources();
    debugPrint('[LocalModule] DI configuration complete.');
  }

  static Future<void> _configureStorageServices() async {
    debugPrint('[LocalModule] Registering FlutterSecureStorage...');
    getIt.registerLazySingleton(() => const FlutterSecureStorage());
    debugPrint('[LocalModule] FlutterSecureStorage registered.');
  }

  static Future<void> _configurePreferences() async {
    debugPrint('[LocalModule] Registering SharedPreferences...');
    getIt.registerSingletonAsync<SharedPreferences>(
      SharedPreferences.getInstance,
    );

    final prefs = await getIt.getAsync<SharedPreferences>();
    getIt.registerSingleton<SharedPreferenceHelper>(
      SharedPreferenceHelper(prefs),
    );
    debugPrint('[LocalModule] SharedPreferences registered.');
  }

  static Future<void> _configureHiveDatabase() async {
    debugPrint('[LocalModule] Configuring HiveDatabase & adapters...');
    getIt.registerLazySingleton(
      () => HiveEncryption(secureStorage: getIt<FlutterSecureStorage>()),
    );
    debugPrint('[LocalModule] HiveEncryption registered.');

    getIt.registerLazySingleton<DatabaseConfig>(
      () => DatabaseConfig.defaultConfig().copyWith(
        recoveryStrategy: RecoveryStrategy.deleteBoxIfCorrupted,
        clearDatabaseOnInit: false,
        maxRecoveryAttempts: 10,
        lazyBoxMode: false,
      ),
    );
    debugPrint('[LocalModule] DatabaseConfig registered.');

    getIt.registerLazySingleton<DatabaseService>(() => HiveService(
          encryption: getIt<HiveEncryption>(),
          config: getIt<DatabaseConfig>(),
        ));

    await getIt<DatabaseService>().init();
    debugPrint('[LocalModule] DatabaseService (Hive) initialized.');

    getIt<DatabaseService>().registerAdapter<UserModel>(UserModelAdapter());
    getIt<DatabaseService>()
        .registerAdapter<SettingsModel>(SettingsModelAdapter());
    debugPrint(
        '[LocalModule] Hive adapters for UserModel and SettingsModel registered.');
  }

  static Future<void> _registerDataSources() async {
    debugPrint('[LocalModule] Registering Hive data sources...');
    Box<UserModel>? userBox;
    try {
      userBox = await getIt<DatabaseService>().openBox<UserModel>('users_box');
      debugPrint('[LocalModule] users_box opened (normal).');
    } catch (e) {
      debugPrint(
          '[LocalModule] Error opening users_box: $e. Trying recovery...');
      try {
        await Hive.deleteBoxFromDisk('users_box');
        userBox =
            await getIt<DatabaseService>().openBox<UserModel>('users_box');
        debugPrint('[LocalModule] users_box recovered by deleteBoxFromDisk.');
      } catch (secondError) {
        debugPrint(
            '[LocalModule] Second error opening users_box: $secondError. Forcing recovery...');
        final databaseService = getIt<DatabaseService>();
        if (databaseService is HiveService) {
          await databaseService.forceRecoveryAndOpen<UserModel>('users_box');
          userBox = await databaseService.openBox<UserModel>('users_box');
          debugPrint(
              '[LocalModule] users_box recovered by forceRecoveryAndOpen.');
        }
      }
    }

    Box<SettingsModel>? settingsBox;
    try {
      settingsBox =
          await getIt<DatabaseService>().openBox<SettingsModel>('settings_box');
      debugPrint('[LocalModule] settings_box opened (normal).');
    } catch (e) {
      debugPrint(
          '[LocalModule] Error opening settings_box: $e. Trying recovery...');
      try {
        await Hive.deleteBoxFromDisk('settings_box');
        settingsBox = await getIt<DatabaseService>()
            .openBox<SettingsModel>('settings_box');
        debugPrint(
            '[LocalModule] settings_box recovered by deleteBoxFromDisk.');
      } catch (secondError) {
        debugPrint(
            '[LocalModule] Second error opening settings_box: $secondError. Forcing recovery...');
        final databaseService = getIt<DatabaseService>();
        if (databaseService is HiveService) {
          await databaseService
              .forceRecoveryAndOpen<SettingsModel>('settings_box');
          settingsBox =
              await databaseService.openBox<SettingsModel>('settings_box');
          debugPrint(
              '[LocalModule] settings_box recovered by forceRecoveryAndOpen.');
        }
      }
    }

    getIt.registerLazySingleton(() => UserLocalDataSource(userBox!));
    getIt.registerLazySingleton(() => SettingLocalDataSource(settingsBox!));
    debugPrint('[LocalModule] Local data sources registered.');

    getIt.registerLazySingleton(() => AuthLocalDataSource(
          getIt<FlutterSecureStorage>(),
        ));
    getIt.registerLazySingleton(() => AuthFirebaseDataSource(
          firebaseAuth: getIt<FirebaseAuth>(),
          firestore: getIt<FirebaseFirestore>(),
        ));
    debugPrint('[LocalModule] Auth data sources registered.');
  }

  static Future<void> _registerBusinessServices() async {
    debugPrint('[LocalModule] Registering JwtService...');
    getIt.registerLazySingleton(() => JwtService(
          getIt<FlutterSecureStorage>(),
          getIt<UserRepository>(),
          enableLogging: true,
        ));
    debugPrint('[LocalModule] JwtService registered.');
  }
}
