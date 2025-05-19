/// {@template enhanced_form}
/// A comprehensive form management system for Flutter applications.
///
/// This system provides robust validation, state management, and form handling
/// with support for synchronous and asynchronous validation, field dependencies,
/// and customizable UI feedback.
/// {@endtemplate}
library;

import 'dart:async';
import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart' as email_pkg;

/// Possible states of form validation
enum FormValidationMode {
  /// Initial state when a field is first registered
  initial,

  /// State after a field value has changed
  changed,

  /// State after form submission has been attempted
  submitted,

  /// State during async validation
  waiting,
}

/// {@template validation_result}
/// Base class for validation result outcomes
/// {@endtemplate}
abstract class ValidationResult {
  /// Whether this result indicates the value is valid
  bool get isValid;

  /// Message to display if validation fails
  String? get message;

  /// Current validation mode when this result was produced
  FormValidationMode? get mode;
}

/// {@template valid_result}
/// Result indicating valid input
/// {@endtemplate}
class ValidResult implements ValidationResult {
  @override
  bool get isValid => true;

  @override
  String? get message => null;

  @override
  FormValidationMode? get mode => null;

  /// Singleton instance
  static final ValidResult instance = ValidResult._();

  ValidResult._();
}

/// {@template invalid_result}
/// Result indicating invalid input with an error message
/// {@endtemplate}
class InvalidResult implements ValidationResult {
  @override
  final String message;

  @override
  final FormValidationMode mode;

  @override
  bool get isValid => false;

  /// Creates an invalid result with an error message
  InvalidResult(this.message, {required this.mode});
}

/// {@template replace_result}
/// Result that replaces the input value with a modified version
/// {@endtemplate}
class ReplaceResult<T> implements ValidationResult {
  /// The modified value
  final T newValue;

  @override
  bool get isValid => true;

  @override
  String? get message => null;

  @override
  FormValidationMode? get mode => null;

  /// Creates a result that replaces the input value
  ReplaceResult(this.newValue);
}

/// {@template waiting_result}
/// Result indicating validation is in progress
/// {@endtemplate}
class WaitingResult implements ValidationResult {
  @override
  bool get isValid => false;

  @override
  String? get message => 'Validation in progress...';

  @override
  FormValidationMode get mode => FormValidationMode.waiting;

  /// Singleton instance
  static final WaitingResult instance = WaitingResult._();

  WaitingResult._();
}

/// {@template validation_mode}
/// Determines when a validator should be active
/// {@endtemplate}
class ValidationMode<T> {
  /// Set of validation modes when validator should be active
  final Set<FormValidationMode> activeModes;

  /// The underlying validator
  final Validator<T> validator;

  /// Creates a validation mode wrapper around a validator
  ValidationMode(this.validator, this.activeModes);

  /// Returns the validator result if the current mode is active, otherwise valid
  FutureOr<ValidationResult?> validate(T? value, FormValidationMode mode) {
    if (activeModes.contains(mode)) {
      return validator.validate(value, mode);
    }
    return ValidResult.instance;
  }
}

/// {@template validator}
/// Base class for all validators
/// {@endtemplate}
abstract class Validator<T> {
  /// Set of form keys this validator depends on
  final Set<FormKey> _dependencies = {};

  /// Validates the input value and returns a validation result
  FutureOr<ValidationResult?> validate(T? value, FormValidationMode mode);

  /// Adds a dependency on another field
  Validator<T> shouldRevalidate(FormKey key) {
    _dependencies.add(key);
    return this;
  }

  /// Gets the set of dependencies
  Set<FormKey> get dependencies => UnmodifiableSetView(_dependencies);

  /// Combines this validator with another using AND logic
  Validator<T> operator &(Validator<T> other) {
    return CompositeValidator<T>([this, other]);
  }

  /// Combines this validator with another using OR logic
  Validator<T> operator |(Validator<T> other) {
    return OrValidator<T>([this, other]);
  }

  /// Creates a NOT validator that inverts this validator's result
  Validator<T> operator ~() {
    return NotValidator<T>(this);
  }
}

/// {@template composite_validator}
/// Combines multiple validators using AND logic
/// {@endtemplate}
class CompositeValidator<T> extends Validator<T> {
  /// List of validators to apply in sequence
  final List<Validator<T>> validators;

  /// Creates a composite validator from a list of validators
  CompositeValidator(this.validators) {
    for (final validator in validators) {
      _dependencies.addAll(validator.dependencies);
    }
  }

  @override
  FutureOr<ValidationResult?> validate(
      T? value, FormValidationMode mode) async {
    for (final validator in validators) {
      final result = validator.validate(value, mode);

      final ValidationResult? resolvedResult;
      if (result is Future) {
        resolvedResult = await result;
      } else {
        resolvedResult = result;
      }

      // If any validator fails, return its result
      if (resolvedResult != null && !resolvedResult.isValid) {
        return resolvedResult;
      }

      // If a validator replaces the value, use that for subsequent validations
      if (resolvedResult is ReplaceResult<T>) {
        value = resolvedResult.newValue;
      }
    }

    return ValidResult.instance;
  }
}

