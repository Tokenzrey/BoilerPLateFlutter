import '../log_level.dart';
import 'file_config.dart';
import 'analytics_config.dart';

class LoggerConfig {
  final String tag;
  final LogLevel minLevel;
  final String timeFormat;
  final bool enableCloudflareDebug;
  final bool printToConsole;
  final FileLogConfig fileConfig;
  final AnalyticsConfig analyticsConfig;

  const LoggerConfig({
    this.tag = 'App',
    this.minLevel = LogLevel.debug,
    this.timeFormat = 'yyyy-MM-dd HH:mm:ss.SSS',
    this.enableCloudflareDebug = false,
    this.printToConsole = true,
    this.fileConfig = const FileLogConfig(),
    this.analyticsConfig = const AnalyticsConfig(),
  });

  factory LoggerConfig.development() => const LoggerConfig(
        minLevel: LogLevel.debug,
        enableCloudflareDebug: false,
        printToConsole: true,
        fileConfig: FileLogConfig(enabled: true),
      );

  factory LoggerConfig.production() => const LoggerConfig(
        minLevel: LogLevel.info,
        enableCloudflareDebug: false,
        printToConsole: false,
        fileConfig: FileLogConfig(
          enabled: true,
          maxFileSize: 10 * 1024 * 1024, 
          maxFiles: 5,
        ),
        analyticsConfig: AnalyticsConfig(
          enabled: true,
          minLevel: LogLevel.error,
        ),
      );

  factory LoggerConfig.test() => const LoggerConfig(
        minLevel: LogLevel.debug,
        printToConsole: true,
        fileConfig: FileLogConfig(enabled: false),
        analyticsConfig: AnalyticsConfig(enabled: false),
      );

  LoggerConfig copyWith({
    String? tag,
    LogLevel? minLevel,
    String? timeFormat,
    bool? enableCloudflareDebug,
    bool? printToConsole,
    FileLogConfig? fileConfig,
    AnalyticsConfig? analyticsConfig,
  }) {
    return LoggerConfig(
      tag: tag ?? this.tag,
      minLevel: minLevel ?? this.minLevel,
      timeFormat: timeFormat ?? this.timeFormat,
      enableCloudflareDebug:
          enableCloudflareDebug ?? this.enableCloudflareDebug,
      printToConsole: printToConsole ?? this.printToConsole,
      fileConfig: fileConfig ?? this.fileConfig,
      analyticsConfig: analyticsConfig ?? this.analyticsConfig,
    );
  }
}
