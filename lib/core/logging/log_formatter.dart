import 'dart:convert';
import 'package:intl/intl.dart';

import 'log_entry.dart';
import 'log_level.dart';

abstract class LogFormatter {
  String format(LogEntry entry);
}

class SimpleLogFormatter implements LogFormatter {
  final DateFormat _dateFormat;

  SimpleLogFormatter({String timeFormat = 'yyyy-MM-dd HH:mm:ss.SSS'})
      : _dateFormat = DateFormat(timeFormat);

  @override
  String format(LogEntry entry) {
    final buffer = StringBuffer();

    final timestamp = _dateFormat.format(entry.timestamp);
    final prefixTag = entry.tag;
    final prefixDomain = entry.domain != null ? '[${entry.domain}]' : '';

    buffer.write(
        '$timestamp [$prefixTag]$prefixDomain [${entry.level.name}] ${entry.level.icon} ${entry.message}');

    return buffer.toString();
  }
}

class DetailedLogFormatter implements LogFormatter {
  final DateFormat _dateFormat;

  final bool forFile;

  DetailedLogFormatter({
    String timeFormat = 'yyyy-MM-dd HH:mm:ss.SSS',
    this.forFile = false,
  }) : _dateFormat = DateFormat(timeFormat);

  @override
  String format(LogEntry entry) {
    final buffer = StringBuffer();

    final timestamp = _dateFormat.format(entry.timestamp);
    final prefixTag = entry.tag;
    final prefixDomain = entry.domain != null ? '[${entry.domain}]' : '';
    final levelIcon = forFile ? '' : '${entry.level.icon} ';
    final ansiColor = forFile ? '' : entry.level.ansiColor;
    final ansiReset = forFile ? '' : LogLevel.ansiReset;

    buffer.write(
        '$ansiColor$timestamp [$prefixTag]$prefixDomain [${entry.level.name}] $levelIcon${entry.message}$ansiReset\n');

    if (entry.metadata != null && entry.metadata!.isNotEmpty) {
      buffer.write(
          '$ansiColor  ➤ Metadata: ${jsonEncode(entry.metadata)}$ansiReset\n');
    }

    if (entry.exception != null) {
      buffer.write('$ansiColor  ➤ Exception: ${entry.exception}$ansiReset\n');
    }

    if (entry.stackTrace != null) {
      buffer
          .write('$ansiColor  ➤ StackTrace:\n${entry.stackTrace}$ansiReset\n');
    }

    return buffer.toString();
  }
}

class JsonLogFormatter implements LogFormatter {
  @override
  String format(LogEntry entry) {
    return jsonEncode(entry.toMap());
  }
}