/// {@template or_validator}
/// Combines multiple validators using OR logic
/// {@endtemplate}
class OrValidator<T> extends Validator<T> {
  /// List of validators where at least one must pass
  final List<Validator<T>> validators;

  /// Creates an OR validator from a list of validators
  OrValidator(this.validators) {
    for (final validator in validators) {
      _dependencies.addAll(validator.dependencies);
    }
  }

  @override
  FutureOr<ValidationResult?> validate(
      T? value, FormValidationMode mode) async {
    List<InvalidResult> errors = [];

    for (final validator in validators) {
      final result = validator.validate(value, mode);

      final ValidationResult? resolvedResult;
      if (result is Future) {
        resolvedResult = await result;
      } else {
        resolvedResult = result;
      }

      // If any validator passes, return its result
      if (resolvedResult == null || resolvedResult.isValid) {
        return resolvedResult ?? ValidResult.instance;
      }

      // Collect errors for comprehensive error message if all validators fail
      if (resolvedResult is InvalidResult) {
        errors.add(resolvedResult);
      }
    }

    // If we reach here, all validators failed
    return errors.isNotEmpty
        ? InvalidResult(errors.map((e) => e.message).join('; '), mode: mode)
        : null;
  }
}

/// {@template not_validator}
/// Inverts the result of another validator
/// {@endtemplate}
class NotValidator<T> extends Validator<T> {
  /// The validator to invert
  final Validator<T> validator;

  /// Custom error message when validation fails
  final String? customMessage;

  /// Creates a NOT validator
  NotValidator(this.validator, {this.customMessage}) {
    _dependencies.addAll(validator.dependencies);
  }

  @override
  FutureOr<ValidationResult?> validate(
      T? value, FormValidationMode mode) async {
    final result = validator.validate(value, mode);

    final ValidationResult? resolvedResult;
    if (result is Future) {
      resolvedResult = await result;
    } else {
      resolvedResult = result;
    }

    if (resolvedResult == null) {
      return null;
    }

    // Invert the result
    if (resolvedResult.isValid) {
      return InvalidResult(
        customMessage ?? 'Value is not allowed',
        mode: mode,
      );
    }

    return ValidResult.instance;
  }
}

/// {@template conditional_validator}
/// Applies validation conditionally based on a predicate
/// {@endtemplate}
class ConditionalValidator<T> extends Validator<T> {
  /// The condition function that determines if validation should occur
  final FutureOr<bool> Function(T? value) condition;

  /// The validator to apply if condition is true
  final Validator<T> validator;

  /// Creates a conditional validator
  ConditionalValidator(this.condition, this.validator) {
    _dependencies.addAll(validator.dependencies);
  }

  @override
  FutureOr<ValidationResult?> validate(
      T? value, FormValidationMode mode) async {
    final shouldValidate = condition(value);

    final bool resolvedShouldValidate;
    if (shouldValidate is Future) {
      resolvedShouldValidate = await shouldValidate;
    } else {
      resolvedShouldValidate = shouldValidate;
    }

    if (resolvedShouldValidate) {
      return validator.validate(value, mode);
    }

    return ValidResult.instance;
  }
}

/// {@template validator_builder}
/// Creates a validator from a function
/// {@endtemplate}
class ValidatorBuilder<T> extends Validator<T> {
  /// The validation function
  final FutureOr<ValidationResult?> Function(T? value, FormValidationMode mode)
      _validateFn;

  /// Creates a validator from a function
  ValidatorBuilder(this._validateFn, {Set<FormKey>? dependencies}) {
    if (dependencies != null) {
      _dependencies.addAll(dependencies);
    }
  }

  @override
  FutureOr<ValidationResult?> validate(T? value, FormValidationMode mode) {
    return _validateFn(value, mode);
  }
}

// Common Built-in Validators

/// {@template non_null_validator}
/// Validates that a value is not null
/// {@endtemplate}
class NonNullValidator<T> extends Validator<T> {
  /// Error message when validation fails
  final String message;

  /// Creates a non-null validator
  NonNullValidator({this.message = 'Value is required'});

  @override
  ValidationResult? validate(T? value, FormValidationMode mode) {
    return value == null ? InvalidResult(message, mode: mode) : null;
  }
}

/// {@template not_empty_validator}
/// Validates that a string is not empty
/// {@endtemplate}
class NotEmptyValidator extends Validator<String> {
  /// Error message when validation fails
  final String message;

  /// Creates a not-empty validator
  NotEmptyValidator({this.message = 'Value cannot be empty'});

