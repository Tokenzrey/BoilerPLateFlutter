import 'dart:io';
import 'package:boilerplate/core/logging/logger.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:flutter/foundation.dart'; // Untuk debugPrint

import 'config/database_service.dart';
import 'config/database_exception.dart';
import 'config/database_config.dart';
import 'hive_encryption.dart';
import 'package:boilerplate/di/service_locator.dart';

/// Implementasi [DatabaseService] menggunakan Hive sebagai database.
class HiveService implements DatabaseService {
  final HiveEncryption _encryption;
  final DatabaseConfig _config;
  final Map<String, Box> _openBoxes = {};

  late final Logger _logger;

  bool _isInitialized = false;
  String? _databaseDir;

  HiveService({
    HiveEncryption? encryption,
    DatabaseConfig? config,
  })  : _encryption = encryption ?? HiveEncryption(),
        _config = config ?? DatabaseConfig.defaultConfig();

  @override
  Future<void> init() async {
    debugPrint('[HiveService][init] Mulai inisialisasi...');
    try {
      if (_config.loggingEnabled) {
        _logger = getIt<Logger>().withTag('[HiveDatabase]');
        _logger.info('Menginisialisasi database Hive', metadata: {
          'inMemoryMode': _config.inMemoryStorage,
          'encryptionEnabled': _config.encryptionEnabled,
          'databaseDir': _config.databaseDir,
          'schemaVersion': _config.schemaVersion,
          'clearOnInit': _config.clearDatabaseOnInit,
          'backupPath': _config.backupPath,
          'autoBackup': _config.autoBackup,
          'compactOnOpen': _config.compactOnOpen,
        });
      }

      if (_config.inMemoryStorage) {
        Hive.init(null);
        debugPrint('[HiveService][init] Mode in-memory aktif.');
      } else {
        await Hive.initFlutter(_config.databaseDir);

        _databaseDir = _config.databaseDir ??
            (await path_provider.getApplicationDocumentsDirectory()).path;
        debugPrint('[HiveService][init] Database path: $_databaseDir');

        if (_config.autoBackup && _config.backupPath != null) {
          final backupDir = Directory(_config.backupPath!);
          if (!await backupDir.exists()) {
            await backupDir.create(recursive: true);
            debugPrint(
                '[HiveService][init] Membuat direktori backup: ${_config.backupPath}');
          }
        }
      }

      if (_config.clearDatabaseOnInit) {
        debugPrint(
            '[HiveService][init] clearDatabaseOnInit: TRUE, menghapus data dari disk...');
        await Hive.deleteFromDisk();
      }

      _logSuccess('Database Hive berhasil diinisialisasi');
      debugPrint('[HiveService][init] Selesai inisialisasi!');
      _isInitialized = true;
    } catch (e) {
      _logError('Gagal menginisialisasi database Hive, $e');
      debugPrint('[HiveService][init][ERROR] $e');
      throw DatabaseException(
        message: 'Gagal menginisialisasi Hive',
        code: 'INIT_ERROR',
        originalError: e,
      );
    }
  }

