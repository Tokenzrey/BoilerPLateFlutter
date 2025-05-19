import 'dart:async';
import 'package:flutter/foundation.dart';

import '../log_entry.dart';
import '../log_formatter.dart';
import '../log_filter.dart';
import '../log_level.dart';
import '../config/analytics_config.dart';
import 'log_handler.dart';

class AnalyticsLogHandler extends LogHandler {
  final AnalyticsConfig config;

  AnalyticsLogHandler({
    LogFilter? filter,
    LogFormatter? formatter,
    required this.config,
  }) : super(
          filter: filter ?? LevelFilter(LogLevel.error),
          formatter: formatter ?? JsonLogFormatter(),
        );

  @override
  Future<void> handle(LogEntry entry) async {
    if (!config.enabled || config.sendToAnalytics == null) return;

    try {
      await config.sendToAnalytics!(
        entry.level,
        entry.message,
        entry.toMap(),
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('AnalyticsLogHandler: Gagal mengirim log ke analitik: $e');
      }
    }
  }

  @override
  Future<void> dispose() async {
    
  }
}
