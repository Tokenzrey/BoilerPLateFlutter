import 'log_level.dart';

class LogEntry {
  final LogLevel level;
  final String message;
  final String tag;
  final String? domain;
  final DateTime timestamp;
  final Object? exception;
  final StackTrace? stackTrace;
  final Map<String, dynamic>? metadata;

  LogEntry({
    required this.level,
    required this.message,
    required this.tag,
    this.domain,
    DateTime? timestamp,
    this.exception,
    this.stackTrace,
    this.metadata,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'level': level.name,
      'message': message,
      'tag': tag,
      'timestamp': timestamp.toIso8601String(),
      if (domain != null) 'domain': domain,
      if (exception != null) 'exception': exception.toString(),
      if (stackTrace != null) 'stackTrace': stackTrace.toString(),
      if (metadata != null) 'metadata': metadata,
    };
  }

  LogEntry copyWith({
    LogLevel? level,
    String? message,
    String? tag,
    String? domain,
    DateTime? timestamp,
    Object? exception,
    StackTrace? stackTrace,
    Map<String, dynamic>? metadata,
  }) {
    return LogEntry(
      level: level ?? this.level,
      message: message ?? this.message,
      tag: tag ?? this.tag,
      domain: domain ?? this.domain,
      timestamp: timestamp ?? this.timestamp,
      exception: exception ?? this.exception,
      stackTrace: stackTrace ?? this.stackTrace,
      metadata: metadata ?? this.metadata,
    );
  }
}
