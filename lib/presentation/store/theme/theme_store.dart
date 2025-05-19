import 'package:boilerplate/core/stores/error/error_store.dart';
import 'package:boilerplate/domain/repository/setting/setting_repository.dart';
import 'package:flutter/material.dart';
import 'package:mobx/mobx.dart';

part 'theme_store.g.dart';

class ThemeStore = ThemeStoreBase with _$ThemeStore;

abstract class ThemeStoreBase with Store {
  final String tag = "ThemeStoreBase";

  // repository instance
  final SettingRepository _repository;

  // store for handling errors
  final ErrorStore errorStore;

  // store variables:-----------------------------------------------------------
  @observable
  bool _darkMode = false;

  // getters:-------------------------------------------------------------------
  bool get darkMode => _darkMode;

  // constructor:---------------------------------------------------------------
  ThemeStoreBase(this._repository, this.errorStore) {
    init();
  }

  // actions:-------------------------------------------------------------------
  @action
  Future changeBrightnessToDark(bool value) async {
    _darkMode = value;
    await _repository.changeBrightnessToDark(value);
  }

  // general methods:-----------------------------------------------------------
  Future init() async {
    _darkMode = _repository.isDarkMode;
  }

  bool isPlatformDark(BuildContext context) =>
      MediaQuery.platformBrightnessOf(context) == Brightness.dark;

  // dispose:-------------------------------------------------------------------
  dispose() {}
}
