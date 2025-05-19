/// Modul enkripsi untuk database Hive
///
/// Modul ini menyediakan fungsi-fungsi untuk mengelola enkripsi database Hive,
/// termasuk pembuatan, penyimpanan, dan pengambilan kunci enkripsi secara aman.
/// Menggunakan algoritma AES-256 yang disediakan oleh Hive dan FlutterSecureStorage
/// untuk menyimpan kunci enkripsi secara aman.
///
/// Fitur utama:
/// - Mengambil kunci enkripsi dari penyimpanan aman atau membuatnya jika belum ada
/// - Membuat HiveAesCipher menggunakan kunci enkripsi
/// - Menghapus kunci enkripsi dari penyimpanan aman
///
/// Penggunaan:
/// ```dart
/// final encryptionService = HiveEncryption();
/// final encryptionKey = await encryptionService.getEncryptionKey('my_secure_key');
/// final cipher = encryptionService.createCipher(encryptionKey);
///
/// // Kemudian gunakan cipher saat membuka box
/// final box = await Hive.openBox('encrypted_box', encryptionCipher: cipher);
/// ```
library;

import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive/hive.dart';

import 'config/database_exception.dart';

/// Pengelola enkripsi untuk database Hive.
///
/// Kelas ini bertanggung jawab untuk mengelola kunci enkripsi yang digunakan
/// oleh Hive untuk mengenkripsi dan mendekripsi data database.
class HiveEncryption {
  final FlutterSecureStorage _secureStorage;

  HiveEncryption({
    FlutterSecureStorage? secureStorage,
  }) : _secureStorage = secureStorage ?? const FlutterSecureStorage();

  /// Mengambil atau menghasilkan kunci enkripsi untuk digunakan dengan HiveAesCipher.
  ///
  /// [keyName] adalah identifikasi unik untuk kunci dalam penyimpanan aman.
  ///
  /// Metode ini akan mencari kunci di penyimpanan aman terlebih dahulu.
  /// Jika kunci ditemukan, akan didekode dan dikembalikan.
  /// Jika kunci tidak ditemukan, kunci baru akan dibuat secara aman,
  /// disimpan di penyimpanan aman, dan kemudian dikembalikan.
  ///
  /// Throws [DatabaseException] jika terjadi kesalahan dalam pembuatan
  /// atau pengambilan kunci enkripsi.
  ///
  /// Returns kunci enkripsi sebagai [List<int>].
  Future<List<int>> getEncryptionKey(String keyName) async {
    try {
      final existingKeyEncoded = await _secureStorage.read(key: keyName);

      if (existingKeyEncoded != null) {
        return base64Decode(existingKeyEncoded);
      } else {
        final key = Hive.generateSecureKey();
        await _secureStorage.write(
          key: keyName,
          value: base64Encode(key),
        );
        return key;
      }
    } catch (e) {
      throw DatabaseException.encryptionError(
        message: 'Gagal mendapatkan atau membuat kunci enkripsi',
        error: e,
      );
    }
  }

  /// Membuat instance HiveAesCipher menggunakan kunci yang disediakan.
  ///
  /// [key] adalah kunci enkripsi yang akan digunakan.
  ///
  /// Returns [HiveCipher] yang akan digunakan saat membuka box Hive.
  HiveCipher createCipher(Uint8List key) {
    return HiveAesCipher(key);
  }

  /// Menghapus kunci enkripsi dari penyimpanan aman.
  ///
  /// [keyName] adalah identifikasi unik kunci yang akan dihapus.
  ///
  /// Metode ini berguna untuk reset enkripsi atau menghapus data sensitif.
  ///
  /// Throws [DatabaseException] jika terjadi kesalahan dalam proses penghapusan.
  Future<void> deleteEncryptionKey(String keyName) async {
    try {
      await _secureStorage.delete(key: keyName);
    } catch (e) {
      throw DatabaseException.encryptionError(
        message: 'Gagal menghapus kunci enkripsi',
        error: e,
      );
    }
  }
}
