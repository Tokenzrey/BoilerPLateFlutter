import 'package:dio/dio.dart';

/// Base network error class for standardized error handling
class NetworkError implements Exception {
  /// Error code (HTTP status or custom code)
  final String code;

  /// Human-readable error message
  final String message;

  /// Original exception that caused this error
  final Exception? originalException;

  /// Raw error response data if available
  final dynamic responseData;

  /// HTTP status code if available
  final int? statusCode;

  /// Request path that caused the error
  final String? path;

  /// Creates a network error with standardized structure
  NetworkError({
    required this.code,
    required this.message,
    this.originalException,
    this.responseData,
    this.statusCode,
    this.path,
  });

  /// Creates a NetworkError from a DioException
  factory NetworkError.fromDioException(DioException exception) {
    final response = exception.response;
    String code;
    String message;
    int? statusCode = response?.statusCode;
    String? path = exception.requestOptions.path;

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

    return NetworkError(
      code: code,
      message: message,
      originalException: exception,
      responseData: response?.data,
      statusCode: statusCode,
      path: path,
    );
  }

  /// Attempts to extract an error message from the response data
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

  @override
  String toString() => 'NetworkError: [$code] $message';
}
