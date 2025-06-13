import 'network_error.dart';

/// Exception thrown when the device is offline
class NoConnectionException extends NetworkError {
  /// Creates a no connection exception
  NoConnectionException({
    super.message = 'No internet connection available',
  }) : super(
          code: 'NO_CONNECTION',
          statusCode: null,
        );

  /// Creates a no connection exception with custom message
  factory NoConnectionException.withCustomMessage(String message) {
    return NoConnectionException(message: message);
  }
}
