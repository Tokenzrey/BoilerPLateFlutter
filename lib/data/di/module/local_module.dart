import 'dart:async';
import 'package:boilerplate/data/local/datasources/auth/auth_firebase_datasource.dart';
import 'package:boilerplate/data/local/datasources/comic/comic_datasource.dart';
import 'package:boilerplate/data/local/datasources/user/setting_datasource.dart';
import 'package:boilerplate/data/local/models/comic_followed_model.dart';
import 'package:boilerplate/data/local/models/settings_model.dart';
import 'package:boilerplate/domain/repository/user/user_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
    await _configureStorageServices();
    await _configurePreferences();
    await _configureHiveDatabase();
    await _registerBusinessServices();
    await _registerDataSources();
  }

  static Future<void> _configureStorageServices() async {
    getIt.registerLazySingleton(() => const FlutterSecureStorage());
  }

  static Future<void> _configurePreferences() async {
    getIt.registerSingletonAsync<SharedPreferences>(
      SharedPreferences.getInstance,
    );

    final prefs = await getIt.getAsync<SharedPreferences>();
    getIt.registerSingleton<SharedPreferenceHelper>(
      SharedPreferenceHelper(prefs),
    );
  }

  static Future<void> _configureHiveDatabase() async {
    getIt.registerLazySingleton(
      () => HiveEncryption(secureStorage: getIt<FlutterSecureStorage>()),
    );

    getIt.registerLazySingleton<DatabaseConfig>(
      () => DatabaseConfig.defaultConfig().copyWith(
        recoveryStrategy: RecoveryStrategy.deleteBoxIfCorrupted,
        clearDatabaseOnInit: false,
        maxRecoveryAttempts: 3,
      ),
    );

    getIt.registerLazySingleton<DatabaseService>(() => HiveService(
          encryption: getIt<HiveEncryption>(),
          config: getIt<DatabaseConfig>(),
        ));

    await getIt<DatabaseService>().init();

    getIt<DatabaseService>().registerAdapter(UserModelAdapter());
    getIt<DatabaseService>().registerAdapter(SettingsModelAdapter());
    getIt<DatabaseService>().registerAdapter(FollowedComicAdapter());
  }

  static Future<void> _registerDataSources() async {
    Box<UserModel>? userBox;
    try {
      userBox = await getIt<DatabaseService>().openBox<UserModel>('users_box');
    } catch (e) {
      try {
        await Hive.deleteBoxFromDisk('users_box');
        userBox =
            await getIt<DatabaseService>().openBox<UserModel>('users_box');
      } catch (secondError) {
        final databaseService = getIt<DatabaseService>();
        if (databaseService is HiveService) {
          await databaseService.forceRecoveryAndOpen<UserModel>('users_box');
          userBox = await databaseService.openBox<UserModel>('users_box');
        }
      }
    }

    Box<SettingsModel>? settingsBox;
    try {
      settingsBox =
          await getIt<DatabaseService>().openBox<SettingsModel>('settings_box');
    } catch (e) {
      try {
        await Hive.deleteBoxFromDisk('settings_box');
        settingsBox = await getIt<DatabaseService>()
            .openBox<SettingsModel>('settings_box');
      } catch (secondError) {
        final databaseService = getIt<DatabaseService>();
        if (databaseService is HiveService) {
          await databaseService
              .forceRecoveryAndOpen<SettingsModel>('settings_box');
          settingsBox =
              await databaseService.openBox<SettingsModel>('settings_box');
        }
      }
    }

    Box<FollowedComic>? fcBox;
    try {
      fcBox = await getIt<DatabaseService>().openBox<FollowedComic>('fc_box');
    } catch (e) {
      try {
        await Hive.deleteBoxFromDisk('fc_box');
        fcBox =
        await getIt<DatabaseService>().openBox<FollowedComic>('fc_box');
      } catch (secondError) {
        final databaseService = getIt<DatabaseService>();
        if (databaseService is HiveService) {
          await databaseService.forceRecoveryAndOpen<FollowedComic>('fc_box');
          fcBox = await databaseService.openBox<FollowedComic>('fc_box');
        }
      }
    }

    getIt.registerLazySingleton(() => UserLocalDataSource(userBox!));
    getIt.registerLazySingleton(() => SettingLocalDataSource(settingsBox!));
    getIt.registerLazySingleton(() => FollowedComicLocalDataSource(fcBox!));

    getIt.registerLazySingleton(() => AuthLocalDataSource(
          getIt<FlutterSecureStorage>(),
        ));
    getIt.registerLazySingleton(() => AuthFirebaseDataSource(
          firebaseAuth: getIt<FirebaseAuth>(),
          firestore: getIt<FirebaseFirestore>(),
        ));
  }

  static Future<void> _registerBusinessServices() async {
    getIt.registerLazySingleton(() => JwtService(
          getIt<FlutterSecureStorage>(),
          getIt<UserRepository>(),
          enableLogging: true,
        ));
  }
}