  @override
  Future<Box<T>> openBox<T>(String boxName) async {
    checkInitialized();
    debugPrint('[HiveService][openBox] Membuka box: $boxName');

    if (_openBoxes.containsKey(boxName)) {
      _logDebug('Membuka box: $boxName (cached)');
      debugPrint(
          '[HiveService][openBox] Box "$boxName" sudah dibuka sebelumnya (cached)');
      return _openBoxes[boxName] as Box<T>;
    }

    try {
      HiveCipher? cipher;

      if (_config.encryptionEnabled) {
        debugPrint(
            '[HiveService][openBox] Enkripsi aktif. Mengambil encryption key...');
        final Uint8List encryptionKey;
        if (_config.encryptionKey != null) {
          encryptionKey = Uint8List.fromList(_config.encryptionKey!);
        } else {
          encryptionKey = Uint8List.fromList(
              await _encryption.getEncryptionKey(_config.encryptionKeyName));
        }
        cipher = _encryption.createCipher(encryptionKey);
      }

      Box<T> box;
      int recoveryAttempts = 0;

      while (true) {
        try {
          if (_config.lazyBoxMode) {
            debugPrint('[HiveService][openBox] Membuka LazyBox: $boxName');
            box = await Hive.openLazyBox<T>(
              boxName,
              encryptionCipher: cipher,
              crashRecovery: true,
            ) as Box<T>;
          } else {
            debugPrint('[HiveService][openBox] Membuka Box standar: $boxName');
            box = await Hive.openBox<T>(
              boxName,
              encryptionCipher: cipher,
              crashRecovery: true,
            );

            if (_config.compactOnOpen) {
              debugPrint(
                  '[HiveService][openBox] compactOnOpen aktif. Kompaksi...');
              await box.compact();
              final stats = box.toMap();
              final entries = stats.length;
              final deletedEntries = await _countDeletedEntries(box);

              if (_shouldCompact(entries, deletedEntries)) {
                debugPrint(
                    '[HiveService][openBox] Kompaksi kedua, karena banyak deleted entry.');
                await box.compact();
              }
            }
          }
          break;
        } catch (e) {
          recoveryAttempts++;
          debugPrint(
              '[HiveService][openBox][ERROR] Percobaan recovery ke-$recoveryAttempts: $e');

          if (recoveryAttempts >= _config.maxRecoveryAttempts) {
            debugPrint('[HiveService][openBox][ERROR] Max recovery attempts.');
            rethrow;
          }

          switch (_config.recoveryStrategy) {
            case RecoveryStrategy.deleteBoxIfCorrupted:
              debugPrint(
                  '[HiveService][openBox][RECOVERY] Menghapus box rusak: $boxName');
              await Hive.deleteBoxFromDisk(boxName);
              break;
            case RecoveryStrategy.restoreFromBackup:
              debugPrint(
                  '[HiveService][openBox][RECOVERY] Restore from backup...');
              if (_config.backupPath != null) {
                await _restoreFromBackup(boxName);
              } else {
                await Hive.deleteBoxFromDisk(boxName);
              }
              break;
            case RecoveryStrategy.throwException:
              throw DatabaseException.boxOpenError(
                boxName: boxName,
                error: e,
              );
            case RecoveryStrategy.recoverAndDeleteCorruptedData:
              debugPrint(
                  '[HiveService][openBox][RECOVERY] recoverAndDeleteCorruptedData, lanjut loop...');
              continue;
          }
        }
      }

      _openBoxes[boxName] = box;

      if (_config.autoBackup && _config.backupPath != null) {
        debugPrint(
            '[HiveService][openBox] autoBackup aktif. Membuat backup...');
        await createBackup(boxName);
      }

      _logDebug('Membuka box: $boxName');
      debugPrint('[HiveService][openBox] Box "$boxName" berhasil dibuka!');
      return box;
    } catch (e) {
      _logError('Gagal membuka box: $boxName, exception: $e');
      debugPrint('[HiveService][openBox][ERROR] $e');
      throw DatabaseException.boxOpenError(
        boxName: boxName,
        error: e,
      );
    }
  }

  Future<Box<T>> forceRecoveryAndOpen<T>(String boxName) async {
    checkInitialized();
    debugPrint(
        '[HiveService][forceRecoveryAndOpen] Forcing recovery: $boxName');

    try {
      await Hive.deleteBoxFromDisk(boxName);
      debugPrint('[HiveService][forceRecoveryAndOpen] Box deleted: $boxName');
    } catch (e) {
      debugPrint(
          '[HiveService][forceRecoveryAndOpen][ERROR] Gagal hapus box: $boxName, $e');
    }

    if (!_config.inMemoryStorage && _databaseDir != null) {
      try {
        final directory = Directory(_databaseDir!);
        if (await directory.exists()) {
          final files = await directory.list().toList();
          for (final file in files) {
            if (file.path.contains(boxName)) {
              try {
                await File(file.path).delete();
                debugPrint(
                    '[HiveService][forceRecoveryAndOpen] File terkait dihapus: ${file.path}');
              } catch (e) {
                debugPrint(
                    '[HiveService][forceRecoveryAndOpen][ERROR] Gagal hapus file: ${file.path}, $e');
              }
            }
          }
        }
      } catch (e) {
        debugPrint(
            '[HiveService][forceRecoveryAndOpen][ERROR] Gagal bersihkan file: $e');
      }
    }

    final box = await Hive.openBox<T>(
      boxName,
      crashRecovery: true,
    );

    _openBoxes[boxName] = box;
    _logSuccess('Successfully recovered and opened box: $boxName');
    debugPrint(
        '[HiveService][forceRecoveryAndOpen] Sukses recovery dan buka box: $boxName');
    return box;
  }