  @override
  ValidationResult? validate(String? value, FormValidationMode mode) {
    if (value == null || value.isEmpty) {
      return InvalidResult(message, mode: mode);
    }
    return null;
  }
}

/// {@template length_validator}
/// Validates string length is within specified bounds
/// {@endtemplate}
class LengthValidator extends Validator<String> {
  /// Minimum allowed length (inclusive)
  final int? min;

  /// Maximum allowed length (inclusive)
  final int? max;

  /// Error message template for minimum length
  final String minMessage;

  /// Error message template for maximum length
  final String maxMessage;

  /// Creates a length validator
  LengthValidator({
    this.min,
    this.max,
    this.minMessage = 'Must be at least {min} characters',
    this.maxMessage = 'Cannot exceed {max} characters',
  });

  @override
  ValidationResult? validate(String? value, FormValidationMode mode) {
    if (value == null) return null;

    if (min != null && value.length < min!) {
      return InvalidResult(
        minMessage.replaceAll('{min}', min.toString()),
        mode: mode,
      );
    }

    if (max != null && value.length > max!) {
      return InvalidResult(
        maxMessage.replaceAll('{max}', max.toString()),
        mode: mode,
      );
    }

    return null;
  }
}

/// {@template safe_password_validator}
/// Validates password meets security requirements
/// {@endtemplate}
class SafePasswordValidator extends Validator<String> {
  /// Minimum required length
  final int minLength;

  /// Whether to require digits
  final bool requireDigits;

  /// Whether to require uppercase letters
  final bool requireUppercase;

  /// Whether to require lowercase letters
  final bool requireLowercase;

  /// Whether to require special characters
  final bool requireSpecialChars;

  /// Error message templates
  final String lengthMessage;
  final String digitsMessage;
  final String uppercaseMessage;
  final String lowercaseMessage;
  final String specialCharsMessage;

  /// Creates a password validator
  SafePasswordValidator({
    this.minLength = 8,
    this.requireDigits = true,
    this.requireUppercase = true,
    this.requireLowercase = true,
    this.requireSpecialChars = true,
    this.lengthMessage = 'Password must be at least {length} characters',
    this.digitsMessage = 'Password must include at least one digit',
    this.uppercaseMessage =
        'Password must include at least one uppercase letter',
    this.lowercaseMessage =
        'Password must include at least one lowercase letter',
    this.specialCharsMessage =
        'Password must include at least one special character',
  });

  @override
  ValidationResult? validate(String? value, FormValidationMode mode) {
    if (value == null || value.isEmpty) return null;

    if (value.length < minLength) {
      return InvalidResult(
        lengthMessage.replaceAll('{length}', minLength.toString()),
        mode: mode,
      );
    }

    if (requireDigits && !value.contains(RegExp(r'[0-9]'))) {
      return InvalidResult(digitsMessage, mode: mode);
    }

    if (requireUppercase && !value.contains(RegExp(r'[A-Z]'))) {
      return InvalidResult(uppercaseMessage, mode: mode);
    }

    if (requireLowercase && !value.contains(RegExp(r'[a-z]'))) {
      return InvalidResult(lowercaseMessage, mode: mode);
    }

    if (requireSpecialChars &&
        !value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return InvalidResult(specialCharsMessage, mode: mode);
    }

    return null;
  }
}

/// {@template regex_validator}
/// Validates string matches a regular expression
/// {@endtemplate}
class RegexValidator extends Validator<String> {
  /// The regular expression pattern to match
  final RegExp pattern;

  /// Error message when validation fails
  final String message;

  /// Creates a regex validator
  RegexValidator(this.pattern, {this.message = 'Invalid format'});

  @override
  ValidationResult? validate(String? value, FormValidationMode mode) {
    if (value == null || value.isEmpty) return null;

    if (!pattern.hasMatch(value)) {
      return InvalidResult(message, mode: mode);
    }

    return null;
  }
}

/// {@template email_validator}
/// Validates email format
/// {@endtemplate}
class EmailValidator extends Validator<String> {
  /// Error message when validation fails
  final String message;

  /// Creates an email validator
  EmailValidator({this.message = 'Invalid email address'});

  @override
  ValidationResult? validate(String? value, FormValidationMode mode) {
    if (value == null || value.isEmpty) return null;

    if (!email_pkg.EmailValidator.validate(value)) {
      return InvalidResult(message, mode: mode);
    }

    return null;
  }
}

/// {@template url_validator}
/// Validates URL format
/// {@endtemplate}
class URLValidator extends Validator<String> {
  /// Error message when validation fails
  final String message;

  /// Creates a URL validator
  URLValidator({this.message = 'Invalid URL'});

