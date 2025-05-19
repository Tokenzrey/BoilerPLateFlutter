/// {@template form_validation_exception}
/// Exception thrown when form validation fails.
/// Contains information about which fields failed validation and why.
/// {@endtemplate}
library;

/// {@template form_validation_exception}
/// Exception thrown when form validation fails during submission.
/// Includes field-specific error messages.
/// {@endtemplate}
class FormValidationException implements Exception {
  /// Message describing the validation failure
  final String message;

  /// Map of field names to their specific error messages
  final Map<String, String?> fieldErrors;

  /// {@template form_validation_exception_constructor}
  /// Creates a new form validation exception.
  ///
  /// [message] General error message
  /// [fieldErrors] Map of field-specific errors
  /// {@endtemplate}
  const FormValidationException(this.message, this.fieldErrors);

  @override
  String toString() => 'FormValidationException: $message';
}
