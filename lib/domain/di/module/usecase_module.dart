import 'dart:async';

import 'package:boilerplate/domain/repository/auth/auth_firebase_repository.dart';
import 'package:boilerplate/domain/usecase/auth_firebase/get_current_user_usecase.dart';
import 'package:boilerplate/domain/usecase/auth_firebase/get_is_logged_in_usecase.dart';
import 'package:boilerplate/domain/usecase/auth_firebase/login_usecase.dart';
import 'package:boilerplate/domain/usecase/auth_firebase/logout_usecase.dart';
import 'package:boilerplate/domain/usecase/auth_firebase/register_usecase.dart';
import 'package:boilerplate/domain/usecase/auth_firebase/save_is_logged_in_usecase.dart';
import 'package:boilerplate/domain/usecase/auth_firebase/save_user_data_usecase.dart';
import 'package:boilerplate/domain/usecase/auth_firebase/update_password_usecase.dart';
import 'package:boilerplate/domain/usecase/auth_firebase/update_user_usecase.dart';

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

    // getIt.registerSingleton<RefreshTokenUseCase>(
    //   RefreshTokenUseCase(
    //     getIt<AuthRepository>(),
    //     getIt<LogoutUseCase>(),
    //   ),
    // );

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
  }
}