  @override
  ValidationResult? validate(String? value, FormValidationMode mode) {
    if (value == null || value.isEmpty) return null;

    try {
      final uri = Uri.parse(value);
      if (!uri.hasScheme || !uri.hasAuthority) {
        return InvalidResult(message, mode: mode);
      }
    } catch (_) {
      return InvalidResult(message, mode: mode);
    }

    return null;
  }
}

/// {@template min_validator}
/// Validates number is greater than or equal to minimum
/// {@endtemplate}
class MinValidator<T extends num> extends Validator<T> {
  /// Minimum allowed value
  final T min;

  /// Whether the minimum is inclusive
  final bool inclusive;

  /// Error message template
  final String message;

  /// Creates a minimum value validator
  MinValidator(
    this.min, {
    this.inclusive = true,
    this.message = 'Value must be {op} {min}',
  });

  @override
  ValidationResult? validate(T? value, FormValidationMode mode) {
    if (value == null) return null;

    final bool valid = inclusive ? value >= min : value > min;
    if (!valid) {
      final op = inclusive ? 'at least' : 'greater than';
      return InvalidResult(
        message.replaceAll('{op}', op).replaceAll('{min}', min.toString()),
        mode: mode,
      );
    }

    return null;
  }
}

/// {@template max_validator}
/// Validates number is less than or equal to maximum
/// {@endtemplate}
class MaxValidator<T extends num> extends Validator<T> {
  /// Maximum allowed value
  final T max;

  /// Whether the maximum is inclusive
  final bool inclusive;

  /// Error message template
  final String message;

  /// Creates a maximum value validator
  MaxValidator(
    this.max, {
    this.inclusive = true,
    this.message = 'Value must be {op} {max}',
  });

  @override
  ValidationResult? validate(T? value, FormValidationMode mode) {
    if (value == null) return null;

    final bool valid = inclusive ? value <= max : value < max;
    if (!valid) {
      final op = inclusive ? 'at most' : 'less than';
      return InvalidResult(
        message.replaceAll('{op}', op).replaceAll('{max}', max.toString()),
        mode: mode,
      );
    }

    return null;
  }
}

/// {@template range_validator}
/// Validates number is within a specific range
/// {@endtemplate}
class RangeValidator<T extends num> extends Validator<T> {
  /// Minimum allowed value
  final T min;

  /// Maximum allowed value
  final T max;

  /// Whether the minimum is inclusive
  final bool inclusiveMin;

  /// Whether the maximum is inclusive
  final bool inclusiveMax;

  /// Error message template
  final String message;

  /// Creates a range validator
  RangeValidator(
    this.min,
    this.max, {
    this.inclusiveMin = true,
    this.inclusiveMax = true,
    this.message = 'Value must be between {min} and {max}',
  });

  @override
  ValidationResult? validate(T? value, FormValidationMode mode) {
    if (value == null) return null;

    final minValid = inclusiveMin ? value >= min : value > min;
    final maxValid = inclusiveMax ? value <= max : value < max;

    if (!minValid || !maxValid) {
      return InvalidResult(
        message
            .replaceAll('{min}', min.toString())
            .replaceAll('{max}', max.toString()),
        mode: mode,
      );
    }

    return null;
  }
}

/// {@template compare_with}
/// Validates by comparing with another field's value
/// {@endtemplate}
class CompareWith<T, U> extends Validator<T> {
  /// The field to compare with
  final FormKey<U> otherField;

  /// The comparison function
  final bool Function(T? value, U? otherValue) compareFn;

  /// Error message when validation fails
  final String message;

  /// Creates a field comparison validator
  CompareWith(
    this.otherField,
    this.compareFn, {
    this.message = 'Values do not match',
  }) {
    // Add dependency on the other field
    _dependencies.add(otherField);
  }

  @override
  ValidationResult? validate(T? value, FormValidationMode mode) {
    // This validator requires FormController context to get the other value
    // The actual validation is handled in FormController.validateField
    return null;
  }
}

/// {@template compare_to}
/// Validates by comparing with a constant value
/// {@endtemplate}
class CompareTo<T> extends Validator<T> {
  /// The constant value to compare with
  final T compareValue;

  /// The comparison function
  final bool Function(T? value, T compareValue) compareFn;

  /// Error message when validation fails
  final String message;

  /// Creates a constant comparison validator
  CompareTo(
    this.compareValue,
    this.compareFn, {
    this.message = 'Value does not match expected value',
  });

  @override
  ValidationResult? validate(T? value, FormValidationMode mode) {
    if (!compareFn(value, compareValue)) {
      return InvalidResult(message, mode: mode);
    }

    return null;
  }
}

/// {@template form_key}
/// Type-safe key for form fields
/// {@endtemplate}
class FormKey<T> {
  /// Unique identifier for this field
  final String name;

  /// Creates a form key with the given name
  const FormKey(this.name);

