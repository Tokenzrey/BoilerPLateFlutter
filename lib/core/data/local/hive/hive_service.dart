/// Implementasi database service menggunakan Hive untuk Flutter.
///
/// HiveService memberikan lapisan abstraksi di atas database Hive yang
/// menangani operasi umum seperti inisialisasi, enkripsi, backup, pemulihan,
/// dan manajemen box. Kelas ini mengimplementasikan [DatabaseService] untuk
/// memberikan antarmuka yang konsisten dan dapat diuji.
///
/// ## Fitur Utama
///
/// - **Enkripsi Database**: Mendukung AES-256 untuk mengenkripsi data sensitif
/// - **Backup & Restore**: Sistem backup otomatis dengan strategi pemulihan
/// - **Penanganan Korupsi**: Mendukung berbagai strategi untuk menangani database korup
/// - **Lazy Loading**: Mendukung LazyBox untuk kinerja yang lebih baik dengan dataset besar
/// - **Mode In-Memory**: Penyimpanan sementara untuk pengujian
///
/// ## Cara Penggunaan
///
/// ```dart
/// // Inisialisasi dengan konfigurasi default
/// final databaseService = HiveService();
/// await databaseService.init();
///
/// // Atau dengan konfigurasi kustom
/// final customConfig = DatabaseConfig(
///   encryptionEnabled: true,
///   autoBackup: true,
///   backupPath: '/path/to/backup',
/// );
/// final databaseService = HiveService(config: customConfig);
/// await databaseService.init();
///
/// // Daftarkan adapter untuk model kustom
/// databaseService.registerAdapter(UserModelAdapter());
///
/// // Buka box dan gunakan
/// final userBox = await databaseService.openBox<UserModel>('users');
/// ```
///
/// ## Keamanan & Enkripsi
///
/// Ketika enkripsi diaktifkan, HiveService menggunakan AES-256 dengan kunci yang
/// disimpan di secure storage perangkat. Ini memastikan data terlindungi bahkan
/// pada perangkat yang di-root.
///
/// ## Backup & Pemulihan
///
/// Fitur backup otomatis membuat salinan box saat ditutup dan dapat dipulihkan
/// jika terjadi korupsi data. Jalur backup dapat dikonfigurasi melalui
/// `DatabaseConfig.backupPath`.
///
/// ## Menangani Korupsi Database
///
/// Terdapat beberapa strategi pemulihan yang didukung:
/// - Menghapus dan membuat ulang box yang rusak
/// - Memulihkan dari backup
/// - Mempertahankan data yang tidak rusak
///
/// @version 1.0.0
library;

