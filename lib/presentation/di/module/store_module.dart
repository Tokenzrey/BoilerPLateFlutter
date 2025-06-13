import 'dart:async';

import 'package:boilerplate/core/stores/error/error_store.dart';
import 'package:boilerplate/core/stores/form/form_store.dart';
import 'package:boilerplate/domain/repository/setting/setting_repository.dart';

// Import dari auth_firebase dengan alias
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

// Import dari user dengan alias

import 'package:boilerplate/presentation/store/auth_firebase/auth_store.dart';
import 'package:boilerplate/presentation/store/language/language_store.dart';
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
  }
}
