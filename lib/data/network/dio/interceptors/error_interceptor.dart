import 'package:dio/dio.dart';

/// Standard network error with consistent structure
class NetworkError implements Exception {
  /// Error code (HTTP status or custom code)
  final String code;

  /// Human-readable error message
  final String message;

  /// Original exception that caused this error
  final Exception? originalException;

  /// Raw error response data if available
  final dynamic responseData;

  /// Creates a network error
  NetworkError({
    required this.code,
    required this.message,
    this.originalException,
    this.responseData,
  });

  @override
  String toString() => 'NetworkError: [$code] $message';
}

/// Interceptor that transforms Dio errors into standardized NetworkError objects
class ErrorInterceptor extends Interceptor {
  /// Custom error mappers by status code
  final Map<int, String Function(Response)>? _statusCodeErrorMessages;

  /// Custom error handlers by error type
  final Map<DioExceptionType, NetworkError Function(DioException)>?
      _customErrorHandlers;

  /// Creates an error interceptor with optional custom mappings
  ErrorInterceptor({
    Map<int, String Function(Response)>? statusCodeErrorMessages,
    Map<DioExceptionType, NetworkError Function(DioException)>?
        customErrorHandlers,
  })  : _statusCodeErrorMessages = statusCodeErrorMessages,
        _customErrorHandlers = customErrorHandlers;

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Check for custom handler based on error type
    if (_customErrorHandlers != null &&
        _customErrorHandlers!.containsKey(err.type)) {
      final customError = _customErrorHandlers![err.type]!(err);
      return handler.reject(
        DioException(
          requestOptions: err.requestOptions,
          error: customError,
          type: err.type,
          response: err.response,
        ),
      );
    }

    final networkError = _mapDioExceptionToNetworkError(err);
    return handler.reject(
      DioException(
        requestOptions: err.requestOptions,
        error: networkError,
        type: err.type,
        response: err.response,
      ),
    );
  }

  /// Maps a DioException to a standardized NetworkError
  NetworkError _mapDioExceptionToNetworkError(DioException exception) {
    final response = exception.response;
    String code;
    String message;
    dynamic responseData = response?.data;

    // Handle response errors (4xx, 5xx)
    if (exception.type == DioExceptionType.badResponse && response != null) {
      final statusCode = response.statusCode ?? 0;
      code = 'HTTP_$statusCode';

      // Use custom message if available for this status code
      if (_statusCodeErrorMessages != null &&
          _statusCodeErrorMessages!.containsKey(statusCode)) {
        message = _statusCodeErrorMessages![statusCode]!(response);
      } else {
        // Default error messages by status code
        message = _getDefaultMessageForStatusCode(statusCode, response);
      }
    } else {
      // Handle non-response errors (network, timeout, etc.)
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
        case DioExceptionType.badCertificate:
          code = 'BAD_CERTIFICATE';
          message =
              'Invalid SSL certificate. Cannot establish secure connection.';
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
        case DioExceptionType.unknown:
          code = 'UNKNOWN';
          message = exception.message ?? 'An unexpected error occurred.';
          break;
        default:
          code = 'UNKNOWN';
          message = 'An unexpected error occurred.';
          break;
      }
    }

    return NetworkError(
      code: code,
      message: message,
      originalException: exception,
      responseData: responseData,
    );
  }

  /// Gets a default error message for the given status code
  String _getDefaultMessageForStatusCode(int statusCode, Response response) {
    switch (statusCode) {
      case 400:
        return _extractErrorMessage(response) ??
            'Bad request. Please check your input.';
      case 401:
        return 'Unauthorized. Please sign in again.';
      case 403:
        return 'You don\'t have permission to access this resource.';
      case 404:
        return 'The requested resource was not found.';
      case 405:
        return 'Method not allowed.';
      case 409:
        return 'Conflict with current state of the resource.';
      case 422:
        return _extractErrorMessage(response) ??
            'Invalid input. Please check your data.';
      case 429:
        return 'Too many requests. Please try again later.';
      case 500:
        return 'Server error. Please try again later.';
      case 502:
        return 'Bad gateway. Please try again later.';
      case 503:
        return 'Service unavailable. Please try again later.';
      default:
        if (statusCode >= 400 && statusCode < 500) {
          return _extractErrorMessage(response) ??
              'Client error (${response.statusMessage ?? statusCode})';
        } else if (statusCode >= 500) {
          return 'Server error (${response.statusMessage ?? statusCode}). Please try again later.';
        } else {
          return response.statusMessage ?? 'Unknown error';
        }
    }
  }

  /// Attempts to extract an error message from the response data
  String? _extractErrorMessage(Response response) {
    final data = response.data;

    if (data == null) return null;

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
    }

    return null;
  }
}
