import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';

import 'log_level.dart';
import 'log_entry.dart';
import 'log_filter.dart';
import 'log_formatter.dart';
import 'handlers/log_handler.dart';
import 'handlers/console_log_handler.dart';
import 'handlers/file_log_handler.dart';
import 'handlers/analytics_log_handler.dart';
import 'config/logger_config.dart';

class Logger {
  final String _tag;

  final List<LogHandler> _handlers = [];

  static Logger? _instance;

  static Logger get instance {
    _instance ??= Logger(
      config: LoggerConfig(
        tag: 'App',
        minLevel: kDebugMode ? LogLevel.debug : LogLevel.info,
        enableCloudflareDebug: false,
      ),
    );
    return _instance!;
  }

  static set instance(Logger logger) {
    _instance = logger;
  }

  Logger({
    required LoggerConfig config,
    List<LogHandler>? handlers,
  }) : _tag = config.tag {
    if (handlers != null && handlers.isNotEmpty) {
      _handlers.addAll(handlers);
    } else {
      if (config.printToConsole) {
        final levelFilter = LevelFilter(config.minLevel);
        final cloudflareFilter = CloudflareFilter(config.enableCloudflareDebug);
        final compositeFilter =
            CompositeFilter([levelFilter, cloudflareFilter]);

        _handlers.add(ConsoleLogHandler(
          filter: compositeFilter,
          formatter: DetailedLogFormatter(timeFormat: config.timeFormat),
        ));
      }

      if (config.fileConfig.enabled) {
        _handlers.add(FileLogHandler(
          filter: LevelFilter(LogLevel.info),
          formatter: DetailedLogFormatter(
            timeFormat: config.timeFormat,
            forFile: true,
          ),
          config: config.fileConfig,
        ));
      }

      if (config.analyticsConfig.enabled &&
          config.analyticsConfig.sendToAnalytics != null) {
        _handlers.add(AnalyticsLogHandler(
          filter: LevelFilter(config.analyticsConfig.minLevel),
          config: config.analyticsConfig,
        ));
      }
    }
  }

  void debug(String message, {String? domain, Map<String, dynamic>? metadata}) {
    _log(LogLevel.debug, message, domain: domain, metadata: metadata);
  }
  void info(String message, {String? domain, Map<String, dynamic>? metadata}) {
    _log(LogLevel.info, message, domain: domain, metadata: metadata);
  }

  void warn(String message, {String? domain, Map<String, dynamic>? metadata}) {
    _log(LogLevel.warning, message, domain: domain, metadata: metadata);
  }

  void error(
    String message, {
    String? domain,
    Object? exception,
    StackTrace? stackTrace,
    Map<String, dynamic>? metadata,
  }) {
    final combinedMetadata = <String, dynamic>{
      if (metadata != null) ...metadata,
      if (exception != null) 'exception': exception.toString(),
    };

    _log(
      LogLevel.error,
      message,
      domain: domain,
      exception: exception,
      stackTrace: stackTrace,
      metadata: combinedMetadata,
    );
  }

  void critical(
    String message, {
    String? domain,
    Object? exception,
    StackTrace? stackTrace,
    Map<String, dynamic>? metadata,
  }) {
    final combinedMetadata = <String, dynamic>{
      if (metadata != null) ...metadata,
      if (exception != null) 'exception': exception.toString(),
    };

    _log(
      LogLevel.critical,
      message,
      domain: domain,
      exception: exception,
      stackTrace: stackTrace,
      metadata: combinedMetadata,
    );
  }

  Future<void> _log(
    LogLevel level,
    String message, {
    String? domain,
    Object? exception,
    StackTrace? stackTrace,
    Map<String, dynamic>? metadata,
  }) async {
    final entry = LogEntry(
      level: level,
      message: message,
      tag: _tag,
      domain: domain,
      exception: exception,
      stackTrace: stackTrace,
      metadata: metadata,
    );

    for (final handler in _handlers) {
      await handler.tryHandle(entry);
    }
  }

  Logger withTag(String tag) {
    return Logger(
      config: LoggerConfig(tag: tag),
      handlers: _handlers,
    );
  }

  void addHandler(LogHandler handler) {
    _handlers.add(handler);
  }

  void removeHandler(LogHandler handler) {
    _handlers.remove(handler);
  }

  Future<void> clearHandlers() async {
    for (final handler in _handlers) {
      await handler.dispose();
    }
    _handlers.clear();
  }
  Future<void> dispose() async {
    await clearHandlers();
  }

  FileLogHandler? get fileHandler {
    return _handlers.whereType<FileLogHandler>().firstOrNull;
  }

  Future<void> clearLogs() async {
    final fileHandler = this.fileHandler;
    if (fileHandler != null) {
      await fileHandler.clearLogs();
    }
  }

  Future<List<File>> getLogFiles() async {
    final fileHandler = this.fileHandler;
    if (fileHandler != null) {
      return fileHandler.getLogFiles();
    }
    return [];
  }
}