  /// Checks if a value is of the expected type
  bool isInstanceOf(dynamic value) {
    return value == null || value is T;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FormKey && other.name == name;
  }

  @override
  int get hashCode => name.hashCode;

  @override
  String toString() => 'FormKey<$T>($name)';
}

/// {@template form_value_state}
/// State of a single form field
/// {@endtemplate}
class FormValueState<T> {
  /// Current value of the field
  T? value;

  /// Validators associated with this field
  final List<Validator> validators;

  /// Whether the field has been touched
  bool touched = false;

  /// Current validation mode
  FormValidationMode mode = FormValidationMode.initial;

  /// Current validation result
  ValidationResult? validationResult;

  /// Future validation result (if async validation is in progress)
  Future<ValidationResult?>? pendingValidation;

  /// Creates a form value state
  FormValueState(this.value, this.validators);
}

/// {@template form_controller}
/// Central management of form state and validation
/// {@endtemplate}
class FormController extends ChangeNotifier {
  /// Map of field states
  final Map<FormKey, FormValueState> _attachedInputs = {};

  /// Map of field validation results
  final Map<FormKey, ValidationResult?> _validity = {};

  /// Map of pending validations
  final Map<FormKey, Future<ValidationResult?>> _pendingValidations = {};

  /// Whether the form has been submitted
  bool _submitted = false;

  /// Whether form submission is in progress
  bool _submitting = false;

  /// Whether the form has been submitted
  bool get submitted => _submitted;

  /// Whether form submission is in progress
  bool get submitting => _submitting;

  /// Gets the current value of a field
  T? getValue<T>(FormKey<T> key) {
    return _attachedInputs[key]?.value as T?;
  }

  /// Gets all form values as a map
  Map<String, dynamic> get values {
    final result = <String, dynamic>{};
    for (final entry in _attachedInputs.entries) {
      result[entry.key.name] = entry.value.value;
    }
    return result;
  }

  /// Gets the validation error for a field
  String? getError(FormKey key) {
    final result = _validity[key];
    if (result != null && !result.isValid) {
      return result.message;
    }
    return null;
  }

  /// Gets all form errors as a map
  Map<String, String> get errors {
    final result = <String, String>{};
    for (final entry in _validity.entries) {
      final error = entry.value;
      if (error != null && !error.isValid) {
        result[entry.key.name] = error.message!;
      }
    }
    return result;
  }

  /// Gets whether a field has a pending validation
  bool isPending(FormKey key) {
    return _pendingValidations.containsKey(key);
  }

  /// Gets all pending validations
  Map<FormKey, Future<ValidationResult?>> get pendingValidations {
    return Map.unmodifiable(_pendingValidations);
  }

  /// Gets whether the form is valid
  bool get isValid {
    // If any field has an error, the form is invalid
    for (final result in _validity.values) {
      if (result != null && !result.isValid) {
        return false;
      }
    }

    // If any field has a pending validation, consider the form invalid
    if (_pendingValidations.isNotEmpty) {
      return false;
    }

    return true;
  }

  /// Registers a field with the controller
  void attach<T>(
    FormKey<T> key,
    T? initialValue,
    List<Validator> validators, {
    bool validate = true,
  }) {
    if (_attachedInputs.containsKey(key)) {
      return;
    }

    final state = FormValueState<T>(initialValue, validators);
    _attachedInputs[key] = state;

    if (validate) {
      validateField(key, FormValidationMode.initial);
    }
  }

  /// Unregisters a field from the controller
  void detach(FormKey key) {
    _attachedInputs.remove(key);
    _validity.remove(key);
    _pendingValidations.remove(key);
    notifyListeners();
  }

  /// Sets the value of a field
  void setValue<T>(FormKey<T> key, T? value) {
    final state = _attachedInputs[key];
    if (state != null) {
      state.value = value;
      state.touched = true;
      state.mode = FormValidationMode.changed;

      validateField(key, FormValidationMode.changed);
      _revalidateDependents(key);
    }
  }

  /// Marks a field as touched
  void touch(FormKey key) {
    final state = _attachedInputs[key];
    if (state != null && !state.touched) {
      state.touched = true;
      notifyListeners();
    }
  }

