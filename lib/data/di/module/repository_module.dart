import 'dart:async';

import 'package:boilerplate/core/data/jwt/jwt_service.dart';
import 'package:boilerplate/data/local/datasources/auth/auth_datasource.dart';
import 'package:boilerplate/data/local/datasources/auth/auth_firebase_datasource.dart';
import 'package:boilerplate/data/local/datasources/history/history_datasource.dart';
import 'package:boilerplate/data/local/datasources/user/setting_datasource.dart';
import 'package:boilerplate/data/local/datasources/user/user_datasource.dart';
import 'package:boilerplate/data/network/api/chapter_top_service.dart';
import 'package:boilerplate/data/network/api/get_comic_chapters.dart';
import 'package:boilerplate/data/network/api/get_comic_details.dart';
import 'package:boilerplate/data/network/api/top_api_service.dart';
import 'package:boilerplate/data/repository/api/comic_details_impl.dart';
import 'package:boilerplate/data/repository/api/home_impl.dart';
import 'package:boilerplate/data/repository/auth/auth_firebase_repository_impl.dart';
import 'package:boilerplate/data/repository/auth/auth_repository_impl.dart';
import 'package:boilerplate/data/repository/setting/setting_repository_impl.dart';
import 'package:boilerplate/data/repository/history/history_repository_impl.dart';
import 'package:boilerplate/data/repository/user/settings_repository_impl.dart';
import 'package:boilerplate/data/repository/user/user_repository_impl.dart';
import 'package:boilerplate/data/sharedpref/shared_preference_helper.dart';
import 'package:boilerplate/domain/repository/api/comic_details_repository.dart';
import 'package:boilerplate/domain/repository/api/home_repository.dart';
import 'package:boilerplate/domain/repository/auth/auth_firebase_repository.dart';
import 'package:boilerplate/domain/repository/auth/auth_repository.dart';
import 'package:boilerplate/domain/repository/setting/setting_repository.dart';
import 'package:boilerplate/domain/repository/history/history_repository.dart';
import 'package:boilerplate/domain/repository/user/setting_repository.dart';
import 'package:boilerplate/domain/repository/user/user_repository.dart';

import '../../../di/service_locator.dart';

class RepositoryModule {
  static Future<void> configureRepositoryModuleInjection() async {
    getIt.registerSingleton<SettingRepository>(SettingRepositoryImpl(
      getIt<SharedPreferenceHelper>(),
    ));

    getIt.registerSingleton<UserRepository>(
      UserRepositoryImpl(
        userLocalDataSource: getIt<UserLocalDataSource>(),
        sharedPrefsHelper: getIt<SharedPreferenceHelper>(),
      ),
    );

    getIt.registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(
        authLocalDataSource: getIt<AuthLocalDataSource>(),
        userLocalDataSource: getIt<UserLocalDataSource>(),
        jwtService: getIt<JwtService>(),
      ),
    );

    getIt.registerLazySingleton<AuthFirebaseRepository>(
      () => AuthFirebaseRepositoryImpl(
        dataSource: getIt<AuthFirebaseDataSource>(),
        sharedPrefsHelper: getIt<SharedPreferenceHelper>(),
      ),
    );

    getIt.registerLazySingleton<HomeRepository>(
      () => HomeRepositoryImpl(
        chapterApiService: getIt<ChapterApiService>(),
        topApiService: getIt<TopApiService>(),
      ),
    );

    getIt.registerSingleton<SettingsRepository>(
      SettingsRepositoryImpl(
        localDataSource: getIt<SettingLocalDataSource>(),
        sharedPrefsHelper: getIt<SharedPreferenceHelper>(),
      ),
    );

    getIt.registerSingleton<ComicDetailsRepository>(
      ComicDetailsRepositoryImpl(
        comicDetailApiService: getIt<ComicDetailApiService>(),
        chapterDetailApiService: getIt<ChapterDetailApiService>(),
      ),
    );

    getIt.registerSingleton<HistoryRepository>(
      HistoryRepositoryImpl(
        localDataSource: getIt<HistoryLocalDataSource>(),
      ),
    );
  }
}
