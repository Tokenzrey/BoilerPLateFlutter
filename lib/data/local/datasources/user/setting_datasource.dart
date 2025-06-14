import 'package:boilerplate/data/local/models/settings_model.dart';
import 'package:hive/hive.dart';

class SettingLocalDataSource {
  final Box<SettingsModel> _settingsBox;

  SettingLocalDataSource(this._settingsBox);

  /// Create or Update settings
  Future<void> saveSettings(SettingsModel model) async {
    await _settingsBox.put(model.id, model);
  }

  /// Read all settings
  Future<List<SettingsModel>> getAllSettings() async {
    return _settingsBox.values.toList();
  }

  /// Find settings by id
  Future<SettingsModel?> findById(String id) async {
    return _settingsBox.get(id);
  }

  /// Delete settings by id
  Future<void> deleteById(String id) async {
    await _settingsBox.delete(id);
  }

  /// Delete all settings
  Future<void> clearAll() async {
    await _settingsBox.clear();
  }
}