  /// Validates a specific field
  void validateField(FormKey key, FormValidationMode mode) {
    final state = _attachedInputs[key];
    if (state == null) return;

    state.mode = mode;

    // Apply all validators
    final fieldValue = state.value;
    final validationResults = <Future<ValidationResult?>>[];

    // Run all validators and collect results
    for (final validator in state.validators) {
      final result = _processValidator(validator, key, fieldValue, mode);
      if (result is Future<ValidationResult?>) {
        validationResults.add(result);
      } else {
        final syncResult = result;
        if (syncResult != null && !syncResult.isValid) {
          // If any sync validator fails, set the error immediately
          _validity[key] = syncResult;
          _pendingValidations.remove(key);
          notifyListeners();
          return;
        }
      }
    }

    // If we have async validators, set up pending state
    if (validationResults.isNotEmpty) {
      _validity[key] = WaitingResult.instance;

      // Create a future that resolves when all validators complete
      final future = Future.wait(validationResults).then((results) {
        // Find the first invalid result, or null if all valid
        final invalidResult = results.firstWhere(
          (result) => result != null && !result.isValid,
          orElse: () => null,
        );

        _validity[key] = invalidResult ?? ValidResult.instance;
        _pendingValidations.remove(key);
        notifyListeners();
        return _validity[key];
      });

      _pendingValidations[key] = future;
    } else {
      // All validators were synchronous and passed
      _validity[key] = ValidResult.instance;
      _pendingValidations.remove(key);
    }

    notifyListeners();
  }

  /// Revalidates all fields
  void revalidate({FormValidationMode mode = FormValidationMode.submitted}) {
    for (final key in _attachedInputs.keys) {
      validateField(key, mode);
    }
  }

  /// Resets the form to initial state
  void reset() {
    _submitted = false;
    _submitting = false;

    for (final entry in _attachedInputs.entries) {
      final state = entry.value;
      state.touched = false;
      state.mode = FormValidationMode.initial;
      _validity[entry.key] = null;
    }

    _pendingValidations.clear();
    notifyListeners();
  }

  /// Submits the form and returns the result
  Future<SubmissionResult> submit() async {
    if (_submitting) {
      // Wait for all pending validations to complete
      await Future.wait(_pendingValidations.values);
    }

    _submitted = true;
    _submitting = true;
    notifyListeners();

    // Validate all fields
    revalidate(mode: FormValidationMode.submitted);

    // Wait for all pending validations to complete
    await Future.wait(_pendingValidations.values.toList());

    // Collect final results
    final formValues = values;
    final formErrors = errors;

    _submitting = false;
    notifyListeners();

    return SubmissionResult(formValues, formErrors);
  }

  // Helper method to process a validator
  FutureOr<ValidationResult?> _processValidator(
    Validator validator,
    FormKey key,
    dynamic value,
    FormValidationMode mode,
  ) {
    if (validator is CompareWith) {
      final compareWith = validator;
      final otherKey = compareWith.otherField;
      final otherValue = _attachedInputs[otherKey]?.value;

      if (!compareWith.compareFn(value, otherValue)) {
        return InvalidResult(compareWith.message, mode: mode);
      }
      return null;
    }

    // Handle regular validators
    return validator.validate(value, mode);
  }

  // Finds and revalidates all fields that depend on the given key
  void _revalidateDependents(FormKey changedKey) {
    for (final entry in _attachedInputs.entries) {
      final key = entry.key;
      final state = entry.value;

      // Check if any validators depend on the changed key
      bool hasDependency = state.validators.any((validator) {
        return validator.dependencies.contains(changedKey);
      });

      if (hasDependency) {
        validateField(key, state.mode);
      }
    }
  }
}

/// {@template submission_result}
/// Result of a form submission
/// {@endtemplate}
class SubmissionResult {
  /// Form values at submission time
  final Map<String, dynamic> values;

  /// Validation errors at submission time
  final Map<String, String> errors;

  /// Whether the submission was successful (no errors)
  bool get isValid => errors.isEmpty;

  /// Creates a submission result
  SubmissionResult(this.values, this.errors);
}

/// {@template form_field_handle}
/// Interface for form field widgets to communicate with form controller
/// {@endtemplate}
abstract class FormFieldHandle<T> {
  /// Current value of the field
  T? get value;

  /// Sets the field value
  void setValue(T? value);

  /// Gets the current error message, if any
  String? get error;

  /// Whether the field is being validated asynchronously
  bool get isPending;
}

/// {@template form_entry}
/// Widget that connects a form field to the form controller
/// {@endtemplate}
class FormEntry<T> extends StatefulWidget {
  /// Key identifying this field in the form
  final FormKey<T> formKey;

  /// Initial value for this field
  final T? initialValue;

  /// Validators for this field
  final List<Validator<T>> validators;

  /// Builder function to create the field UI
  final Widget Function(BuildContext context, FormFieldHandle<T> field) builder;

  /// Creates a form field entry
  const FormEntry({
    super.key,
    required this.formKey,
    this.initialValue,
    this.validators = const [],
    required this.builder,
  });

  @override
  State<FormEntry<T>> createState() => FormEntryState<T>();
}