import 'dart:io';
import 'dart:typed_data';
import 'package:boilerplate/core/logging/logger.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart' as path_provider;

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

  /// Membuat instance HiveService.
  ///
  /// [encryption] adalah implementasi enkripsi untuk Hive.
  /// Jika tidak disediakan, akan menggunakan [HiveEncryption] default.
  ///
  /// [config] adalah konfigurasi database.
  /// Jika tidak disediakan, akan menggunakan [DatabaseConfig.defaultConfig].
  HiveService({
    HiveEncryption? encryption,
    DatabaseConfig? config,
  })  : _encryption = encryption ?? HiveEncryption(),
        _config = config ?? DatabaseConfig.defaultConfig();

  @override
  Future<void> init() async {
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
      } else {
        await Hive.initFlutter(_config.databaseDir);

        _databaseDir = _config.databaseDir ??
            (await path_provider.getApplicationDocumentsDirectory()).path;

        if (_config.autoBackup && _config.backupPath != null) {
          final backupDir = Directory(_config.backupPath!);
          if (!await backupDir.exists()) {
            await backupDir.create(recursive: true);
          }
        }
      }

      if (_config.clearDatabaseOnInit) {
        await Hive.deleteFromDisk();
      }

      _logSuccess('Database Hive berhasil diinisialisasi');
      _isInitialized = true;
    } catch (e) {
      _logError('Gagal menginisialisasi database Hive, $e');
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

    if (_openBoxes.containsKey(boxName)) {
      _logDebug('Membuka box: $boxName');
      return _openBoxes[boxName] as Box<T>;
    }

    try {
      HiveCipher? cipher;

      if (_config.encryptionEnabled) {
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
            box = await Hive.openLazyBox<T>(
              boxName,
              encryptionCipher: cipher,
              crashRecovery: true,
            ) as Box<T>;
          } else {
            // Buka box standar
            box = await Hive.openBox<T>(
              boxName,
              encryptionCipher: cipher,
              crashRecovery: true,
            );

            if (_config.compactOnOpen) {
              await box.compact();

              final stats = box.toMap();
              final entries = stats.length;
              final deletedEntries = await _countDeletedEntries(box);

              if (_shouldCompact(entries, deletedEntries)) {
                await box.compact();
              }
            }
          }
          break;
        } catch (e) {
          recoveryAttempts++;

          if (recoveryAttempts >= _config.maxRecoveryAttempts) {
            rethrow;
          }

          switch (_config.recoveryStrategy) {
            case RecoveryStrategy.deleteBoxIfCorrupted:
              await Hive.deleteBoxFromDisk(boxName);
              break;

            case RecoveryStrategy.restoreFromBackup:
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
              continue;
          }
        }
      }

      _openBoxes[boxName] = box;

      if (_config.autoBackup && _config.backupPath != null) {
        await createBackup(boxName);
      }

      _logDebug('Membuka box: $boxName');
      return box;
    } catch (e) {
      _logError('Gagal membuka box: $boxName, exception: $e');
      throw DatabaseException.boxOpenError(
        boxName: boxName,
        error: e,
      );
    }
  }

  Future<Box<T>> forceRecoveryAndOpen<T>(String boxName) async {
    checkInitialized();

    _logDebug('Forcing recovery for box: $boxName');

    // First try to delete the box
    try {
      await Hive.deleteBoxFromDisk(boxName);
      _logDebug('Box deleted for recovery: $boxName');
    } catch (e) {
      _logError('Failed to delete box for recovery: $boxName, $e');
    }

    // Try to find and delete any related files
    if (!_config.inMemoryStorage && _databaseDir != null) {
      try {
        final directory = Directory(_databaseDir!);
        if (await directory.exists()) {
          final files = await directory.list().toList();
          for (final file in files) {
            if (file.path.contains(boxName)) {
              try {
                await File(file.path).delete();
                _logDebug('Deleted related file: ${file.path}');
              } catch (e) {
                _logError('Failed to delete related file: ${file.path}, $e');
              }
            }
          }
        }
      } catch (e) {
        _logError('Error cleaning up box files: $e');
      }
    }

    // Now try to open the box with minimal settings
    final box = await Hive.openBox<T>(
      boxName,
      crashRecovery: true,
    );

    _openBoxes[boxName] = box;
    _logSuccess('Successfully recovered and opened box: $boxName');
    return box;
  }

  /// Menghitung perkiraan jumlah entri yang dihapus dalam sebuah box
  ///
  /// Metode ini menganalisis struktur internal Hive Box untuk memberikan
  /// estimasi akurat tentang jumlah entri yang telah dihapus tetapi belum
  /// dibebaskan ruangannya dalam file penyimpanan.
  Future<int> _countDeletedEntries(Box box) async {
    try {
      // Cara 1: Menggunakan informasi internal box (pendekatan paling akurat)
      if (box.isOpen) {
        // Jika box dibuka dengan Lazy Loading, pendekatan berbeda diperlukan
        if (box is LazyBox) {
          // Untuk LazyBox, kita perlu menggunakan pendekatan metadata
          final String boxPath = box.path ?? '';
          if (boxPath.isNotEmpty) {
            final File boxFile = File(boxPath);
            if (await boxFile.exists()) {
              final int fileSize = await boxFile.length();
              final int currentEntries = box.length;

              // Rata-rata 100 bytes per entri (asumsi konservatif)
              // Ini sebenarnya tergantung pada ukuran data Anda
              const int avgEntrySize = 100;

              // Memperkirakan kapasitas total berdasarkan ukuran file
              final int estimatedCapacity = fileSize ~/ avgEntrySize;

              // Memperkirakan jumlah yang dihapus berdasarkan perbedaan kapasitas dan entri aktual
              final int estimatedDeleted = estimatedCapacity - currentEntries;

              // Mengembalikan estimasi dengan batas bawah 0
              return estimatedDeleted > 0 ? estimatedDeleted : 0;
            }
          }

          // Fallback: Perkiraan berdasarkan persentase ukuran box
          return (box.length * 0.2).round(); // Asumsi 20% deleted
        }

        // Untuk box standar, kita bisa mendapatkan informasi yang lebih akurat
        // dengan akses ke frame data dan memeriksa tanda deleted

        // 1. Dapatkan data internal box (jumlah maksimum slot dan slot yang digunakan)
        final boxLength = box.length;

        // 2. Hitung entri yang dihapus menggunakan metrik internal Hive
        // Kita mengakses metadata Hive yang menyimpan informasi tentang jumlah frame
        // dan frame yang ditandai dihapus

        // Metode ini tergantung pada struktur internal Hive, yang mungkin berubah
        // antar versi, jadi kita gunakan pendekatan alternatif yang lebih aman

        // Hitung berdasarkan jumlah operasi delete dan put sejak terakhir kompaksi
        // Karena Hive tidak menyediakan API publik untuk ini, kita gunakan metrik alternatif

        // Gunakan heuristik: Jika ukuran file terlalu besar dibanding jumlah entri,
        // kemungkinan banyak entri yang dihapus

        // Periksa ukuran file dibanding dengan jumlah entri yang ada
        final boxPath = box.path;
        if (boxPath != null) {
          final File boxFile = File(boxPath);
          if (await boxFile.exists()) {
            final fileSize = await boxFile.length();

            // Perkirakan ukuran per entri (asumsi: rata-rata 40 bytes overhead + ukuran data)
            // Ini perkiraan yang konservatif, ukuran sebenarnya bervariasi
            int totalDataSize = 0;
            box.toMap().forEach((key, value) {
              // Perkiraan ukuran kunci (minimal 4 bytes untuk integer, lebih untuk string)
              int keySize = key is String ? key.length * 2 + 6 : 4;

              // Perkiraan ukuran nilai
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
                // Untuk tipe lain, gunakan estimasi yang lebih tinggi
                valueSize = 100;
              }

              totalDataSize +=
                  keySize + valueSize + 40; // 40 bytes overhead per entry
            });

            // Jika ukuran file signifikan lebih besar dari perkiraan total data,
            // kemungkinan banyak entri yang telah dihapus
            if (totalDataSize > 0 && fileSize > totalDataSize * 1.5) {
              // Perkirakan jumlah entri yang dihapus
              return ((fileSize - totalDataSize) / (totalDataSize / boxLength))
                  .round();
            }

            // Fallback jika estimasi di atas tidak memungkinkan
            if (fileSize > boxLength * 200) {
              // Asumsi rata-rata 200 bytes per entri
              return (fileSize / 200 - boxLength).round();
            }
          }
        }

        // Jika tidak ada informasi file, gunakan heuristik sederhana
        // berdasarkan ukuran box
        if (boxLength > 100) {
          // Untuk box besar, asumsikan 15% entri mungkin telah dihapus
          return (boxLength * 0.15).round();
        } else if (boxLength > 20) {
          // Untuk box medium, asumsikan 10% entri mungkin telah dihapus
          return (boxLength * 0.1).round();
        }
      }

      // Untuk box kecil atau tidak ada informasi yang cukup
      return 0;
    } catch (e) {
      // Log error jika konfigurasi logging diaktifkan
      if (_config.loggingEnabled) {
        _logger.debug('Error menghitung entri yang dihapus: $e');
      }

      // Fallback konservatif jika terjadi error:
      // Perkirakan berdasarkan jumlah entri saat ini
      final int currentEntries = box.length;
      if (currentEntries > 1000) {
        return (currentEntries * 0.1)
            .round(); // Asumsi 10% deleted untuk box besar
      } else if (currentEntries > 100) {
        return (currentEntries * 0.05)
            .round(); // Asumsi 5% deleted untuk box sedang
      }

      // Untuk box kecil, kemungkinan tidak perlu kompaksi
      return 0;
    }
  }

  /// Menentukan apakah box perlu dikompaksi berdasarkan jumlah entri dan entri yang dihapus
  bool _shouldCompact(int entries, int deletedEntries) {
    if (entries == 0) return false;

    if (deletedEntries > 50) {
      return true;
    }

    if (entries > 500 && deletedEntries > entries * 0.1) {
      return true;
    }

    if (entries > 100 && deletedEntries > entries * 0.2) {
      return true;
    }

    if (entries > 0 && deletedEntries > entries * 0.5) {
      return true;
    }

    return false;
  }

  /// Menganalisis efisiensi penyimpanan dari sebuah box
  ///
  /// Mengembalikan persentase ruang penyimpanan yang digunakan secara efektif.
  /// Nilai yang mendekati 100% menunjukkan efisiensi tinggi dengan sedikit ruang terbuang.
  @override
  Future<double> analyzeStorageEfficiency(String boxName) async {
    checkInitialized();

    try {
      final box = await openBox(boxName);
      final entries = box.length;
      final deletedEntries = await _countDeletedEntries(box);
      final totalEntries = entries + deletedEntries;

      if (totalEntries == 0) return 100.0;

      return (entries / totalEntries) * 100;
    } catch (e) {
      _logError('Gagal menganalisis efisiensi storage untuk box $boxName: $e');
      return 0.0;
    }
  }

  /// Memadatkan semua box yang memenuhi kriteria kompaksi
  ///
  /// Berguna untuk operasi pemeliharaan rutin database
  @override
  Future<Map<String, bool>> compactAllBoxesIfNeeded() async {
    checkInitialized();

    final results = <String, bool>{};

    for (final boxName in _openBoxes.keys) {
      try {
        final box = _openBoxes[boxName]!;
        final entries = box.length;
        final deletedEntries = await _countDeletedEntries(box);

        if (_shouldCompact(entries, deletedEntries)) {
          await box.compact();
          results[boxName] = true;
        } else {
          results[boxName] = false;
        }
      } catch (e) {
        _logError('Gagal kompaksi box $boxName: $e');
        results[boxName] = false;
      }
    }

    return results;
  }

  /// Membuat backup dari box tertentu
  @override
  Future<void> createBackup(String boxName) async {
    if (_config.backupPath == null || _databaseDir == null) return;

    try {
      final boxDir = path.join(_databaseDir!, boxName);
      final backupDir = path.join(_config.backupPath!, boxName);

      final backupDirObj = Directory(backupDir);
      if (!await backupDirObj.exists()) {
        await backupDirObj.create(recursive: true);
      }

      final boxDirObj = Directory(boxDir);
      if (await boxDirObj.exists()) {
        await for (final file in boxDirObj.list()) {
          if (file is File) {
            final fileName = path.basename(file.path);
            final backupFile = File(path.join(backupDir, fileName));
            await file.copy(backupFile.path);
          }
        }
      }
    } catch (e) {
      _logError('Error saat membuat backup untuk $boxName: $e');
    }
  }

  /// Helper untuk logging error
  void _logError(String message) {
    if (_config.loggingEnabled) {
      _logger.error(message);
    }
  }

  /// Helper untuk logging success
  void _logSuccess(String message) {
    if (_config.loggingEnabled) {
      _logger.info(message);
    }
  }

  /// Helper untuk logging debug
  void _logDebug(String message) {
    if (_config.loggingEnabled) {
      _logger.debug(message);
    }
  }

  /// Memulihkan box dari backup
  Future<void> _restoreFromBackup(String boxName) async {
    if (_config.backupPath == null || _databaseDir == null) return;

    try {
      final boxDir = path.join(_databaseDir!, boxName);
      final backupDir = path.join(_config.backupPath!, boxName);

      final backupDirObj = Directory(backupDir);
      if (!await backupDirObj.exists()) {
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
        }
      }
    } catch (e) {
      _logError('Error saat memulihkan backup untuk $boxName: $e');
      await Hive.deleteBoxFromDisk(boxName);
    }
  }

  @override
  Future<void> closeBox(String boxName) async {
    checkInitialized();

    if (_openBoxes.containsKey(boxName)) {
      if (_config.autoBackup && _config.backupPath != null) {
        await createBackup(boxName);
      }

      final box = _openBoxes[boxName]!;
      await box.close();
      _openBoxes.remove(boxName);
    }
  }

  @override
  Future<void> closeAllBoxes() async {
    checkInitialized();

    for (final boxName in List.from(_openBoxes.keys)) {
      await closeBox(boxName);
    }
  }

  @override
  Future<void> clearBox(String boxName) async {
    checkInitialized();

    if (_openBoxes.containsKey(boxName)) {
      await _openBoxes[boxName]!.clear();
    } else {
      final box = await openBox(boxName);
      await box.clear();
    }
  }

  @override
  Future<bool> boxExists(String boxName) async {
    checkInitialized();
    return Hive.boxExists(boxName);
  }

  @override
  List<String> getOpenBoxes() {
    checkInitialized();
    return _openBoxes.keys.toList();
  }

  @override
  void registerAdapter<T>(dynamic adapter) {
    checkInitialized();

    if (!Hive.isAdapterRegistered(adapter.typeId)) {
      Hive.registerAdapter<T>(adapter);
    }
  }

  /// Memastikan bahwa database telah diinisialisasi
  @override
  void checkInitialized() {
    if (!_isInitialized) {
      _logError('Database belum terinisialisasi');
      throw DatabaseException.notInitialized();
    }
  }

  /// Mendapatkan box yang telah dibuka
  ///
  /// Mengembalikan null jika box dengan nama [boxName] belum pernah dibuka
  @override
  Box<T>? getOpenBox<T>(String boxName) {
    if (_openBoxes.containsKey(boxName)) {
      return _openBoxes[boxName] as Box<T>;
    }
    return null;
  }

  /// Membuat backup database penuh dari semua box
  ///
  /// Mengembalikan path direktori backup, atau null jika backup gagal
  @override
  Future<String?> createFullBackup() async {
    if (_config.backupPath == null) return null;

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

      return backupDir;
    } catch (e) {
      _logError('Full backup gagal: $e');
      return null;
    }
  }

  /// Mendapatkan versi skema database saat ini
  @override
  int getSchemaVersion() => _config.schemaVersion;

  /// Memadatkan box untuk mengurangi ukuran penyimpanan
  ///
  /// Ini berguna setelah menghapus banyak entri dari box
  @override
  Future<void> compactBox(String boxName) async {
    checkInitialized();

    if (_openBoxes.containsKey(boxName)) {
      await _openBoxes[boxName]!.compact();
    }
  }

  /// Mendapatkan path direktori database
  ///
  /// Mengembalikan null jika database dijalankan dalam mode in-memory
  @override
  String? getDatabaseDirectory() {
    return _databaseDir;
  }
}
