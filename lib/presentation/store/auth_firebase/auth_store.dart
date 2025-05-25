import 'package:boilerplate/core/domain/usecase/use_case.dart';
import 'package:boilerplate/core/stores/error/error_store.dart';
import 'package:boilerplate/core/stores/form/form_store.dart';
import 'package:boilerplate/core/widgets/notification.dart';
import 'package:flutter/foundation.dart';
import 'package:mobx/mobx.dart';

import 'package:boilerplate/domain/entity/user/user.dart';
import 'package:boilerplate/domain/usecase/auth_firebase/register_usecase.dart';
import 'package:boilerplate/domain/usecase/auth_firebase/login_usecase.dart';
import 'package:boilerplate/domain/usecase/auth_firebase/logout_usecase.dart';
import 'package:boilerplate/domain/usecase/auth_firebase/get_is_logged_in_usecase.dart';
import 'package:boilerplate/domain/usecase/auth_firebase/update_user_usecase.dart';
import 'package:boilerplate/domain/usecase/auth_firebase/update_password_usecase.dart';
import 'package:boilerplate/domain/usecase/auth_firebase/get_current_user_usecase.dart';
import 'package:boilerplate/domain/usecase/auth_firebase/save_user_data_usecase.dart';
import 'package:boilerplate/domain/usecase/auth_firebase/save_is_logged_in_usecase.dart';

part 'auth_store.g.dart';

class AuthStore = AuthStoreBase with _$AuthStore;

abstract class AuthStoreBase with Store {
  AuthStoreBase(
    this._registerUserUseCase,
    this._loginUserUseCase,
    this._logoutUserUseCase,
    this._isLoggedInUseCase,
    this._updateUserDataUseCase,
    this._updatePasswordUseCase,
    this._getCurrentUserUseCase,
    this._saveUserDataUseCase,
    this._saveLoginStatusUseCase,
    this.formErrorStore,
    this.errorStore,
  ) {
    _setupDisposers();
    // Pastikan init NotificationService di main.dart atau di sini
    _notificationService.init();
    checkLoginStatus();
  }

  final RegisterUseCase _registerUserUseCase;
  final LoginUseCase _loginUserUseCase;
  final LogoutUseCase _logoutUserUseCase;
  final IsLoggedInUseCase _isLoggedInUseCase;
  final UpdateUserUseCase _updateUserDataUseCase;
  final UpdatePasswordUseCase _updatePasswordUseCase;
  final GetCurrentUserUseCase _getCurrentUserUseCase;
  final SaveUserDataUseCase _saveUserDataUseCase;
  final SaveLoginStatusUseCase _saveLoginStatusUseCase;

  final FormErrorStore formErrorStore;
  final ErrorStore errorStore;

  final NotificationService _notificationService = NotificationService();

  late List<ReactionDisposer> _disposers;

  @observable
  bool isLoading = false;

  @observable
  bool isLoggedIn = false;

  @observable
  User? currentUser;

  @observable
  String? errorMessage;

  @computed
  bool get hasError => errorMessage != null && errorMessage!.isNotEmpty;

  @action
  void setLoading(bool value) {
    isLoading = value;
  }

  @action
  void setLoggedIn(bool value) {
    isLoggedIn = value;
  }

  @action
  void setCurrentUser(User? user) {
    currentUser = user;
  }

  @action
  void setErrorMessage(String? message) {
    errorMessage = message;
    if (message != null && message.isNotEmpty) {
      _notificationService.showNotification(
        id: DateTime.now()
            .millisecondsSinceEpoch
            .remainder(1000000), // Gunakan ID unik
        title: 'Error',
        body: message,
      );
    }
  }

  @action
  void resetError() {
    setErrorMessage(null);
  }

  @action
  Future<bool> register(
      String email, String password, String username, String fullName) async {
    setLoading(true);
    setErrorMessage(null);

    final params = RegisterParams(
      email: email,
      password: password,
      username: username,
      fullName: fullName,
    );

    final result = await _registerUserUseCase(params);

    return await result.fold(
      (failure) async {
        setErrorMessage(failure.message);
        setLoading(false);
        return false;
      },
      (user) async {
        setCurrentUser(user);
        setLoggedIn(true);

        await _saveLoginStatusUseCase(
            const SaveLoginStatusParams(isLoggedIn: true));
        await _saveUserDataUseCase(SaveUserDataParams(userData: user));

        _notificationService.showNotification(
          id: DateTime.now().millisecondsSinceEpoch.remainder(1000000),
          title: 'Registration Successful',
          body: 'Welcome, ${user.fullName}!',
        );

        setLoading(false);
        return true;
      },
    );
  }