/// {@template form_entry_state}
/// State for FormEntry that implements FormFieldHandle
/// {@endtemplate}
class FormEntryState<T> extends State<FormEntry<T>>
    implements FormFieldHandle<T> {
  late FormController _controller;
  T? _cachedValue;
  String? _cachedError;
  bool _cachedIsPending = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Find the form controller
    final data = Data.of(context);
    _controller = data.controller;

    // Register this field with the controller
    _controller.attach<T>(
      widget.formKey,
      widget.initialValue,
      widget.validators,
    );

    // Set up listener to update cached values
    _controller.addListener(_updateCache);
    _updateCache();
  }

  @override
  void didUpdateWidget(FormEntry<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.validators != widget.validators) {
      // jangan detach/attach segera, tapi jadwalkan setelah build selesai:
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Pastikan widget masih mounted
        if (!mounted) return;

        // Lepas registrasi lama
        _controller.detach(oldWidget.formKey);

        // Daftarkan ulang dengan validator baru
        _controller.attach<T>(
          widget.formKey,
          _controller.getValue<T>(widget.formKey) ?? widget.initialValue,
          widget.validators,
        );
      });
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_updateCache);
    // Don't detach automatically - the form controller manages lifecycle
    super.dispose();
  }

  void _updateCache() {
    final newValue = _controller.getValue<T>(widget.formKey);
    final newError = _controller.getError(widget.formKey);
    final newIsPending = _controller.isPending(widget.formKey);

    if (_cachedValue != newValue ||
        _cachedError != newError ||
        _cachedIsPending != newIsPending) {
      setState(() {
        _cachedValue = newValue;
        _cachedError = newError;
        _cachedIsPending = newIsPending;
      });
    }
  }

  @override
  T? get value => _cachedValue;

  @override
  String? get error => _cachedError;

  @override
  bool get isPending => _cachedIsPending;

  @override
  void setValue(T? newValue) {
    _controller.setValue<T>(widget.formKey, newValue);
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, this);
  }
}

/// {@template data}
/// InheritedWidget for dependency injection of form controller
/// {@endtemplate}
class Data extends InheritedWidget {
  /// The form controller
  final FormController controller;

  /// Creates a data provider
  const Data({
    super.key,
    required this.controller,
    required super.child,
  });

  /// Gets the form controller from the context
  static Data of(BuildContext context) {
    final data = context.dependOnInheritedWidgetOfExactType<Data>();
    assert(data != null, 'No Data found in context');
    return data!;
  }

  @override
  bool updateShouldNotify(Data oldWidget) {
    return controller != oldWidget.controller;
  }
}

/// {@template ignore_form}
/// Widget that breaks form propagation
/// {@endtemplate}
class IgnoreForm extends StatelessWidget {
  /// Child widget
  final Widget child;

  /// Creates a widget that breaks form propagation
  const IgnoreForm({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    // Use a new controller that won't be used
    return Data(
      controller: FormController(),
      child: child,
    );
  }
}

/// {@template form}
/// Root form widget that provides controller and manages submission
/// {@endtemplate}
class Form extends StatefulWidget {
  /// Child widget
  final Widget child;

  /// Called when form is submitted successfully
  final void Function(Map<String, dynamic> values)? onSubmit;

  /// Called when form submission fails
  final void Function(Map<String, String> errors)? onError;

  /// Creates a form widget
  const Form({
    super.key,
    required this.child,
    this.onSubmit,
    this.onError,
  });

  @override
  State<Form> createState() => _FormState();
}

class _FormState extends State<Form> {
  final FormController _controller = FormController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Data(
      controller: _controller,
      child: widget.child,
    );
  }
}

/// {@template form_entry_error_builder}
/// Builder for field-level error display
/// {@endtemplate}
class FormEntryErrorBuilder extends StatelessWidget {
  /// Form key for the field
  final FormKey formKey;

  /// Builder function for error display
  final Widget Function(BuildContext context, String error, bool isPending)
      builder;

  /// Validation modes to display errors for
  final Set<FormValidationMode> modes;

  /// Creates a field error builder
  const FormEntryErrorBuilder({
    super.key,
    required this.formKey,
    required this.builder,
    this.modes = const {
      FormValidationMode.changed,
      FormValidationMode.submitted,
      FormValidationMode.waiting,
    },
  });

  @override
  Widget build(BuildContext context) {
    final controller = Data.of(context).controller;

    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final error = controller.getError(formKey);
        final isPending = controller.isPending(formKey);

        // Only show errors for specified modes
        final state = controller._attachedInputs[formKey];
        if (state != null && !modes.contains(state.mode)) {
          return const SizedBox.shrink();
        }

        if (error != null) {
          return builder(context, error, isPending);
        }

        return const SizedBox.shrink();
      },
    );
  }
}

/// {@template form_error_builder}
/// Builder for form-level error display
/// {@endtemplate}
class FormErrorBuilder extends StatelessWidget {
  /// Builder function for error display
  final Widget Function(
      BuildContext context, List<String> errors, bool isPending) builder;

