import 'package:flutter/foundation.dart';

import '../log_entry.dart';
import '../log_formatter.dart';
import '../log_filter.dart';
import '../log_level.dart';
import 'log_handler.dart';

class ConsoleLogHandler extends LogHandler {
  ConsoleLogHandler({
    LogFilter? filter,
    LogFormatter? formatter,
  }) : super(
          filter: filter ??
              LevelFilter(kDebugMode ? LogLevel.debug : LogLevel.info),
          formatter: formatter ?? DetailedLogFormatter(),
        );

  @override
  Future<void> handle(LogEntry entry) async {
    final formattedLog = formatter.format(entry);
    debugPrint(formattedLog);
  }

  @override
  Future<void> dispose() async {
  }
}