  Future<int> _countDeletedEntries(Box box) async {
    try {
      if (box.isOpen) {
        if (box is LazyBox) {
          final String boxPath = box.path ?? '';
          if (boxPath.isNotEmpty) {
            final File boxFile = File(boxPath);
            if (await boxFile.exists()) {
              final int fileSize = await boxFile.length();
              final int currentEntries = box.length;
              const int avgEntrySize = 100;
              final int estimatedCapacity = fileSize ~/ avgEntrySize;
              final int estimatedDeleted = estimatedCapacity - currentEntries;
              return estimatedDeleted > 0 ? estimatedDeleted : 0;
            }
          }
          return (box.length * 0.2).round();
        }

        final boxLength = box.length;
        final boxPath = box.path;
        if (boxPath != null) {
          final File boxFile = File(boxPath);
          if (await boxFile.exists()) {
            final fileSize = await boxFile.length();
            int totalDataSize = 0;
            box.toMap().forEach((key, value) {
              int keySize = key is String ? key.length * 2 + 6 : 4;
              int valueSize;
              if (value == null) {
                valueSize = 1;
              } else if (value is num) {
                valueSize = 8;
              } else if (value is String) {
                valueSize = value.length * 2 + 6;
              } else if (value is List) {
                valueSize = value.length * 4 + 10;
              } else if (value is Map) {
                valueSize = value.length * 8 + 10;
              } else {
                valueSize = 100;
              }
              totalDataSize += keySize + valueSize + 40;
            });

            if (totalDataSize > 0 && fileSize > totalDataSize * 1.5) {
              return ((fileSize - totalDataSize) / (totalDataSize / boxLength))
                  .round();
            }
            if (fileSize > boxLength * 200) {
              return (fileSize / 200 - boxLength).round();
            }
          }
        }
        if (boxLength > 100) {
          return (boxLength * 0.15).round();
        } else if (boxLength > 20) {
          return (boxLength * 0.1).round();
        }
      }
      return 0;
    } catch (e) {
      if (_config.loggingEnabled) {
        _logger.debug('Error menghitung entri yang dihapus: $e');
      }
      final int currentEntries = box.length;
      if (currentEntries > 1000) {
        return (currentEntries * 0.1).round();
      } else if (currentEntries > 100) {
        return (currentEntries * 0.05).round();
      }
      return 0;
    }
  }

  bool _shouldCompact(int entries, int deletedEntries) {
    if (entries == 0) return false;
    if (deletedEntries > 50) return true;
    if (entries > 500 && deletedEntries > entries * 0.1) return true;
    if (entries > 100 && deletedEntries > entries * 0.2) return true;
    if (entries > 0 && deletedEntries > entries * 0.5) return true;
    return false;
  }

  @override
  Future<double> analyzeStorageEfficiency(String boxName) async {
    checkInitialized();

    try {
      final box = await openBox(boxName);
      final entries = box.length;
      final deletedEntries = await _countDeletedEntries(box);
      final totalEntries = entries + deletedEntries;

      debugPrint(
          '[HiveService][analyzeStorageEfficiency] $boxName -> entries: $entries, deleted: $deletedEntries, total: $totalEntries');

      if (totalEntries == 0) return 100.0;

      return (entries / totalEntries) * 100;
    } catch (e) {
      _logError('Gagal menganalisis efisiensi storage untuk box $boxName: $e');
      debugPrint('[HiveService][analyzeStorageEfficiency][ERROR] $e');
      return 0.0;
    }
  }

