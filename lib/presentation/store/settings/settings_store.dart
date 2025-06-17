import 'package:flutter/foundation.dart';
import 'package:boilerplate/core/domain/usecase/use_case.dart';
import 'package:boilerplate/domain/entity/user/setting.dart';
import 'package:boilerplate/domain/usecase/settings/delete_setting_db_usecase.dart';
import 'package:boilerplate/domain/usecase/settings/find_setting_db_usecase.dart';
import 'package:boilerplate/domain/usecase/settings/get_current_setting_usecase.dart';
import 'package:boilerplate/domain/usecase/settings/remove_current_setting_usecase.dart';
import 'package:boilerplate/domain/usecase/settings/save_current_setting_usecase.dart';
import 'package:boilerplate/domain/usecase/settings/save_setting_db_usecase.dart';
import 'package:boilerplate/presentation/store/auth_firebase/auth_store.dart';
import 'package:mobx/mobx.dart';

part 'settings_store.g.dart';

class SettingsStore = SettingsStoreBase with _$SettingsStore;

abstract class SettingsStoreBase with Store {
  final AuthStore authStore;
  final GetCurrentSettingsUseCase getCurrentSettingsUseCase;
  final FindSettingsByIdUseCase findSettingsByIdUseCase;
  final SaveSettingsUseCase saveSettingsUseCase;
  final SaveCurrentSettingsUseCase saveCurrentSettingsUseCase;
  final DeleteSettingsByIdUseCase deleteByIdUseCase;
  final RemoveCurrentSettingsUseCase removeCurrentSettingsUseCase;

  SettingsStoreBase({
    required this.authStore,
    required this.getCurrentSettingsUseCase,
    required this.findSettingsByIdUseCase,
    required this.saveSettingsUseCase,
    required this.saveCurrentSettingsUseCase,
    required this.deleteByIdUseCase,
    required this.removeCurrentSettingsUseCase,
  });

  @observable
  SettingsEntity? settings;

  @observable
  bool isLoading = false;

  @observable
  String? errorMessage;

  @computed
  bool get hasError => errorMessage != null && errorMessage!.isNotEmpty;

  String get _currentId {
    final user = authStore.currentUser;
    debugPrint('[DEBUG][SettingsStore] Current user: $user');
    return (authStore.isLoggedIn && user != null && user.id.isNotEmpty)
        ? user.id
        : 'guest';
  }

  // Helper untuk debug fetch DB dan SharedPreferences
  Future<void> _debugPrintDbState(String id, {String? prefix}) async {
    final dbResult = await findSettingsByIdUseCase(FindSettingsByIdParams(id));
    final dbSettings = dbResult.fold((f) => null, (r) => r);
    final spResult = await getCurrentSettingsUseCase(const NoParams());
    final spSettings = spResult.fold((f) => null, (r) => r);

    debugPrint('[DEBUG]${prefix != null ? "[$prefix]" : ""} '
        'ID: $id\n'
        '→ settings in-memory: ${settings?.toJson()}\n'
        '→ DB (Hive): ${dbSettings?.toJson()}\n'
        '→ Current (SharedPreferences): ${spSettings?.toJson()}');
  }

  @action
  Future<void> getSettings() async {
    isLoading = true;
    errorMessage = null;

    await authStore.loadCurrentUser();
    final id = _currentId;
    debugPrint('[DEBUG][getSettings] Start. CurrentId: $id');

    try {
      final currentResult = await getCurrentSettingsUseCase(const NoParams());
      SettingsEntity? current = currentResult.fold((f) => null, (r) => r);

      debugPrint(
          '[DEBUG][getSettings] Fetched from SharedPrefs: ${current?.toJson()}');

      if (current != null && current.id == id) {
        settings = current;
        isLoading = false;
        debugPrint(
            '[DEBUG][getSettings] Found current settings in SP, assigned in-memory. Done.');
        await _debugPrintDbState(id, prefix: 'getSettings/Done');
        return;
      }

      final dbResult =
          await findSettingsByIdUseCase(FindSettingsByIdParams(id));
      SettingsEntity? found = dbResult.fold((f) => null, (r) => r);

      debugPrint(
          '[DEBUG][getSettings] Fetched from Hive DB: ${found?.toJson()}');

      if (found != null) {
        await saveCurrentSettingsUseCase(found);
        settings = found;
        isLoading = false;
        debugPrint(
            '[DEBUG][getSettings] Found in DB, assigned in-memory & updated SP. Done.');
        await _debugPrintDbState(id, prefix: 'getSettings/Done');
        return;
      }

      final defaultSettings = SettingsEntity(
        id: id,
        contentTypes: const ['manga', 'manhwa', 'manhua'],
        demographic: 'male',
        matureContent: const ['mature', 'horror_gore', 'adult'],
      );

      await saveSettingsUseCase(defaultSettings);
      await saveCurrentSettingsUseCase(defaultSettings);
      settings = defaultSettings;
      debugPrint(
          '[DEBUG][getSettings] Default settings created, assigned in-memory, saved to DB & SP.');
      await _debugPrintDbState(id, prefix: 'getSettings/Done');
    } catch (e) {
      errorMessage = 'Failed to load settings: $e';
      debugPrint('[DEBUG][getSettings] Error: $e');
    } finally {
      isLoading = false;
    }
  }

  @action
  Future<void> saveOrUpdateSettings(SettingsEntity newSettings) async {
    isLoading = true;
    errorMessage = null;

    await authStore.loadCurrentUser();
    final id = _currentId;
    final updatedSettings = newSettings.copyWith(id: id);
    debugPrint(
        '[DEBUG][saveOrUpdateSettings] Saving: ${updatedSettings.toJson()}');

    try {
      await saveSettingsUseCase(updatedSettings);
      await saveCurrentSettingsUseCase(updatedSettings);
      settings = updatedSettings;
      debugPrint(
          '[DEBUG][saveOrUpdateSettings] Saved successfully. In-memory updated.');
      await _debugPrintDbState(id, prefix: 'saveOrUpdateSettings/Done');
    } catch (e) {
      errorMessage = 'Failed to save/update settings: $e';
      debugPrint('[DEBUG][saveOrUpdateSettings] Error: $e');
    } finally {
      isLoading = false;
    }
  }

  @action
  Future<void> deleteSettings() async {
    isLoading = true;
    errorMessage = null;

    await authStore.loadCurrentUser();
    final id = _currentId;
    debugPrint('[DEBUG][deleteSettings] Deleting for id: $id');

    try {
      await deleteByIdUseCase(DeleteSettingsByIdParams(id));
      debugPrint('[DEBUG][deleteSettings] Deleted from Hive DB.');

      final currentResult = await getCurrentSettingsUseCase(const NoParams());
      final current = currentResult.fold((f) => null, (r) => r);

      if (current != null && current.id == id) {
        await removeCurrentSettingsUseCase(const NoParams());
        debugPrint('[DEBUG][deleteSettings] Removed from SharedPreferences.');
      }
      settings = null;
      debugPrint('[DEBUG][deleteSettings] In-memory settings set to null.');

      await _debugPrintDbState(id, prefix: 'deleteSettings/Done');
    } catch (e) {
      errorMessage = 'Failed to delete settings: $e';
      debugPrint('[DEBUG][deleteSettings] Error: $e');
    } finally {
      isLoading = false;
    }
  }
}
