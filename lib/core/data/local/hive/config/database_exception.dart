class DatabaseException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  const DatabaseException({
    required this.message,
    this.code,
    this.originalError,
  });

  @override
  String toString() {
    return 'DatabaseException: $message${code != null ? ' (Code: $code)' : ''}';
  }

  factory DatabaseException.notInitialized() => const DatabaseException(
        message: 'Database has not been initialized',
        code: 'DB_NOT_INITIALIZED',
      );

  factory DatabaseException.boxOpenError({
    required String boxName,
    required dynamic error,
  }) =>
      DatabaseException(
        message: 'Failed to open box "$boxName"',
        code: 'BOX_OPEN_ERROR',
        originalError: error,
      );

  factory DatabaseException.encryptionError({
    required String message,
    dynamic error,
  }) =>
      DatabaseException(
        message: message,
        code: 'ENCRYPTION_ERROR',
        originalError: error,
      );
}
