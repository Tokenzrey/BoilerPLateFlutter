import 'dart:async';

import 'package:boilerplate/core/stores/error/error_store.dart';
import 'package:boilerplate/core/stores/form/form_store.dart';
import 'package:boilerplate/domain/repository/setting/setting_repository.dart';
import 'package:boilerplate/domain/usecase/api/chapter_top_usecase.dart';
import 'package:boilerplate/domain/usecase/api/top_api_usecase.dart';

import 'package:boilerplate/domain/usecase/auth_firebase/register_usecase.dart';
import 'package:boilerplate/domain/usecase/auth_firebase/login_usecase.dart'
    as firebase_auth;
import 'package:boilerplate/domain/usecase/auth_firebase/logout_usecase.dart'
    as firebase_auth;
import 'package:boilerplate/domain/usecase/auth_firebase/save_is_logged_in_usecase.dart';
import 'package:boilerplate/domain/usecase/auth_firebase/save_user_data_usecase.dart';
import 'package:boilerplate/domain/usecase/auth_firebase/update_password_usecase.dart';
import 'package:boilerplate/domain/usecase/auth_firebase/update_user_usecase.dart';
import 'package:boilerplate/domain/usecase/auth_firebase/get_is_logged_in_usecase.dart'
    as firebase_auth;
import 'package:boilerplate/domain/usecase/auth_firebase/get_current_user_usecase.dart'
    as firebase_auth;
import 'package:boilerplate/domain/usecase/settings/delete_setting_db_usecase.dart';
import 'package:boilerplate/domain/usecase/settings/find_setting_db_usecase.dart';
import 'package:boilerplate/domain/usecase/settings/get_current_setting_usecase.dart';
import 'package:boilerplate/domain/usecase/settings/remove_current_setting_usecase.dart';
import 'package:boilerplate/domain/usecase/settings/save_current_setting_usecase.dart';
import 'package:boilerplate/domain/usecase/settings/save_setting_db_usecase.dart';

import 'package:boilerplate/presentation/store/auth_firebase/auth_store.dart';
import 'package:boilerplate/presentation/store/home/home_store.dart';
import 'package:boilerplate/presentation/store/language/language_store.dart';
import 'package:boilerplate/presentation/store/settings/settings_store.dart';
import 'package:boilerplate/presentation/store/theme/theme_store.dart';

import '../../../di/service_locator.dart';

class StoreModule {
  static Future<void> configureStoreModuleInjection() async {
    // factories:---------------------------------------------------------------
    getIt.registerFactory(() => ErrorStore());
    getIt.registerFactory(() => FormErrorStore());
    getIt.registerFactory(
      () => FormStore(getIt<FormErrorStore>(), getIt<ErrorStore>()),
    );

    // stores:------------------------------------------------------------------
    getIt.registerSingleton<AuthStore>(
      AuthStore(
        getIt<RegisterUseCase>(),
        getIt<firebase_auth.LoginUseCase>(),
        getIt<firebase_auth.LogoutUseCase>(),
        getIt<firebase_auth.IsLoggedInUseCase>(),
        getIt<UpdateUserUseCase>(),
        getIt<UpdatePasswordUseCase>(),
        getIt<firebase_auth.GetCurrentUserUseCase>(),
        getIt<SaveUserDataUseCase>(),
        getIt<SaveLoginStatusUseCase>(),
        getIt<FormErrorStore>(),
        getIt<ErrorStore>(),
      ),
    );
    getIt.registerSingleton<ThemeStore>(
      ThemeStore(
        getIt<SettingRepository>(),
        getIt<ErrorStore>(),
      ),
    );
    getIt.registerSingleton<LanguageStore>(
      LanguageStore(
        getIt<SettingRepository>(),
        getIt<ErrorStore>(),
      ),
    );

    getIt.registerSingleton<SettingsStore>(
      SettingsStore(
        authStore: getIt<AuthStore>(),
        getCurrentSettingsUseCase: getIt<GetCurrentSettingsUseCase>(),
        findSettingsByIdUseCase: getIt<FindSettingsByIdUseCase>(),
        saveSettingsUseCase: getIt<SaveSettingsUseCase>(),
        saveCurrentSettingsUseCase: getIt<SaveCurrentSettingsUseCase>(),
        deleteByIdUseCase: getIt<DeleteSettingsByIdUseCase>(),
        removeCurrentSettingsUseCase: getIt<RemoveCurrentSettingsUseCase>(),
      ),
    );

    getIt.registerSingleton<HomeStore>(
      HomeStore(
        getIt<TopApiUseCase>(),
        getIt<LatestChaptersUseCase>(),
        getIt<SettingsStore>(),
      ),
    );
  }
}
