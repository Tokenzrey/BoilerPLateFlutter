import 'network_error.dart';

/// Exception thrown when server rejects request due to validation errors
class ValidationException extends NetworkError {
  /// Map of field names to validation error messages
  final Map<String, List<String>> fieldErrors;

  /// Creates a validation exception
  ValidationException({
    super.message = 'Please correct the errors and try again.',
    required this.fieldErrors,
    super.responseData,
    super.path,
  }) : super(
          code: 'VALIDATION_ERROR',
          statusCode: 422,
        );

  /// Creates a validation exception from a response body
  factory ValidationException.fromJson(
    Map<String, dynamic> json, {
    String? path,
  }) {
    final Map<String, List<String>> fieldErrors = {};
    String message = 'Validation failed. Please check your input.';

    // Extract primary message if available
    if (json.containsKey('message') && json['message'] is String) {
      message = json['message'];
    }

    // Parse errors - handles Laravel/Symfony style validation errors
    if (json.containsKey('errors') && json['errors'] is Map) {
      final errors = json['errors'] as Map;
      errors.forEach((key, value) {
        if (value is List) {
          fieldErrors[key.toString()] = value.map((e) => e.toString()).toList();
        } else if (value is String) {
          fieldErrors[key.toString()] = [value];
        }
      });
    }

    return ValidationException(
      message: message,
      fieldErrors: fieldErrors,
      responseData: json,
      path: path,
    );
  }

  /// Gets all error messages as a flattened list
  List<String> get allErrorMessages {
    return fieldErrors.values.expand((messages) => messages).toList();
  }

  /// Gets the first error message for a specific field
  String? getFirstErrorFor(String field) {
    return fieldErrors[field]?.first;
  }

  /// Gets all error messages for a specific field
  List<String>? getErrorsFor(String field) {
    return fieldErrors[field];
  }

  /// Returns true if there are errors for the specified field
  bool hasErrorsFor(String field) {
    return fieldErrors.containsKey(field) && fieldErrors[field]!.isNotEmpty;
  }

  @override
  String toString() {
    if (fieldErrors.isEmpty) {
      return 'ValidationException: $message';
    }

    final fields = fieldErrors.keys.join(', ');
    return 'ValidationException: $message (Fields with errors: $fields)';
  }
}
