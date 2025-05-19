class FileLogConfig {
  final bool enabled;
  final int maxFileSize;
  final int maxFiles;
  final String fileName;

  const FileLogConfig({
    this.enabled = false,
    this.maxFileSize = 5 * 1024 * 1024,
    this.maxFiles = 3,
    this.fileName = 'app_logs',
  });

  FileLogConfig copyWith({
    bool? enabled,
    int? maxFileSize,
    int? maxFiles,
    String? fileName,
  }) {
    return FileLogConfig(
      enabled: enabled ?? this.enabled,
      maxFileSize: maxFileSize ?? this.maxFileSize,
      maxFiles: maxFiles ?? this.maxFiles,
      fileName: fileName ?? this.fileName,
    );
  }
}