  /// Creates a form error builder
  const FormErrorBuilder({
    super.key,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Data.of(context).controller;

    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final errors = controller.errors.values.toList();
        final isPending = controller.pendingValidations.isNotEmpty;

        if (errors.isNotEmpty || isPending) {
          return builder(context, errors, isPending);
        }

        return const SizedBox.shrink();
      },
    );
  }
}

/// {@template form_pending_builder}
/// Builder for pending validation display
/// {@endtemplate}
class FormPendingBuilder extends StatelessWidget {
  /// Builder function for pending state display
  final Widget Function(BuildContext context, int pendingCount) builder;

  /// Creates a pending validation builder
  const FormPendingBuilder({
    super.key,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Data.of(context).controller;

    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final pendingCount = controller.pendingValidations.length;

        if (pendingCount > 0) {
          return builder(context, pendingCount);
        }

        return const SizedBox.shrink();
      },
    );
  }
}

/// {@template submit_button}
/// Button that handles form submission with loading and error states
/// {@endtemplate}
class SubmitButton extends StatelessWidget {
  /// Normal button child
  final Widget child;

  /// Loading indicator widget
  final Widget? loadingChild;

  /// Button child when form has errors
  final Widget? errorChild;

  /// Button style
  final ButtonStyle? style;

  /// Leading icon
  final Widget? leading;

  /// Trailing icon
  final Widget? trailing;

  /// Loading indicator (for custom display)
  final Widget? loadingIndicator;

  /// Error icon (for custom display)
  final Widget? errorIcon;

  /// Whether to disable the button when the form has errors
  final bool disableOnError;

  /// Called when button is pressed
  final void Function(SubmissionResult result)? onPressed;

  /// Creates a submit button
  const SubmitButton({
    super.key,
    required this.child,
    this.loadingChild,
    this.errorChild,
    this.style,
    this.leading,
    this.trailing,
    this.loadingIndicator,
    this.errorIcon,
    this.disableOnError = true,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Data.of(context).controller;

    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final isSubmitting = controller.submitting;
        final hasErrors = !controller.isValid && controller.submitted;
        final hasPending = controller.pendingValidations.isNotEmpty;

        final Widget displayChild;
        final VoidCallback? onPressedHandler;

        if (isSubmitting || hasPending) {
          // Loading state
          displayChild = loadingChild ?? _buildLoading();
          onPressedHandler = null;
        } else if (hasErrors && disableOnError) {
          // Error state with disabled button
          displayChild = errorChild ?? _buildError();
          onPressedHandler = null;
        } else {
          // Normal or error state with enabled button
          displayChild = hasErrors ? (errorChild ?? _buildError()) : child;
          onPressedHandler = () => _handleSubmit(context);
        }

        return ElevatedButton(
          onPressed: onPressedHandler,
          style: style,
          child: displayChild,
        );
      },
    );
  }

  Widget _buildLoading() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        loadingIndicator ??
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
        if (loadingChild != null) const SizedBox(width: 8),
        if (loadingChild != null) loadingChild!,
      ],
    );
  }

  Widget _buildError() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (errorIcon != null) errorIcon!,
        if (errorIcon != null) const SizedBox(width: 8),
        child,
      ],
    );
  }

  Future<void> _handleSubmit(BuildContext context) async {
    final result = await context.submitForm();
    if (result.isValid) {
      onPressed?.call(result);
    }
  }
}

/// {@template form_extension}
/// Extension methods for form operations
/// {@endtemplate}
extension FormExtension on BuildContext {
  /// Gets the form controller from the context
  FormController get formController => Data.of(this).controller;

  /// Submits the form and returns the result
  Future<SubmissionResult> submitForm() async {
    return await formController.submit();
  }

  /// Resets the form to initial state
  void resetForm() {
    formController.reset();
  }

  /// Gets the current value of a field
  T? getValue<T>(FormKey<T> key) {
    return formController.getValue(key);
  }

  /// Sets the value of a field
  void setValue<T>(FormKey<T> key, T? value) {
    formController.setValue(key, value);
  }

  /// Gets whether the form is valid
  bool get isFormValid => formController.isValid;

  /// Gets whether the form is submitting
  bool get isFormSubmitting => formController.submitting;

  /// Gets whether the form has been submitted
  bool get isFormSubmitted => formController.submitted;

  /// Gets all form values as a map
  Map<String, dynamic> get formValues => formController.values;

  /// Gets all form errors as a map
  Map<String, String> get formErrors => formController.errors;
}

/// {@template localizations_extension}
/// Extension to support form validation localization
/// {@endtemplate}
extension LocalizationsExtension on BuildContext {
  /// Gets localized validation messages
  String getValidationMessage(String key, [Map<String, String>? params]) {
    // This would integrate with your app's localization system
    // For now, return the key as a fallback
    return key;
  }
}
