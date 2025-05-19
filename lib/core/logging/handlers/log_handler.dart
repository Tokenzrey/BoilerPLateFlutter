import '../log_entry.dart';
import '../log_formatter.dart';
import '../log_filter.dart';

abstract class LogHandler {
  final LogFilter filter;

  final LogFormatter formatter;

  LogHandler({
    required this.filter,
    required this.formatter,
  });

  Future<void> handle(LogEntry entry);

  Future<void> tryHandle(LogEntry entry) async {
    if (filter.shouldLog(entry)) {
      await handle(entry);
    }
  }
  
  Future<void> dispose();
}
