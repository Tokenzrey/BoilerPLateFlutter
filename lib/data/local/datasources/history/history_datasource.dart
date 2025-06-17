import 'package:boilerplate/data/local/models/history_entry_model.dart';
import 'package:hive/hive.dart';

class HistoryLocalDataSource {
  final Box<HistoryModel> _historyBox;

  HistoryLocalDataSource(this._historyBox);

  /// Create or Update History
  Future<void> addOrUpdateEntry(HistoryModel model) async {
    try {
      print("Attempting to add to historyBox: ${model.runtimeType}, $model"); 
    final existingKey = _historyBox.keys.firstWhere(
      (key) {
        final item = _historyBox.get(key);
        return item?.userId == model.userId && item?.hid == model.hid;
      },
      orElse: () => null,
    );

    if (existingKey != null) {
      await _historyBox.delete(existingKey);
    }

    print("History DataSource Add: $model");
    final key = '${model.userId}_${model.hid}';
    await _historyBox.put(key, model);

    print("🗃 Current box content:");
    for (var key in _historyBox.keys) {
      print("🔑 $key: ${_historyBox.get(key)}");
    }
  } catch (e, stack) {
    print("❌ Error saat menambahkan history: $e");
    print("🔍 Stacktrace: $stack");
  }
  }

  /// Fetch History
  Future<List<HistoryModel>> fetchRecentHistory(String userId) async {
    try {
      final entries = _historyBox.values
          .where((e) => e.userId == userId)
          .toList();

      print("UserId: $userId");
      print("Entries Get: $entries");

      final Map<String, HistoryModel> latestMap = {};
      for (var entry in entries) {
        final existing = latestMap[entry.slug];
        if (existing == null || entry.createdAt.isAfter(existing.createdAt)) {
          latestMap[entry.slug] = entry;
        }
      }

      print("History DataSource Fetch: $latestMap");

      return latestMap.values.toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (e, stacktrace) {
      print("❌ Error in fetchRecentHistory: $e");
      print("🔍 Stacktrace: $stacktrace");
      return [];
    }
  }

  /// Delete settings by id
  Future<void> deleteById(String userId, String hid) async {
    try {
      final key = _historyBox.keys.firstWhere(
        (key) {
          final item = _historyBox.get(key);
          return item?.userId == userId && item?.hid == hid;
        },
        orElse: () => null,
      );

      if (key != null) {
        await _historyBox.delete(key);
      }
    } catch (e, stacktrace) {
      print("❌ Error in deleteById: $e");
      print("🔍 Stacktrace: $stacktrace");
    }
  }

  /// Delete all History
  Future<void> clearAll(String userId) async {
    try {
      final keysToDelete = _historyBox.keys.where((key) {
        final item = _historyBox.get(key);
        return item?.userId == userId;
      }).toList();

      await _historyBox.deleteAll(keysToDelete);
    } catch (e, stacktrace) {
      print("❌ Error in clearAll: $e");
      print("🔍 Stacktrace: $stacktrace");
    }
  }
}
