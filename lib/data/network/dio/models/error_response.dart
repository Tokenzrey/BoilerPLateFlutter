/// Model representing a standard error response from the API
class ErrorResponse {
  /// Error code or identifier
  final String code;

  /// Human-readable error message
  final String message;

  /// Additional error details (field validation errors, etc.)
  final Map<String, dynamic>? errors;

  /// HTTP status code
  final int? statusCode;

  /// Creates an error response
  const ErrorResponse({
    required this.code,
    required this.message,
    this.errors,
    this.statusCode,
  });

  /// Creates an error response from JSON
  factory ErrorResponse.fromJson(Map<String, dynamic> json) {
    return ErrorResponse(
      code: json['code'] as String? ?? 'UNKNOWN_ERROR',
      message: json['message'] as String? ?? 'An unknown error occurred',
      errors: json['errors'] as Map<String, dynamic>?,
      statusCode: json['status_code'] as int?,
    );
  }

  /// Creates a generic error response
  factory ErrorResponse.generic({
    String message = 'An unexpected error occurred',
    int? statusCode,
  }) {
    return ErrorResponse(
      code: 'GENERIC_ERROR',
      message: message,
      statusCode: statusCode,
    );
  }

  /// Creates an error response for network connectivity issues
  factory ErrorResponse.noConnection() {
    return const ErrorResponse(
      code: 'NO_CONNECTION',
      message: 'No internet connection available',
    );
  }

  /// Creates an error response for timeouts
  factory ErrorResponse.timeout() {
    return const ErrorResponse(
      code: 'TIMEOUT',
      message: 'The request timed out. Please try again later.',
    );
  }

  /// Creates an error response for server errors
  factory ErrorResponse.serverError({String? message}) {
    return ErrorResponse(
      code: 'SERVER_ERROR',
      message: message ?? 'A server error occurred. Please try again later.',
      statusCode: 500,
    );
  }

  /// Creates an error response for unauthorized access
  factory ErrorResponse.unauthorized({String? message}) {
    return ErrorResponse(
      code: 'UNAUTHORIZED',
      message: message ?? 'You are not authorized to perform this action',
      statusCode: 401,
    );
  }

  /// Creates an error response for validation errors
  factory ErrorResponse.validationError({
    required Map<String, dynamic> errors,
    String? message,
  }) {
    return ErrorResponse(
      code: 'VALIDATION_ERROR',
      message: message ?? 'Please check the provided information',
      errors: errors,
      statusCode: 422,
    );
  }

  /// Converts this error response to a map
  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'message': message,
      if (errors != null) 'errors': errors,
      if (statusCode != null) 'status_code': statusCode,
    };
  }

  @override
  String toString() => 'ErrorResponse(code: $code, message: $message)';
}
