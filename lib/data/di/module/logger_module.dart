import 'package:boilerplate/constants/strings.dart';
import 'package:boilerplate/core/logging/config/analytics_config.dart';
import 'package:boilerplate/core/logging/config/file_config.dart';
import 'package:boilerplate/core/logging/config/logger_config.dart';
import 'package:boilerplate/core/logging/log_level.dart';
import 'package:boilerplate/core/logging/logger.dart';
import 'package:boilerplate/di/service_locator.dart';
import 'package:flutter/foundation.dart';

/// Modul untuk konfigurasi sistem logging
class LoggerModule {
  static final _loggerConfig = LoggerConfig(
    tag: Strings.appName,
    minLevel: kDebugMode ? LogLevel.debug : LogLevel.info,
    timeFormat: 'yyyy-MM-dd HH:mm:ss.SSS',
    fileConfig: const FileLogConfig(
      enabled: true,
      fileName: 'app_logs',
    ),
    analyticsConfig: const AnalyticsConfig(
      enabled: false,
    ),
  );

  /// Mengkonfigurasi injeksi dependensi untuk sistem logging
  static Future<void> configureLoggingInjection() async {
    // Set logger instance
    Logger.instance = Logger(config: _loggerConfig);

    getIt.registerLazySingleton<Logger>(() => Logger.instance);
  }
}
