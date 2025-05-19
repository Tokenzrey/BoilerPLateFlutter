/// Database Configuration
///
/// Library ini menyediakan konfigurasi lengkap untuk database Hive
/// yang dapat disesuaikan untuk berbagai kebutuhan aplikasi:
///
/// - Konfigurasi enkripsi data untuk keamanan
/// - Pengoptimalan performa dengan lazy loading
/// - Mekanisme backup dan pemulihan otomatis
/// - Strategi penanganan korupsi data
/// - Pengaturan kompresi untuk menghemat ruang penyimpanan
/// - Mode penyimpanan in-memory untuk testing
///
/// Contoh penggunaan:
/// ```dart
/// // Konfigurasi untuk lingkungan produksi
/// final dbConfig = DatabaseConfig.defaultConfig();
///
/// // Konfigurasi untuk pengujian
/// final testConfig = DatabaseConfig.test();
///
/// // Konfigurasi khusus dengan parameter yang disesuaikan
/// final customConfig = DatabaseConfig(
///   encryptionEnabled: true,
///   lazyBoxMode: true,
///   compressionLevel: 3,
/// );
/// ```
library;

import 'package:flutter/foundation.dart';
import 'package:equatable/equatable.dart';
import 'package:boilerplate/constants/strings.dart';

enum RecoveryStrategy {
  recoverAndDeleteCorruptedData,
  deleteBoxIfCorrupted,
  restoreFromBackup,
  throwException,
}

/// Konfigurasi inisialisasi database
///
/// Kelas ini menyediakan berbagai opsi konfigurasi untuk mengontrol perilaku
/// database Hive, termasuk enkripsi, performa, backup, dan strategi pemulihan.
@immutable
class DatabaseConfig extends Equatable {
  final String? databaseDir;
  final bool encryptionEnabled;
  final String encryptionKeyName;
  final List<int>? encryptionKey;
  final bool clearDatabaseOnInit;
  final bool lazyBoxMode;
  final int? maxSizePerBox;
  final bool inMemoryStorage;
  final int compressionLevel;
  final bool compactOnOpen;
  final RecoveryStrategy recoveryStrategy;
  final int maxRecoveryAttempts;
  final bool loggingEnabled;
  final bool readOnly;
  final String? backupPath;
  final bool autoBackup;
  final int schemaVersion;

  const DatabaseConfig({
    this.databaseDir,
    this.encryptionEnabled = false,
    this.encryptionKeyName = Strings.hiveEncryptionToken,
    this.encryptionKey,
    this.clearDatabaseOnInit = false,
    this.lazyBoxMode = false,
    this.maxSizePerBox,
    this.inMemoryStorage = false,
    this.compressionLevel = 0,
    this.compactOnOpen = false,
    this.recoveryStrategy = RecoveryStrategy.deleteBoxIfCorrupted,
    this.maxRecoveryAttempts = 3,
    this.loggingEnabled = false,
    this.readOnly = false,
    this.backupPath,
    this.autoBackup = false,
    this.schemaVersion = 1,
  });

  /// Konfigurasi default untuk lingkungan produksi
  ///
  /// Menggunakan enkripsi, lazy loading, dan strategi pemulihan yang aman
  factory DatabaseConfig.defaultConfig() => const DatabaseConfig(
        encryptionEnabled: true,
        encryptionKeyName: Strings.hiveEncryptionToken,
        lazyBoxMode: true,
        compressionLevel: 1,
        compactOnOpen: true,
        recoveryStrategy: RecoveryStrategy.deleteBoxIfCorrupted,
        loggingEnabled: false,
      );

  /// Konfigurasi pengujian untuk unit/integration tests
  ///
  /// Menggunakan penyimpanan in-memory dan menghapus database pada inisialisasi
  factory DatabaseConfig.test() => const DatabaseConfig(
        encryptionEnabled: false,
        clearDatabaseOnInit: true,
        inMemoryStorage: true,
        compressionLevel: 0,
        loggingEnabled: true,
        schemaVersion: 0,
      );

  /// Konfigurasi pengembangan dengan logging tapi tanpa enkripsi
  factory DatabaseConfig.development() => const DatabaseConfig(
        encryptionEnabled: false,
        lazyBoxMode: false,
        compressionLevel: 0,
        compactOnOpen: false,
        loggingEnabled: true,
        autoBackup: true,
      );

