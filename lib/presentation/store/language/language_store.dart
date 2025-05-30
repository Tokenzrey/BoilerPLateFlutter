// ignore_for_file: unused_field

import 'package:boilerplate/core/stores/error/error_store.dart';
import 'package:boilerplate/domain/entity/language/language.dart';
import 'package:boilerplate/domain/repository/setting/setting_repository.dart';
import 'package:mobx/mobx.dart';

part 'language_store.g.dart';

class LanguageStore = LanguageStoreBase with _$LanguageStore;

abstract class LanguageStoreBase with Store {
  static const String tag = "LanguageStore";

  // repository instance
  final SettingRepository _repository;

  // store for handling errors
  final ErrorStore errorStore;

  // supported languages
  List<Language> supportedLanguages = [
    Language(code: 'US', locale: 'en', language: 'English'),
    Language(code: 'DK', locale: 'da', language: 'Danish'),
    Language(code: 'ES', locale: 'es', language: 'España'),
  ];

  // constructor:---------------------------------------------------------------
  LanguageStoreBase(this._repository, this.errorStore) {
    init();
  }

  // store variables:-----------------------------------------------------------
  @observable
  String _locale = "en";

  @computed
  String get locale => _locale;

  // actions:-------------------------------------------------------------------
  @action
  void changeLanguage(String value) {
    _locale = value;
    _repository.changeLanguage(value).then((_) {
      // write additional logic here
    });
  }

  @action
  String getCode() {
    String code = "US";

    if (_locale == 'en') {
      code = "US";
    } else if (_locale == 'da') {
      code = "DK";
    } else if (_locale == 'es') {
      code = "ES";
    }

    return code;
  }

  @action
  String? getLanguage() {
    return supportedLanguages[supportedLanguages
            .indexWhere((language) => language.locale == _locale)]
        .language;
  }

  // general:-------------------------------------------------------------------
  void init() async {
    // getting current language from shared preference
    if (_repository.currentLanguage != null) {
      _locale = _repository.currentLanguage!;
    }
  }

  // dispose:-------------------------------------------------------------------
  dispose() {}
}
