/// {@template form_contracts}
/// Defines the core contracts and interfaces for the form management system.
/// This library provides abstractions for field management, validation, and form handling.
/// {@endtemplate}
library;

import 'dart:async';

/// A function type for synchronous form field validation.
typedef FormValidatorFn<T> = String? Function(T? value);

/// A function type for asynchronous form field validation.
typedef AsyncFormValidatorFn<T> = Future<String?> Function(T? value);

/// {@template form_field_state}
/// Represents the state of a single form field.
/// Includes value, validation status, and other metadata.
/// {@endtemplate}
abstract class IFormFieldState {
  /// The name identifier of this field
  String get name;

  /// The current value of the field
  dynamic get value;
  set value(dynamic newValue);

  /// The initial value when the field was registered
  dynamic get initialValue;

  /// Current validation error message (null if valid)
  String? get error;
  set error(String? errorMessage);

  /// Whether the field has been interacted with
  bool get touched;
  set touched(bool value);

  /// Whether async validation is currently in progress
  bool get asyncValidationInProgress;

  /// Latest result from async validation
  String? get asyncErrorResult;

  /// Whether this field accepts multiple values (e.g. checkboxes, multi-select)
  bool get isMultiValue;

  /// Validates the field synchronously
  String? validate();

  /// Validates the field asynchronously
  Future<String?> validateAsync();

  /// Resets the field to its initial state
  void reset();
}

/// {@template form_manager}
/// Core interface for form management functionality.
/// Handles field registration, validation, and form submission.
/// {@endtemplate}
abstract class IFormManager {
  /// Whether the form is currently submitting
  bool get isSubmitting;

  /// Whether the form has been submitted at least once
  bool get hasBeenSubmitted;

  /// All current form values as a map
  Map<String, dynamic> get values;

  /// All current validation errors as a map
  Map<String, String?> get errors;

  /// Registers a new field with the form manager
  void registerField<T>({
    required String name,
    T? initialValue,
    FormValidatorFn<T>? validator,
    AsyncFormValidatorFn<T>? asyncValidator,
    bool isMultiValue = false,
  });

  /// Registers multiple fields at once
  void registerFields<T>({
    required Map<String, dynamic> initialValues,
    Map<String, FormValidatorFn>? validators,
    Map<String, AsyncFormValidatorFn>? asyncValidators,
    Map<String, bool>? multiValueFlags,
  });

  /// Unregisters a field from the form
  void unregisterField(String name);

  /// Unregisters multiple fields
  void unregisterFields(List<String> names);

  /// Gets the value of a specific field
  T? getValue<T>(String name);

  /// Gets multiple values from a multi-value field
  List<T>? getValues<T>(String name);

  /// Sets the value of a specific field
  void setFieldValue(String name, dynamic value);

  /// Sets multiple values for a multi-value field
  void setFieldValues<T>(String name, List<T> values);

  /// Gets the validation error for a specific field
  String? getError(String name);

  /// Marks a field as touched (user has interacted with it)
  void touchField(String name);

  /// Validates a specific field
  bool validateField(String name);

  /// Validates a specific field asynchronously
  Future<bool> validateFieldAsync(String name);

  /// Validates the entire form
  bool validate();

  /// Validates the entire form asynchronously
  Future<bool> validateAsync();

  /// Submits the form, returning values if valid
  Future<Map<String, dynamic>> submit();

  /// Resets all fields to their initial values
  void reset();

  /// Checks if any async validations are in progress
  bool hasAsyncValidationInProgress();

  /// Checks if a specific field has async validation in progress
  bool isFieldAsyncValidating(String name);
}
