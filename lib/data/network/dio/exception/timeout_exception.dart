import 'network_error.dart';

/// Type of timeout that occurred
enum TimeoutType {
  /// Timeout while establishing connection
  connection,

  /// Timeout while sending data
  send,

  /// Timeout while waiting for response
  receive,
}

/// Exception thrown when a request times out
class TimeoutException extends NetworkError {
  /// The type of timeout that occurred
  final TimeoutType timeoutType;

  /// Duration after which the timeout occurred (if known)
  final Duration? duration;

  /// Creates a timeout exception
  TimeoutException({
    required this.timeoutType,
    required super.message,
    this.duration,
    super.path,
  }) : super(
          code: _getCodeForType(timeoutType),
        );

  /// Creates a connection timeout exception
  factory TimeoutException.connection({
    String message =
        'Connection timed out. Please check your internet connection.',
    Duration? duration,
    String? path,
  }) {
    return TimeoutException(
      timeoutType: TimeoutType.connection,
      message: message,
      duration: duration,
      path: path,
    );
  }

  /// Creates a send timeout exception
  factory TimeoutException.send({
    String message = 'Request timed out while sending data. Please try again.',
    Duration? duration,
    String? path,
  }) {
    return TimeoutException(
      timeoutType: TimeoutType.send,
      message: message,
      duration: duration,
      path: path,
    );
  }

  /// Creates a receive timeout exception
  factory TimeoutException.receive({
    String message = 'Server took too long to respond. Please try again later.',
    Duration? duration,
    String? path,
  }) {
    return TimeoutException(
      timeoutType: TimeoutType.receive,
      message: message,
      duration: duration,
      path: path,
    );
  }

  static String _getCodeForType(TimeoutType type) {
    switch (type) {
      case TimeoutType.connection:
        return 'CONNECTION_TIMEOUT';
      case TimeoutType.send:
        return 'SEND_TIMEOUT';
      case TimeoutType.receive:
        return 'RECEIVE_TIMEOUT';
    }
  }

  @override
  String toString() {
    final durationInfo =
        duration != null ? ' after ${duration!.inMilliseconds}ms' : '';
    return 'TimeoutException (${timeoutType.name}$durationInfo): $message';
  }
}
