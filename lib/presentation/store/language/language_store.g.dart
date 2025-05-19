// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'language_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$LanguageStore on LanguageStoreBase, Store {
  Computed<String>? _$localeComputed;

  @override
  String get locale =>
      (_$localeComputed ??= Computed<String>(() => super.locale,
              name: 'LanguageStoreBase.locale'))
          .value;

  late final _$_localeAtom =
      Atom(name: 'LanguageStoreBase._locale', context: context);

  @override
  String get _locale {
    _$_localeAtom.reportRead();
    return super._locale;
  }

  @override
  set _locale(String value) {
    _$_localeAtom.reportWrite(value, super._locale, () {
      super._locale = value;
    });
  }

  late final _$LanguageStoreBaseActionController =
      ActionController(name: 'LanguageStoreBase', context: context);

  @override
  void changeLanguage(String value) {
    final _$actionInfo = _$LanguageStoreBaseActionController.startAction(
        name: 'LanguageStoreBase.changeLanguage');
    try {
      return super.changeLanguage(value);
    } finally {
      _$LanguageStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String getCode() {
    final _$actionInfo = _$LanguageStoreBaseActionController.startAction(
        name: 'LanguageStoreBase.getCode');
    try {
      return super.getCode();
    } finally {
      _$LanguageStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String? getLanguage() {
    final _$actionInfo = _$LanguageStoreBaseActionController.startAction(
        name: 'LanguageStoreBase.getLanguage');
    try {
      return super.getLanguage();
    } finally {
      _$LanguageStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
locale: ${locale}
    ''';
  }
}
