/// Database Service
///
/// Interface umum untuk layanan basis data yang menyediakan abstraksi
/// dari teknologi penyimpanan yang mendasarinya. Interface ini memungkinkan
/// aplikasi untuk berinteraksi dengan basis data tanpa tergantung pada
/// implementasi spesifik seperti Hive, SQLite, atau lainnya.
///
/// Abstraksi ini memfasilitasi:
/// - Independensi aplikasi dari teknologi basis data tertentu
/// - Kemudahan dalam melakukan pengujian dengan mock database
/// - Penerapan prinsip Dependency Inversion dalam Clean Architecture
/// - Konsistensi antarmuka untuk operasi basis data di seluruh aplikasi
///
/// Implementasi interface ini harus menangani:
/// - Inisialisasi dan penutupan koneksi basis data
/// - Pembuatan dan manajemen box/koleksi data
/// - Registrasi adapter untuk tipe data kustom
/// - Backup dan pemulihan data
/// - Manajemen performa seperti kompaksi dan optimasi penyimpanan
/// - Penanganan kesalahan secara konsisten
///
/// Contoh penggunaan dalam aplikasi:
/// ```dart
/// final DatabaseService db = serviceLocator.get<DatabaseService>();
/// await db.init();
/// final userBox = await db.openBox<UserModel>('users');
/// ```
library;

/// Kontrak abstrak untuk implementasi layanan basis data.
abstract class DatabaseService {
  /// Menginisialisasi layanan basis data dengan konfigurasi yang ditentukan.
  ///
  /// Metode ini harus dipanggil sebelum menggunakan metode lain dari layanan ini.
  /// Implementasi dapat melakukan pengaturan awal seperti:
  /// - Menentukan direktori penyimpanan
  /// - Mengonfigurasi enkripsi
  /// - Mempersiapkan logging
  ///
  /// @throws DatabaseException jika terjadi kesalahan saat inisialisasi.
  Future<void> init();

  /// Membuka box/koleksi baru atau yang sudah ada dengan nama tertentu.
  ///
  /// Jenis T menentukan tipe objek yang akan disimpan di dalam box.
  /// Jika box sudah terbuka, implementasi harus mengembalikan referensi
  /// ke box yang ada, bukan membuka instance baru.
  ///
  /// @param boxName Nama unik dari box yang akan dibuka
  /// @return Box/koleksi tipe T yang telah dibuka
  /// @throws DatabaseException jika box tidak dapat dibuka
  Future<dynamic> openBox<T>(String boxName);

  /// Menutup box/koleksi tertentu untuk menghemat sumber daya.
  ///
  /// Setelah box ditutup, referensi yang ada mungkin tidak valid lagi
  /// dan operasi pada box tersebut dapat menghasilkan kesalahan.
  ///
  /// @param boxName Nama box yang akan ditutup
  /// @throws DatabaseException jika terjadi kesalahan saat menutup box
  Future<void> closeBox(String boxName);

  /// Menutup semua box/koleksi yang saat ini terbuka.
  ///
  /// Berguna ketika aplikasi akan dihentikan atau membebaskan sumber daya.
  ///
  /// @throws DatabaseException jika terjadi kesalahan saat menutup box
  Future<void> closeAllBoxes();

  /// Menghapus semua data dari box/koleksi tetapi mempertahankan box itu sendiri.
  ///
  /// @param boxName Nama box yang akan dibersihkan
  /// @throws DatabaseException jika box tidak ada atau tidak dapat dibersihkan
  Future<void> clearBox(String boxName);

  /// Memeriksa apakah box/koleksi dengan nama tertentu sudah ada.
  ///
  /// @param boxName Nama box yang akan diperiksa
  /// @return true jika box ada, false jika tidak
  /// @throws DatabaseException jika terjadi kesalahan saat memeriksa
  Future<bool> boxExists(String boxName);

  /// Mendapatkan nama-nama semua box/koleksi yang saat ini terbuka.
  ///
  /// @return Daftar nama box/koleksi yang terbuka
  /// @throws DatabaseException jika database belum diinisialisasi
  List<String> getOpenBoxes();

  /// Mendaftarkan adapter untuk tipe kustom agar bisa diserialisasi dan disimpan.
  ///
  /// Adapter biasanya diperlukan untuk tipe data kompleks
  /// seperti model dalam aplikasi.
  ///
  /// @param adapter Adapter tipe yang akan didaftarkan
  /// @throws DatabaseException jika adapter gagal didaftarkan
  void registerAdapter<T>(dynamic adapter);

  /// Memastikan bahwa database telah diinisialisasi sebelum melakukan operasi.
  ///
  /// Metode ini harus dipanggil oleh metode lain dalam implementasi
  /// sebelum melakukan operasi pada database untuk memastikan
  /// database dalam keadaan siap digunakan.
  ///
  /// @throws DatabaseException jika database belum diinisialisasi
  void checkInitialized();

  /// Membuat backup dari box tertentu ke lokasi yang dikonfigurasi.
  ///
  /// Metode ini membuat salinan fisik data box ke lokasi backup
  /// yang telah dikonfigurasi sebelumnya.
  ///
  /// @param boxName Nama box yang akan dibackup
  /// @throws DatabaseException jika terjadi kesalahan saat proses backup
  Future<void> createBackup(String boxName);

  /// Mengambil referensi ke box yang sudah dibuka sebelumnya.
  ///
  /// Berbeda dengan openBox, metode ini tidak membuka box baru
  /// melainkan hanya mengembalikan referensi jika box sudah terbuka.
  ///
  /// @param boxName Nama box yang dicari
  /// @return Box jika sudah terbuka, null jika belum
  /// @throws DatabaseException jika database belum diinisialisasi
  dynamic getOpenBox<T>(String boxName);

  /// Memadatkan/mengompaksi box untuk mengurangi ukuran penyimpanan.
  ///
  /// Proses ini menghapus ruang yang tidak digunakan setelah
  /// penghapusan data secara berulang.
  ///
  /// @param boxName Nama box yang akan dikompaksi
  /// @throws DatabaseException jika terjadi kesalahan saat kompaksi
  Future<void> compactBox(String boxName);

  /// Membuat backup penuh dari seluruh database.
  ///
  /// Metode ini membuat salinan dari semua box yang terdaftar
  /// ke lokasi backup yang sudah ditentukan.
  ///
  /// @return Path direktori tempat backup disimpan, atau null jika gagal
  /// @throws DatabaseException jika terjadi kesalahan saat backup
  Future<String?> createFullBackup();

  /// Mendapatkan versi skema database saat ini.
  ///
  /// Berguna untuk melakukan migrasi data dan mengelola
  /// kompatibilitas antar versi aplikasi.
  ///
  /// @return Nomor versi skema database
  int getSchemaVersion();

  /// Mendapatkan path direktori fisik tempat database disimpan.
  ///
  /// @return Path direktori database, atau null jika dalam mode in-memory
  String? getDatabaseDirectory();

  /// Menganalisis efisiensi penyimpanan dari sebuah box.
  ///
  /// @param boxName Nama box yang akan dianalisis
  /// @return Persentase efisiensi penyimpanan (0-100%)
  /// @throws DatabaseException jika terjadi kesalahan saat analisis
  Future<double> analyzeStorageEfficiency(String boxName);

  /// Memadatkan semua box yang memenuhi kriteria kompaksi.
  ///
  /// @return Map yang berisi nama box dan status kompaksi (true jika dikompaksi)
  /// @throws DatabaseException jika terjadi kesalahan saat proses kompaksi
  Future<Map<String, bool>> compactAllBoxesIfNeeded();
}
