// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$AuthStore on AuthStoreBase, Store {
  Computed<bool>? _$hasErrorComputed;

  @override
  bool get hasError => (_$hasErrorComputed ??=
          Computed<bool>(() => super.hasError, name: 'AuthStoreBase.hasError'))
      .value;

  late final _$isLoadingAtom =
      Atom(name: 'AuthStoreBase.isLoading', context: context);

  @override
  bool get isLoading {
    _$isLoadingAtom.reportRead();
    return super.isLoading;
  }

  @override
  set isLoading(bool value) {
    _$isLoadingAtom.reportWrite(value, super.isLoading, () {
      super.isLoading = value;
    });
  }

  late final _$isLoggedInAtom =
      Atom(name: 'AuthStoreBase.isLoggedIn', context: context);

  @override
  bool get isLoggedIn {
    _$isLoggedInAtom.reportRead();
    return super.isLoggedIn;
  }

  @override
  set isLoggedIn(bool value) {
    _$isLoggedInAtom.reportWrite(value, super.isLoggedIn, () {
      super.isLoggedIn = value;
    });
  }

  late final _$currentUserAtom =
      Atom(name: 'AuthStoreBase.currentUser', context: context);

  @override
  User? get currentUser {
    _$currentUserAtom.reportRead();
    return super.currentUser;
  }

  @override
  set currentUser(User? value) {
    _$currentUserAtom.reportWrite(value, super.currentUser, () {
      super.currentUser = value;
    });
  }

  late final _$errorMessageAtom =
      Atom(name: 'AuthStoreBase.errorMessage', context: context);

  @override
  String? get errorMessage {
    _$errorMessageAtom.reportRead();
    return super.errorMessage;
  }

  @override
  set errorMessage(String? value) {
    _$errorMessageAtom.reportWrite(value, super.errorMessage, () {
      super.errorMessage = value;
    });
  }

  late final _$registerAsyncAction =
      AsyncAction('AuthStoreBase.register', context: context);

  @override
  Future<bool> register(
      String email, String password, String username, String fullName,
      {String avatar = "0"}) {
    return _$registerAsyncAction.run(() =>
        super.register(email, password, username, fullName, avatar: avatar));
  }

  late final _$loginAsyncAction =
      AsyncAction('AuthStoreBase.login', context: context);

  @override
  Future<bool> login(String email, String password) {
    return _$loginAsyncAction.run(() => super.login(email, password));
  }

  late final _$updateUserDataAsyncAction =
      AsyncAction('AuthStoreBase.updateUserData', context: context);

  @override
  Future<bool> updateUserData(String fullName, String username, String avatar) {
    return _$updateUserDataAsyncAction
        .run(() => super.updateUserData(fullName, username, avatar));
  }

  late final _$updatePasswordAsyncAction =
      AsyncAction('AuthStoreBase.updatePassword', context: context);

  @override
  Future<bool> updatePassword(String currentPassword, String newPassword) {
    return _$updatePasswordAsyncAction
        .run(() => super.updatePassword(currentPassword, newPassword));
  }

  late final _$deleteAccountAsyncAction =
      AsyncAction('AuthStoreBase.deleteAccount', context: context);

  @override
  Future<bool> deleteAccount(String password) {
    return _$deleteAccountAsyncAction.run(() => super.deleteAccount(password));
  }

  late final _$deleteAccountByIdAsyncAction =
      AsyncAction('AuthStoreBase.deleteAccountById', context: context);

  @override
  Future<bool> deleteAccountById(String uid) {
    return _$deleteAccountByIdAsyncAction
        .run(() => super.deleteAccountById(uid));
  }

  late final _$logoutAsyncAction =
      AsyncAction('AuthStoreBase.logout', context: context);

  @override
  Future<bool> logout() {
    return _$logoutAsyncAction.run(() => super.logout());
  }

  late final _$checkLoginStatusAsyncAction =
      AsyncAction('AuthStoreBase.checkLoginStatus', context: context);

  @override
  Future<void> checkLoginStatus() {
    return _$checkLoginStatusAsyncAction.run(() => super.checkLoginStatus());
  }

  late final _$loadCurrentUserAsyncAction =
      AsyncAction('AuthStoreBase.loadCurrentUser', context: context);

  @override
  Future<void> loadCurrentUser() {
    return _$loadCurrentUserAsyncAction.run(() => super.loadCurrentUser());
  }

  late final _$AuthStoreBaseActionController =
      ActionController(name: 'AuthStoreBase', context: context);

  @override
  void setLoading(bool value) {
    final _$actionInfo = _$AuthStoreBaseActionController.startAction(
        name: 'AuthStoreBase.setLoading');
    try {
      return super.setLoading(value);
    } finally {
      _$AuthStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setLoggedIn(bool value) {
    final _$actionInfo = _$AuthStoreBaseActionController.startAction(
        name: 'AuthStoreBase.setLoggedIn');
    try {
      return super.setLoggedIn(value);
    } finally {
      _$AuthStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setCurrentUser(User? user) {
    final _$actionInfo = _$AuthStoreBaseActionController.startAction(
        name: 'AuthStoreBase.setCurrentUser');
    try {
      return super.setCurrentUser(user);
    } finally {
      _$AuthStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setErrorMessage(String? message) {
    final _$actionInfo = _$AuthStoreBaseActionController.startAction(
        name: 'AuthStoreBase.setErrorMessage');
    try {
      return super.setErrorMessage(message);
    } finally {
      _$AuthStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void resetError() {
    final _$actionInfo = _$AuthStoreBaseActionController.startAction(
        name: 'AuthStoreBase.resetError');
    try {
      return super.resetError();
    } finally {
      _$AuthStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
isLoading: ${isLoading},
isLoggedIn: ${isLoggedIn},
currentUser: ${currentUser},
errorMessage: ${errorMessage},
hasError: ${hasError}
    ''';
  }
}
