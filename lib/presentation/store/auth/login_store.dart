import 'package:boilerplate/core/domain/usecase/use_case.dart';
import 'package:boilerplate/core/stores/error/error_store.dart';
import 'package:boilerplate/core/stores/form/form_store.dart';
import 'package:boilerplate/domain/usecase/user/is_logged_in_usecase.dart';
import 'package:mobx/mobx.dart';

import '../../../domain/entity/user/user.dart';
import '../../../domain/usecase/user/login_usecase.dart';
import '../../../domain/usecase/user/logout_usecase.dart';

part 'login_store.g.dart';

class UserStore = UserStoreBase with _$UserStore;

abstract class UserStoreBase with Store {
  // constructor:---------------------------------------------------------------
  UserStoreBase(
    this._isLoggedInUseCase,
    this._loginUseCase,
    this._logoutUseCase,
    this.formErrorStore,
    this.errorStore,
  ) {
    // setting up disposers
    _setupDisposers();

    // checking if user is logged in
    _isLoggedInUseCase.execute(const NoParams()).then((value) async {
      isLoggedIn = value.fold(
        (failure) => false,
        (success) => success,
      );
    });
  }

  // use cases:-----------------------------------------------------------------
  final IsLoggedInUseCase _isLoggedInUseCase;
  final LoginUseCase _loginUseCase;
  final LogoutUseCase _logoutUseCase;

  // stores:--------------------------------------------------------------------
  // for handling form errors
  final FormErrorStore formErrorStore;

  // store for handling error messages
  final ErrorStore errorStore;

  // disposers:-----------------------------------------------------------------
  late List<ReactionDisposer> _disposers;

  void _setupDisposers() {
    _disposers = [
      reaction((_) => success, (_) => success = false, delay: 200),
    ];
  }

  // empty responses:-----------------------------------------------------------
  static ObservableFuture<User?> emptyLoginResponse =
      ObservableFuture.value(null);

  // store variables:-----------------------------------------------------------
  bool isLoggedIn = false;

  @observable
  bool success = false;

  @observable
  ObservableFuture<User?> loginFuture = emptyLoginResponse;

  @computed
  bool get isLoading => loginFuture.status == FutureStatus.pending;

  // actions:-------------------------------------------------------------------
  @action
  Future<void> login(String email, String password) async {
    final LoginParams loginParams =
        LoginParams(email: email, password: password);

    final future = _loginUseCase.execute(loginParams).then((either) {
      return either.fold<User?>(
        (failure) {
          isLoggedIn = false;
          success = false;
          errorStore.errorMessage = failure.message;
          return null;
        },
        (user) {
          isLoggedIn = true;
          success = true;
          return user;
        },
      );
    });

    loginFuture = ObservableFuture(future);
  }

  logout() async {
    await _logoutUseCase.execute(const NoParams());
    isLoggedIn = false;
    success = false;
  }

  // general methods:-----------------------------------------------------------
  void dispose() {
    for (final d in _disposers) {
      d();
    }
  }
}