  /// Konfigurasi keamanan tinggi dengan proteksi maksimum
  factory DatabaseConfig.secure() => const DatabaseConfig(
        encryptionEnabled: true,
        encryptionKeyName: Strings.hiveSecureEncryptionToken,
        compressionLevel: 9,
        compactOnOpen: true,
        recoveryStrategy: RecoveryStrategy.deleteBoxIfCorrupted,
        autoBackup: true,
      );

  /// Konfigurasi yang dioptimalkan untuk performa
  factory DatabaseConfig.performance() => DatabaseConfig(
        encryptionEnabled: false,
        lazyBoxMode: true,
        maxSizePerBox: 10000,
        compressionLevel: 0,
        compactOnOpen: false,
        recoveryStrategy: RecoveryStrategy.recoverAndDeleteCorruptedData,
      );

  /// Membuat salinan konfigurasi ini dengan properti yang dimodifikasi
  DatabaseConfig copyWith({
    String? databaseDir,
    bool? encryptionEnabled,
    String? encryptionKeyName,
    List<int>? encryptionKey,
    bool? clearDatabaseOnInit,
    bool? lazyBoxMode,
    int? maxSizePerBox,
    bool? inMemoryStorage,
    int? compressionLevel,
    bool? compactOnOpen,
    RecoveryStrategy? recoveryStrategy,
    int? maxRecoveryAttempts,
    bool? loggingEnabled,
    bool? readOnly,
    String? backupPath,
    bool? autoBackup,
    int? schemaVersion,
  }) {
    return DatabaseConfig(
      databaseDir: databaseDir ?? this.databaseDir,
      encryptionEnabled: encryptionEnabled ?? this.encryptionEnabled,
      encryptionKeyName: encryptionKeyName ?? this.encryptionKeyName,
      encryptionKey: encryptionKey ?? this.encryptionKey,
      clearDatabaseOnInit: clearDatabaseOnInit ?? this.clearDatabaseOnInit,
      lazyBoxMode: lazyBoxMode ?? this.lazyBoxMode,
      maxSizePerBox: maxSizePerBox ?? this.maxSizePerBox,
      inMemoryStorage: inMemoryStorage ?? this.inMemoryStorage,
      compressionLevel: compressionLevel ?? this.compressionLevel,
      compactOnOpen: compactOnOpen ?? this.compactOnOpen,
      recoveryStrategy: recoveryStrategy ?? this.recoveryStrategy,
      maxRecoveryAttempts: maxRecoveryAttempts ?? this.maxRecoveryAttempts,
      loggingEnabled: loggingEnabled ?? this.loggingEnabled,
      readOnly: readOnly ?? this.readOnly,
      backupPath: backupPath ?? this.backupPath,
      autoBackup: autoBackup ?? this.autoBackup,
      schemaVersion: schemaVersion ?? this.schemaVersion,
    );
  }

  /// Validasi konfigurasi
  ///
  /// Memeriksa apakah kombinasi pengaturan valid dan memberikan peringatan jika ada masalah
  void validate() {
    assert(!inMemoryStorage || backupPath == null,
        'Backup tidak tersedia untuk penyimpanan in-memory');

    assert(compressionLevel >= 0 && compressionLevel <= 9,
        'Level kompresi harus antara 0-9');

    assert(!readOnly || !autoBackup,
        'Backup otomatis tidak dapat diaktifkan dalam mode hanya-baca');
  }

  @override
  List<Object?> get props => [
        databaseDir,
        encryptionEnabled,
        encryptionKeyName,
        encryptionKey,
        clearDatabaseOnInit,
        lazyBoxMode,
        maxSizePerBox,
        inMemoryStorage,
        compressionLevel,
        compactOnOpen,
        recoveryStrategy,
        maxRecoveryAttempts,
        loggingEnabled,
        readOnly,
        backupPath,
        autoBackup,
        schemaVersion,
      ];

  @override
  String toString() => 'DatabaseConfig('
      'encryptionEnabled: $encryptionEnabled, '
      'lazyBoxMode: $lazyBoxMode, '
      'compressionLevel: $compressionLevel, '
      'schemaVersion: $schemaVersion)';
}
