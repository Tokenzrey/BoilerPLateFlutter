enum LogLevel {
  debug,
  info,
  warning,
  error,
  critical;

  String get name => toString().split('.').last.toUpperCase();

  String get icon {
    switch (this) {
      case LogLevel.debug:
        return '🔍';
      case LogLevel.info:
        return '📢';
      case LogLevel.warning:
        return '⚠️';
      case LogLevel.error:
        return '❌';
      case LogLevel.critical:
        return '💀';
    }
  }

  String get ansiColor {
    switch (this) {
      case LogLevel.debug:
        return '\x1B[37m';
      case LogLevel.info:
        return '\x1B[32m';
      case LogLevel.warning:
        return '\x1B[33m';
      case LogLevel.error:
        return '\x1B[31m';
      case LogLevel.critical:
        return '\x1B[35m';
    }
  }

  static const String ansiReset = '\x1B[0m';
}