  @override
  Future<Map<String, bool>> compactAllBoxesIfNeeded() async {
    checkInitialized();
    debugPrint('[HiveService][compactAllBoxesIfNeeded] Mulai...');

    final results = <String, bool>{};
    for (final boxName in _openBoxes.keys) {
      try {
        final box = _openBoxes[boxName]!;
        final entries = box.length;
        final deletedEntries = await _countDeletedEntries(box);

        if (_shouldCompact(entries, deletedEntries)) {
          debugPrint(
              '[HiveService][compactAllBoxesIfNeeded] Kompaksi: $boxName');
          await box.compact();
          results[boxName] = true;
        } else {
          results[boxName] = false;
        }
      } catch (e) {
        _logError('Gagal kompaksi box $boxName: $e');
        debugPrint('[HiveService][compactAllBoxesIfNeeded][ERROR] $e');
        results[boxName] = false;
      }
    }

    debugPrint('[HiveService][compactAllBoxesIfNeeded] Selesai!');
    return results;
  }

  @override
  Future<void> createBackup(String boxName) async {
    if (_config.backupPath == null || _databaseDir == null) return;

    debugPrint('[HiveService][createBackup] Membuat backup: $boxName');
    try {
      final boxDir = path.join(_databaseDir!, boxName);
      final backupDir = path.join(_config.backupPath!, boxName);

      final backupDirObj = Directory(backupDir);
      if (!await backupDirObj.exists()) {
        await backupDirObj.create(recursive: true);
        debugPrint(
            '[HiveService][createBackup] Membuat direktori backup: $backupDir');
      }

      final boxDirObj = Directory(boxDir);
      if (await boxDirObj.exists()) {
        await for (final file in boxDirObj.list()) {
          if (file is File) {
            final fileName = path.basename(file.path);
            final backupFile = File(path.join(backupDir, fileName));
            await file.copy(backupFile.path);
            debugPrint('[HiveService][createBackup] Backup file: $fileName');
          }
        }
      }
    } catch (e) {
      _logError('Error saat membuat backup untuk $boxName: $e');
      debugPrint('[HiveService][createBackup][ERROR] $e');
    }
  }

  void _logError(String message) {
    if (_config.loggingEnabled) {
      _logger.error(message);
    }
    debugPrint('[HiveService][ERROR] $message');
  }

  void _logSuccess(String message) {
    if (_config.loggingEnabled) {
      _logger.info(message);
    }
    debugPrint('[HiveService][SUCCESS] $message');
  }

  void _logDebug(String message) {
    if (_config.loggingEnabled) {
      _logger.debug(message);
    }
    debugPrint('[HiveService][DEBUG] $message');
  }

  Future<void> _restoreFromBackup(String boxName) async {
    if (_config.backupPath == null || _databaseDir == null) return;

    debugPrint('[HiveService][_restoreFromBackup] Mulai restore: $boxName');
    try {
      final boxDir = path.join(_databaseDir!, boxName);
      final backupDir = path.join(_config.backupPath!, boxName);

      final backupDirObj = Directory(backupDir);
      if (!await backupDirObj.exists()) {
        debugPrint('[HiveService][_restoreFromBackup] Tidak ada backup!');
        return;
      }

      await Hive.deleteBoxFromDisk(boxName);

      final boxDirObj = Directory(boxDir);
      if (!await boxDirObj.exists()) {
        await boxDirObj.create(recursive: true);
      }

      await for (final file in backupDirObj.list()) {
        if (file is File) {
          final fileName = path.basename(file.path);
          final boxFile = File(path.join(boxDir, fileName));
          await file.copy(boxFile.path);
          debugPrint(
              '[HiveService][_restoreFromBackup] Restore file: $fileName');
        }
      }
    } catch (e) {
      _logError('Error saat memulihkan backup untuk $boxName: $e');
      debugPrint('[HiveService][_restoreFromBackup][ERROR] $e');
      await Hive.deleteBoxFromDisk(boxName);
    }
  }

