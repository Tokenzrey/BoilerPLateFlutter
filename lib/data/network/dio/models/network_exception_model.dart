import 'package:dio/dio.dart';

/// Model representing a network exception with detailed information
class NetworkExceptionModel implements Exception {
  /// The error message
  final String message;

  /// The error code (HTTP status or custom code)
  final String code;

  /// The stacktrace if available
  final StackTrace? stackTrace;

  /// The original exception that caused this exception
  final Exception? originalException;

  /// The request URL that failed
  final String? requestUrl;

  /// The request method (GET, POST, etc.)
  final String? requestMethod;

  /// The HTTP status code if available
  final int? statusCode;

  /// The raw error data if available
  final dynamic errorData;

  /// Creates a network exception model
  const NetworkExceptionModel({
    required this.message,
    required this.code,
    this.stackTrace,
    this.originalException,
    this.requestUrl,
    this.requestMethod,
    this.statusCode,
    this.errorData,
  });

  /// Creates a network exception from a DioException
  factory NetworkExceptionModel.fromDioException(
    DioException exception, {
    StackTrace? stackTrace,
  }) {
    final response = exception.response;
    String code;
    String message;
    int? statusCode = response?.statusCode;
    String? requestUrl = exception.requestOptions.uri.toString();
    String? requestMethod = exception.requestOptions.method;
    dynamic errorData = response?.data;

    switch (exception.type) {
      case DioExceptionType.connectionTimeout:
        code = 'CONNECTION_TIMEOUT';
        message =
            'Connection timed out. Please check your internet connection.';
        break;
      case DioExceptionType.sendTimeout:
        code = 'SEND_TIMEOUT';
        message = 'Request timed out while sending data. Please try again.';
        break;
      case DioExceptionType.receiveTimeout:
        code = 'RECEIVE_TIMEOUT';
        message = 'Server took too long to respond. Please try again later.';
        break;
      case DioExceptionType.badResponse:
        code = 'HTTP_$statusCode';
        message = _extractErrorMessage(response) ??
            'Server responded with status code $statusCode';
        break;
      case DioExceptionType.cancel:
        code = 'REQUEST_CANCELLED';
        message = 'Request was cancelled.';
        break;
      case DioExceptionType.connectionError:
        code = 'CONNECTION_ERROR';
        message =
            'Could not connect to the server. Please check your internet connection.';
        break;
      case DioExceptionType.badCertificate:
        code = 'BAD_CERTIFICATE';
        message =
            'Invalid SSL certificate. Cannot establish secure connection.';
        break;
      case DioExceptionType.unknown:
        code = 'UNKNOWN';
        message = exception.message ?? 'An unexpected error occurred.';
        break;
    }

    return NetworkExceptionModel(
      code: code,
      message: message,
      stackTrace: stackTrace ?? exception.stackTrace,
      originalException: exception,
      requestUrl: requestUrl,
      requestMethod: requestMethod,
      statusCode: statusCode,
      errorData: errorData,
    );
  }

  /// Creates a network exception for no internet connection
  factory NetworkExceptionModel.noConnection({
    String message = 'No internet connection available.',
    StackTrace? stackTrace,
    String? requestUrl,
    String? requestMethod,
  }) {
    return NetworkExceptionModel(
      code: 'NO_CONNECTION',
      message: message,
      stackTrace: stackTrace,
      requestUrl: requestUrl,
      requestMethod: requestMethod,
    );
  }

  /// Creates a network exception for timeout errors
  factory NetworkExceptionModel.timeout({
    String message = 'Request timed out.',
    String? requestUrl,
    String? requestMethod,
    StackTrace? stackTrace,
  }) {
    return NetworkExceptionModel(
      code: 'TIMEOUT',
      message: message,
      requestUrl: requestUrl,
      requestMethod: requestMethod,
      stackTrace: stackTrace,
    );
  }

  /// Creates a network exception for server errors
  factory NetworkExceptionModel.serverError({
    String message = 'Server error occurred.',
    int statusCode = 500,
    String? requestUrl,
    String? requestMethod,
    dynamic errorData,
    StackTrace? stackTrace,
  }) {
    return NetworkExceptionModel(
      code: 'SERVER_ERROR',
      message: message,
      statusCode: statusCode,
      requestUrl: requestUrl,
      requestMethod: requestMethod,
      errorData: errorData,
      stackTrace: stackTrace,
    );
  }

  /// Creates a generic network exception
  factory NetworkExceptionModel.generic({
    String message = 'An error occurred.',
    String code = 'UNKNOWN',
    StackTrace? stackTrace,
    Exception? originalException,
  }) {
    return NetworkExceptionModel(
      code: code,
      message: message,
      stackTrace: stackTrace,
      originalException: originalException,
    );
  }

  /// Attempts to extract an error message from a response
  static String? _extractErrorMessage(Response? response) {
    if (response == null || response.data == null) return null;

    final data = response.data;

    if (data is Map) {
      // Common API error formats
      for (final key in [
        'message',
        'error',
        'error_message',
        'error_description',
        'errorMessage'
      ]) {
        if (data.containsKey(key) && data[key] is String) {
          return data[key];
        }
      }

      // Nested error objects
      final error = data['error'];
      if (error is Map && error.containsKey('message')) {
        return error['message'];
      }

      // Laravel/Symfony style errors
      final errors = data['errors'];
      if (errors is Map && errors.isNotEmpty) {
        final firstError = errors.values.first;
        if (firstError is List && firstError.isNotEmpty) {
          return firstError.first.toString();
        }
      }
    }

    return null;
  }

  /// Returns true if this is a connection error
  bool get isConnectionError =>
      code == 'NO_CONNECTION' || code == 'CONNECTION_ERROR';

  /// Returns true if this is a timeout error
  bool get isTimeoutError =>
      code == 'CONNECTION_TIMEOUT' ||
      code == 'SEND_TIMEOUT' ||
      code == 'RECEIVE_TIMEOUT' ||
      code == 'TIMEOUT';

  /// Returns true if this is a server error (5xx)
  bool get isServerError =>
      statusCode != null && statusCode! >= 500 && statusCode! < 600;

  /// Returns true if this is a client error (4xx)
  bool get isClientError =>
      statusCode != null && statusCode! >= 400 && statusCode! < 500;

  /// Returns true if this is an unauthorized error (401)
  bool get isUnauthorizedError => statusCode == 401;

  /// Returns true if this is a forbidden error (403)
  bool get isForbiddenError => statusCode == 403;

  /// Returns true if this is a not found error (404)
  bool get isNotFoundError => statusCode == 404;

  /// Returns true if this is a validation error (422)
  bool get isValidationError => statusCode == 422;

  /// Returns true if this error is likely to be resolved by retrying
  bool get isRetryable =>
      isConnectionError ||
      isTimeoutError ||
      isServerError ||
      (statusCode != null && statusCode! >= 500);

  @override
  String toString() {
    final buffer = StringBuffer('NetworkException: [$code] $message');

    if (statusCode != null) {
      buffer.write(' (Status: $statusCode)');
    }

    if (requestMethod != null && requestUrl != null) {
      buffer.write(' - $requestMethod $requestUrl');
    }

    return buffer.toString();
  }
}
