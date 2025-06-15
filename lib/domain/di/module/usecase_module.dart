import 'dart:async';

import 'package:boilerplate/domain/repository/api/home_repository.dart';
import 'package:boilerplate/domain/repository/auth/auth_firebase_repository.dart';
import 'package:boilerplate/domain/repository/user/setting_repository.dart';
import 'package:boilerplate/domain/repository/user/user_repository.dart';
import 'package:boilerplate/domain/repository/auth/auth_repository.dart';
import 'package:boilerplate/domain/usecase/api/top_api_usecase.dart';
import 'package:boilerplate/domain/usecase/auth_firebase/get_current_user_usecase.dart';
import 'package:boilerplate/domain/usecase/auth_firebase/get_is_logged_in_usecase.dart';
import 'package:boilerplate/domain/usecase/auth_firebase/login_usecase.dart';
import 'package:boilerplate/domain/usecase/auth_firebase/logout_usecase.dart';
import 'package:boilerplate/domain/usecase/auth_firebase/register_usecase.dart';
import 'package:boilerplate/domain/usecase/auth_firebase/save_is_logged_in_usecase.dart';
import 'package:boilerplate/domain/usecase/auth_firebase/save_user_data_usecase.dart';
import 'package:boilerplate/domain/usecase/auth_firebase/update_password_usecase.dart';
import 'package:boilerplate/domain/usecase/auth_firebase/update_user_usecase.dart';
import 'package:boilerplate/domain/usecase/settings/delete_setting_db_usecase.dart';
import 'package:boilerplate/domain/usecase/settings/find_setting_db_usecase.dart';
import 'package:boilerplate/domain/usecase/settings/get_current_setting_usecase.dart';
import 'package:boilerplate/domain/usecase/settings/remove_current_setting_usecase.dart';
import 'package:boilerplate/domain/usecase/settings/save_current_setting_usecase.dart';
import 'package:boilerplate/domain/usecase/settings/save_setting_db_usecase.dart';

import 'package:boilerplate/domain/usecase/user/is_logged_in_usecase.dart'
    as user;
import 'package:boilerplate/domain/usecase/user/login_usecase.dart' as user;
import 'package:boilerplate/domain/usecase/user/logout_usecase.dart' as user;
import 'package:boilerplate/domain/usecase/user/register_usecase.dart' as user;
import 'package:boilerplate/domain/usecase/user/update_password_usecase.dart'
    as user;
import 'package:boilerplate/domain/usecase/user/update_user_usecase.dart'
    as user;

import 'package:boilerplate/domain/usecase/auth/get_current_user_usecase.dart'
    as auth;
import 'package:boilerplate/domain/usecase/auth/refresh_token_usecase.dart'
    as auth;

import '../../../di/service_locator.dart';

class UseCaseModule {
  static Future<void> configureUseCaseModuleInjection() async {
    getIt.registerSingleton<IsLoggedInUseCase>(
      IsLoggedInUseCase(getIt<AuthFirebaseRepository>()),
    );
    getIt.registerSingleton<LoginUseCase>(
      LoginUseCase(getIt<AuthFirebaseRepository>()),
    );
    getIt.registerSingleton<RegisterUseCase>(
      RegisterUseCase(
        getIt<AuthFirebaseRepository>(),
      ),
    );
    getIt.registerSingleton<LogoutUseCase>(
      LogoutUseCase(
        getIt<AuthFirebaseRepository>(),
      ),
    );
    getIt.registerSingleton<GetCurrentUserUseCase>(
      GetCurrentUserUseCase(
        getIt<AuthFirebaseRepository>(),
      ),
    );
    getIt.registerSingleton<UpdatePasswordUseCase>(
      UpdatePasswordUseCase(
        getIt<AuthFirebaseRepository>(),
      ),
    );
    getIt.registerSingleton<UpdateUserUseCase>(
      UpdateUserUseCase(
        getIt<AuthFirebaseRepository>(),
      ),
    );
    getIt.registerSingleton<SaveLoginStatusUseCase>(
      SaveLoginStatusUseCase(
        getIt<AuthFirebaseRepository>(),
      ),
    );
    getIt.registerSingleton<SaveUserDataUseCase>(
      SaveUserDataUseCase(
        getIt<AuthFirebaseRepository>(),
      ),
    );

    // old user usecase
    getIt.registerSingleton<user.LogoutUseCase>(
      user.LogoutUseCase(
        getIt<AuthRepository>(),
        getIt<UserRepository>(),
      ),
    );

    getIt.registerSingleton<auth.RefreshTokenUseCase>(
      auth.RefreshTokenUseCase(
        getIt<AuthRepository>(),
        getIt<user.LogoutUseCase>(),
      ),
    );

    getIt.registerSingleton<auth.GetCurrentUserUseCase>(
      auth.GetCurrentUserUseCase(
        getIt<AuthRepository>(),
        getIt<UserRepository>(),
        getIt<user.LogoutUseCase>(),
        getIt<auth.RefreshTokenUseCase>(),
      ),
    );

    getIt.registerSingleton<user.IsLoggedInUseCase>(
      user.IsLoggedInUseCase(
        getIt<UserRepository>(),
      ),
    );
    getIt.registerSingleton<user.LoginUseCase>(
      user.LoginUseCase(
        getIt<UserRepository>(),
        getIt<AuthRepository>(),
      ),
    );
    getIt.registerSingleton<user.RegisterUseCase>(
      user.RegisterUseCase(
        getIt<UserRepository>(),
      ),
    );
    getIt.registerSingleton<user.UpdatePasswordUseCase>(
      user.UpdatePasswordUseCase(
        getIt<UserRepository>(),
        getIt<auth.GetCurrentUserUseCase>(),
      ),
    );
    getIt.registerSingleton<user.UpdateUserUseCase>(
      user.UpdateUserUseCase(
        getIt<UserRepository>(),
        getIt<auth.GetCurrentUserUseCase>(),
      ),
    );

    // Settings
    getIt.registerSingleton<SaveSettingsUseCase>(
      SaveSettingsUseCase(getIt<SettingsRepository>()),
    );
    getIt.registerSingleton<FindSettingsByIdUseCase>(
      FindSettingsByIdUseCase(getIt<SettingsRepository>()),
    );
    getIt.registerSingleton<SaveCurrentSettingsUseCase>(
      SaveCurrentSettingsUseCase(getIt<SettingsRepository>()),
    );
    getIt.registerSingleton<GetCurrentSettingsUseCase>(
      GetCurrentSettingsUseCase(getIt<SettingsRepository>()),
    );
    getIt.registerSingleton<DeleteSettingsByIdUseCase>(
      DeleteSettingsByIdUseCase(getIt<SettingsRepository>()),
    );
    getIt.registerSingleton<RemoveCurrentSettingsUseCase>(
      RemoveCurrentSettingsUseCase(getIt<SettingsRepository>()),
    );

    // API
    getIt.registerSingleton<TopApiUseCase>(
      TopApiUseCase(
        getIt<HomeRepository>(),
      ),
    );
  }
}