  @override
  Future<void> closeBox(String boxName) async {
    checkInitialized();
    debugPrint('[HiveService][closeBox] Menutup box: $boxName');

    if (_openBoxes.containsKey(boxName)) {
      if (_config.autoBackup && _config.backupPath != null) {
        await createBackup(boxName);
      }

      final box = _openBoxes[boxName]!;
      await box.close();
      _openBoxes.remove(boxName);
      debugPrint('[HiveService][closeBox] Box ditutup: $boxName');
    }
  }

  @override
  Future<void> closeAllBoxes() async {
    checkInitialized();
    debugPrint('[HiveService][closeAllBoxes] Menutup semua box...');
    for (final boxName in List.from(_openBoxes.keys)) {
      await closeBox(boxName);
    }
    debugPrint('[HiveService][closeAllBoxes] Semua box sudah ditutup.');
  }

  @override
  Future<void> clearBox(String boxName) async {
    checkInitialized();
    debugPrint('[HiveService][clearBox] Mengosongkan box: $boxName');
    if (_openBoxes.containsKey(boxName)) {
      await _openBoxes[boxName]!.clear();
    } else {
      final box = await openBox(boxName);
      await box.clear();
    }
    debugPrint('[HiveService][clearBox] Box dikosongkan: $boxName');
  }

  @override
  Future<bool> boxExists(String boxName) async {
    checkInitialized();
    debugPrint('[HiveService][boxExists] Mengecek box: $boxName');
    return Hive.boxExists(boxName);
  }

  @override
  List<String> getOpenBoxes() {
    checkInitialized();
    debugPrint('[HiveService][getOpenBoxes] ${_openBoxes.keys}');
    return _openBoxes.keys.toList();
  }

  @override
  void registerAdapter<T>(dynamic adapter) {
    checkInitialized();
    if (!Hive.isAdapterRegistered(adapter.typeId)) {
      Hive.registerAdapter<T>(adapter);
      debugPrint(
          '[HiveService][registerAdapter] Adapter registered: ${adapter.runtimeType}');
    }
  }

  @override
  void checkInitialized() {
    if (!_isInitialized) {
      _logError('Database belum terinisialisasi');
      debugPrint(
          '[HiveService][checkInitialized][ERROR] Database belum di-init!');
      throw DatabaseException.notInitialized();
    }
  }

  @override
  Box<T>? getOpenBox<T>(String boxName) {
    if (_openBoxes.containsKey(boxName)) {
      debugPrint('[HiveService][getOpenBox] Get open box: $boxName');
      return _openBoxes[boxName] as Box<T>;
    }
    debugPrint('[HiveService][getOpenBox] Box belum dibuka: $boxName');
    return null;
  }

  @override
  Future<String?> createFullBackup() async {
    if (_config.backupPath == null) return null;
    debugPrint('[HiveService][createFullBackup] Membuat full backup...');
    try {
      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
      final backupDir =
          path.join(_config.backupPath!, 'full_backup_$timestamp');

      final backupDirObj = Directory(backupDir);
      if (!await backupDirObj.exists()) {
        await backupDirObj.create(recursive: true);
      }

      for (final boxName in _openBoxes.keys) {
        await createBackup(boxName);
      }
      debugPrint('[HiveService][createFullBackup] Selesai.');
      return backupDir;
    } catch (e) {
      _logError('Full backup gagal: $e');
      debugPrint('[HiveService][createFullBackup][ERROR] $e');
      return null;
    }
  }

  @override
  int getSchemaVersion() => _config.schemaVersion;

  @override
  Future<void> compactBox(String boxName) async {
    checkInitialized();
    if (_openBoxes.containsKey(boxName)) {
      await _openBoxes[boxName]!.compact();
      debugPrint('[HiveService][compactBox] Kompaksi: $boxName');
    }
  }

  @override
  String? getDatabaseDirectory() {
    debugPrint('[HiveService][getDatabaseDirectory] $_databaseDir');
    return _databaseDir;
  }
}
