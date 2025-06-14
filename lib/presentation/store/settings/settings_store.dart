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
    return (authStore.isLoggedIn && user != null && user.id.isNotEmpty)
        ? user.id
        : 'guest';
  }

  @action
  Future<void> getSettings() async {
    isLoading = true;
    errorMessage = null;

    final id = _currentId;

    try {
      final currentResult = await getCurrentSettingsUseCase(const NoParams());
      SettingsEntity? current = currentResult.fold((f) => null, (r) => r);

      if (current != null && current.id == id) {
        settings = current;
        isLoading = false;
        return;
      }

      final dbResult =
          await findSettingsByIdUseCase(FindSettingsByIdParams(id));
      SettingsEntity? found = dbResult.fold((f) => null, (r) => r);

      if (found != null) {
        await saveCurrentSettingsUseCase(found);
        settings = found;
        isLoading = false;
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
    } catch (e) {
      errorMessage = 'Failed to load settings: $e';
    } finally {
      isLoading = false;
    }
  }

  @action
  Future<void> saveOrUpdateSettings(SettingsEntity newSettings) async {
    isLoading = true;
    errorMessage = null;

    final id = _currentId;
    final updatedSettings = newSettings.copyWith(id: id);

    try {
      await saveSettingsUseCase(updatedSettings);
      await saveCurrentSettingsUseCase(updatedSettings);
      settings = updatedSettings;
    } catch (e) {
      errorMessage = 'Failed to save/update settings: $e';
    } finally {
      isLoading = false;
    }
  }

  @action
  Future<void> deleteSettings() async {
    isLoading = true;
    errorMessage = null;

    final id = _currentId;

    try {
      await deleteByIdUseCase(DeleteSettingsByIdParams(id));

      final currentResult = await getCurrentSettingsUseCase(const NoParams());
      final current = currentResult.fold((f) => null, (r) => r);

      if (current != null && current.id == id) {
        await removeCurrentSettingsUseCase(const NoParams());
      }
      settings = null;
    } catch (e) {
      errorMessage = 'Failed to delete settings: $e';
    } finally {
      isLoading = false;
    }
  }
}
