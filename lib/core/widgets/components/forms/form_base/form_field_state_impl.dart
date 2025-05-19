/// {@template form_field_state_impl}
/// Implementation of the IFormFieldState interface.
/// Manages the state and validation logic for a single form field.
/// {@endtemplate}
library;

import 'form_contracts.dart';

/// {@template form_field_state_impl}
/// Concrete implementation of IFormFieldState that tracks a form field's
/// value, validation state, and metadata.
/// {@endtemplate}
class FormFieldStateImpl implements IFormFieldState {
  @override
  final String name;

  @override
  dynamic value;

  @override
  final dynamic initialValue;

  /// The synchronous validator function
  final String? Function(dynamic)? validator;

  /// The asynchronous validator function
  final Future<String?> Function(dynamic)? asyncValidator;

  @override
  String? error;

  @override
  bool touched = false;

  @override
  bool asyncValidationInProgress = false;

  @override
  String? asyncErrorResult;

  @override
  final bool isMultiValue;

  /// {@template form_field_state_impl_constructor}
  /// Creates a new form field state instance.
  ///
  /// [name] The identifier for this field
  /// [value] Initial value for the field
  /// [validator] Optional synchronous validator
  /// [asyncValidator] Optional asynchronous validator
  /// [isMultiValue] Whether this field accepts multiple values
  /// {@endtemplate}
  FormFieldStateImpl({
    required this.name,
    this.value,
    this.validator,
    this.asyncValidator,
    this.isMultiValue = false,
  }) : initialValue = value;

  @override
  String? validate() {
    if (validator == null) return null;
    error = validator!(value);
    return error;
  }

  @override
  Future<String?> validateAsync() async {
    // Run sync validation first
    if (validator != null) {
      error = validator!(value);
      if (error != null) return error;
    }

    // Then async validation if needed
    if (asyncValidator != null) {
      asyncValidationInProgress = true;
      asyncErrorResult = await asyncValidator!(value);
      asyncValidationInProgress = false;
      error = asyncErrorResult;
    }

    return error;
  }

  @override
  void reset() {
    value = initialValue;
    error = null;
    asyncErrorResult = null;
    asyncValidationInProgress = false;
    touched = false;
  }

  @override
  String toString() =>
      'FormFieldState(name: $name, value: $value, error: $error, touched: $touched)';
}
