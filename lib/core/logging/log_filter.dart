import 'log_entry.dart';
import 'log_level.dart';

abstract class LogFilter {
  bool shouldLog(LogEntry entry);
}

class LevelFilter implements LogFilter {
  final LogLevel minLevel;

  LevelFilter(this.minLevel);

  @override
  bool shouldLog(LogEntry entry) {
    return entry.level.index >= minLevel.index;
  }
}

class CloudflareFilter implements LogFilter {
  final bool enabled;

  CloudflareFilter(this.enabled);

  @override
  bool shouldLog(LogEntry entry) {
    if (!enabled &&
        entry.domain == 'Cloudflare' &&
        entry.level == LogLevel.debug) {
      return false;
    }
    return true;
  }
}

class CompositeFilter implements LogFilter {
  final List<LogFilter> filters;

  CompositeFilter(this.filters);

  @override
  bool shouldLog(LogEntry entry) {
    for (final filter in filters) {
      if (!filter.shouldLog(entry)) {
        return false;
      }
    }
    return true;
  }
}