  @action
  Future<bool> login(String email, String password) async {
    setLoading(true);
    setErrorMessage(null);

    final params = LoginParams(email: email, password: password);
    final result = await _loginUserUseCase(params);

    return await result.fold(
      (failure) async {
        setErrorMessage(failure.message);
        setLoading(false);
        return false;
      },
      (user) async {
        setCurrentUser(user);
        setLoggedIn(true);

        await _saveLoginStatusUseCase(
            const SaveLoginStatusParams(isLoggedIn: true));
        await _saveUserDataUseCase(SaveUserDataParams(userData: user));

        _notificationService.showNotification(
          id: DateTime.now().millisecondsSinceEpoch.remainder(1000000),
          title: 'Login Successful',
          body: 'Hello again, ${user.fullName}!',
        );

        setLoading(false);
        return true;
      },
    );
  }

  @action
  Future<bool> updateUserData(
      String fullName, String username, String? photoUrl) async {
    setLoading(true);
    setErrorMessage(null);

    final params = UpdateUserDataParams(
      fullName: fullName,
      username: username,
      photoUrl: photoUrl,
    );

    final result = await _updateUserDataUseCase(params);

    return await result.fold(
      (failure) async {
        setErrorMessage(failure.message);
        setLoading(false);
        return false;
      },
      (user) async {
        setCurrentUser(user);

        await _saveUserDataUseCase(SaveUserDataParams(userData: user));

        _notificationService.showNotification(
          id: DateTime.now().millisecondsSinceEpoch.remainder(1000000),
          title: 'Profile Updated',
          body: 'Your profile has been updated.',
        );

        setLoading(false);
        return true;
      },
    );
  }

  @action
  Future<bool> updatePassword(
      String currentPassword, String newPassword) async {
    setLoading(true);
    setErrorMessage(null);

    final params = UpdatePasswordParams(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );

    final result = await _updatePasswordUseCase(params);

    return await result.fold(
      (failure) async {
        setErrorMessage(failure.message);
        setLoading(false);
        return false;
      },
      (_) async {
        _notificationService.showNotification(
          id: DateTime.now().millisecondsSinceEpoch.remainder(1000000),
          title: 'Password Updated',
          body: 'Your password has been changed successfully.',
        );

        setLoading(false);
        return true;
      },
    );
  }

  @action
  Future<bool> logout() async {
    setLoading(true);
    setErrorMessage(null);

    final result = await _logoutUserUseCase(const NoParams());

    return await result.fold(
      (failure) async {
        setErrorMessage(failure.message);
        setLoading(false);
        return false;
      },
      (_) async {
        setCurrentUser(null);
        setLoggedIn(false);

        await _saveLoginStatusUseCase(
            const SaveLoginStatusParams(isLoggedIn: false));
        await _saveUserDataUseCase(const SaveUserDataParams(userData: null));

        _notificationService.showNotification(
          id: DateTime.now().millisecondsSinceEpoch.remainder(1000000),
          title: 'Logged Out',
          body: 'You have been logged out.',
        );

        setLoading(false);
        return true;
      },
    );
  }

  @action
  Future<void> checkLoginStatus() async {
    final isLoggedInResult = await _isLoggedInUseCase(const NoParams());

    isLoggedInResult.fold(
      (failure) {
        setLoggedIn(false);
        setErrorMessage(failure.message);
      },
      (loginStatus) {
        setLoggedIn(loginStatus);
      },
    );

    if (isLoggedIn) {
      await loadCurrentUser();
    } else {
      setCurrentUser(null);
    }
  }

  @action
  Future<void> loadCurrentUser() async {
    final userResult = await _getCurrentUserUseCase(const NoParams());

    userResult.fold(
      (failure) {
        setErrorMessage(failure.message);
        setCurrentUser(null);
      },
      (user) {
        setCurrentUser(user);
      },
    );
  }

  void _setupDisposers() {
    _disposers = [
      reaction((_) => currentUser, (_) {
        if (kDebugMode) {
          print("Current user changed: $currentUser");
        }
      }),
    ];
  }

  void dispose() {
    for (final disposer in _disposers) {
      disposer();
    }
  }
}
