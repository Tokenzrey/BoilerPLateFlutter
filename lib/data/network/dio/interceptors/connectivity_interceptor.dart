import 'package:dio/dio.dart';

/// Service to check network connectivity status
abstract class ConnectivityService {
  /// Checks if the device is currently connected to the internet
  Future<bool> isConnected();

  /// Stream of connectivity status changes
  Stream<bool>? get onConnectivityChanged;
}

/// Exception thrown when device is offline
class NoConnectionException implements Exception {
  /// Error message
  final String message;

  /// Creates a no connection exception
  NoConnectionException([this.message = 'No internet connection available']);

  @override
  String toString() => 'NoConnectionException: $message';
}

/// Interceptor that checks for internet connectivity before making requests
class ConnectivityInterceptor extends Interceptor {
  /// Service for checking connectivity status
  final ConnectivityService _connectivityService;

  /// Whether to throw an exception when offline
  final bool _throwExceptionOnConnectionFailure;

  /// Creates a connectivity interceptor
  ConnectivityInterceptor(
    this._connectivityService, {
    bool throwExceptionOnConnectionFailure = true,
  }) : _throwExceptionOnConnectionFailure = throwExceptionOnConnectionFailure;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Check if the request should bypass connectivity check
    if (options.extra.containsKey('bypassConnectivityCheck') &&
        options.extra['bypassConnectivityCheck'] == true) {
      return handler.next(options);
    }

    final bool isConnected = await _connectivityService.isConnected();

    if (isConnected) {
      return handler.next(options);
    }

    if (_throwExceptionOnConnectionFailure) {
      final error = NoConnectionException();
      return handler.reject(
        DioException(
          requestOptions: options,
          error: error,
          type: DioExceptionType.connectionError,
          message: error.toString(),
        ),
      );
    } else {
      // Queue the request for later retry when online
      // You could implement a request queue here if needed
      return handler.reject(
        DioException(
          requestOptions: options,
          error: NoConnectionException('Request queued - device is offline'),
          type: DioExceptionType.connectionError,
        ),
      );
    }
  }
}

/// Extension for adding connectivity bypass to Options
extension ConnectivityOptionsExtension on Options {
  /// Creates a copy of options that will bypass connectivity checks
  Options bypassConnectivityCheck() {
    final Map<String, dynamic> newExtra = Map<String, dynamic>.from(extra ?? {})
      ..['bypassConnectivityCheck'] = true;
    return copyWith(extra: newExtra);
  }
}
