/// {@template form_controller}
/// Primary controller for handling form state, validation, and submission.
/// Provides a unified API for registering fields, validating input,
/// and handling form submission while supporting both synchronous and
/// asynchronous validation workflows.
/// {@endtemplate}
library;

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:boilerplate/core/logging/logger.dart';
import 'package:boilerplate/di/service_locator.dart';
import 'form_contracts.dart';
import 'form_field_state_impl.dart';
import 'form_validation_exception.dart';

/// {@template form_controller}
/// Main controller for form management that implements IFormManager.
/// Handles field registration, validation, and submission of forms.
/// {@endtemplate}
class FormController extends ChangeNotifier implements IFormManager {
  /// Logger instance for debugging
  final Logger log = getIt<Logger>();

  /// Map of field states, keyed by field name
  final Map<String, IFormFieldState> _fields = {};

  bool _isSubmitting = false;

  @override
  bool get isSubmitting => _isSubmitting;

  bool _hasBeenSubmitted = false;

  @override
  bool get hasBeenSubmitted => _hasBeenSubmitted;

  /// Completer for the current form submission
  Completer<Map<String, dynamic>>? _submissionCompleter;

  /// {@template form_controller_constructor}
  /// Creates a new form controller instance.
  /// {@endtemplate}
  FormController() {
    log.info('FormController initialized');
  }

  @override
  Map<String, dynamic> get values {
    final result = <String, dynamic>{};
    _fields.forEach((key, state) {
      result[key] = state.value;
    });
    log.info('Current form values: $result');
    return result;
  }

  @override
  T? getValue<T>(String name) {
    final v = _fields[name]?.value as T?;
    log.info('getValue<$T>("$name") = $v');
    return v;
  }

  @override
  List<T>? getValues<T>(String name) {
    final v = _fields[name]?.value as List<T>?;
    log.info('getValues<$T>("$name") = $v');
    return v;
  }

  @override
  Map<String, String?> get errors {
    final result = <String, String?>{};
    _fields.forEach((key, state) {
      result[key] = state.error;
    });
    log.info('Current form errors: $result');
    return result;
  }

  @override
  String? getError(String name) {
    final e = _fields[name]?.error;
    log.info('getError("$name") = $e');
    return e;
  }

  @override
  bool isFieldAsyncValidating(String name) {
    return _fields[name]?.asyncValidationInProgress ?? false;
  }

  @override
  void registerField<T>({
    required String name,
    T? initialValue,
    FormValidatorFn<T>? validator,
    AsyncFormValidatorFn<T>? asyncValidator,
    bool isMultiValue = false,
  }) {
    if (_fields.containsKey(name)) {
      log.info('Field "$name" is already registered – skipping.');
      return;
    }

    final wrappedValidator =
        validator == null ? null : (dynamic v) => validator(v as T?);

    final wrappedAsyncValidator = asyncValidator == null
        ? null
        : (dynamic v) async => await asyncValidator(v as T?);

    _fields[name] = FormFieldStateImpl(
      name: name,
      value: initialValue,
      validator: wrappedValidator,
      asyncValidator: wrappedAsyncValidator,
      isMultiValue: isMultiValue,
    );
    log.info(
        'Field registered: "$name", initialValue=$initialValue, isMultiValue=$isMultiValue');
  }

  @override
  void registerFields<T>({
    required Map<String, dynamic> initialValues,
    Map<String, FormValidatorFn>? validators,
    Map<String, AsyncFormValidatorFn>? asyncValidators,
    Map<String, bool>? multiValueFlags,
  }) {
    initialValues.forEach((name, initialValue) {
      registerField(
        name: name,
        initialValue: initialValue,
        validator: validators?[name],
        asyncValidator: asyncValidators?[name],
        isMultiValue: multiValueFlags?[name] ?? false,
      );
    });
    log.info('Bulk registered ${initialValues.length} fields');
  }

  @override
  void unregisterField(String name) {
    _fields.remove(name);
    log.info('Field unregistered: "$name"');
  }

  @override
  void unregisterFields(List<String> names) {
    for (final name in names) {
      _fields.remove(name);
    }
    log.info('Unregistered ${names.length} fields: $names');
  }

  @override
  void setFieldValue(String name, dynamic value) {
    final field = _fields[name];
    if (field != null) {
      log.info('setFieldValue("$name", $value)');
      field.value = value;

      if (field is FormFieldStateImpl) {
        field.asyncValidationInProgress = false;
        field.asyncErrorResult = null;
      }

      if (field.touched) {
        log.info('  field was touched → validating field "$name"');
        validateField(name);
      }

      notifyListeners();
    } else {
      log.info('setFieldValue: no field named "$name"');
    }
  }

  @override
  void setFieldValues<T>(String name, List<T> values) {
    final field = _fields[name];
    if (field != null && field.isMultiValue) {
      log.info('setFieldValues("$name", $values)');
      field.value = values;

      if (field is FormFieldStateImpl) {
        field.asyncValidationInProgress = false;
        field.asyncErrorResult = null;
      }

      if (field.touched) {
        log.info('  field was touched → validating field "$name"');
        validateField(name);
      }

      notifyListeners();
    } else {
      log.info(
          'setFieldValues: field "$name" not found or not a multi-value field');
    }
  }

  @override
  void touchField(String name) {
    final field = _fields[name];
    if (field != null) {
      field.touched = true;
      log.info('Field touched: "$name"');
      notifyListeners();
    }
  }

  @override
  bool validateField(String name) {
    final field = _fields[name];
    if (field == null) return true;

    // Run synchronous validation
    final syncResult = field.validate();

    // Run async validation if sync validation passed
    if (syncResult == null &&
        field is FormFieldStateImpl &&
        field.asyncValidator != null) {
      field.asyncValidationInProgress = true;
      field.asyncValidator!(field.value).then((asyncError) {
        field.asyncValidationInProgress = false;
        field.asyncErrorResult = asyncError;
        field.error ??= asyncError;

        log.info('asyncValidateField("$name") → error="$asyncError"');
        notifyListeners();
      });
    }

    notifyListeners();
    return field.error == null;
  }

  @override
  Future<bool> validateFieldAsync(String name) async {
    final field = _fields[name];
    if (field == null) return true;

    await field.validateAsync();
    notifyListeners();
    return field.error == null;
  }

  @override
  Future<bool> validateAsync() async {
    bool isValid = true;
    final futures = <Future<void>>[];

    // Run all synchronous validations first
    _fields.forEach((name, field) {
      final error = field.validate();
      field.touched = true;
      log.info('  field "$name" sync validation → error="$error"');
      if (error != null) {
        isValid = false;
      }
    });

    // Then queue all async validations if their fields are valid so far
    for (final entry in _fields.entries) {
      final name = entry.key;
      final field = entry.value;

      if (field is FormFieldStateImpl &&
          field.asyncValidator != null &&
          field.error == null) {
        field.asyncValidationInProgress = true;
        final future = field.validateAsync().then((asyncError) {
          log.info('  field "$name" async validation → error="$asyncError"');
          if (asyncError != null) {
            isValid = false;
          }
        });

        futures.add(future);
      }
    }

    // Wait for all async validations to complete
    if (futures.isNotEmpty) {
      await Future.wait(futures);
    }

    notifyListeners();
    log.info('Form validation result: ${isValid ? "PASS" : "FAIL"}');
    return isValid;
  }

  @override
  bool validate() {
    bool isValid = true;

    _fields.forEach((name, field) {
      final error = field.validate();
      field.touched = true;
      log.info('  field "$name" → error="$error"');
      if (error != null) {
        isValid = false;
      }

      // Include async results if available
      if (field.asyncErrorResult != null) {
        field.error ??= field.asyncErrorResult;
        if (field.asyncErrorResult != null) {
          isValid = false;
        }
      }
    });

    log.info('Form validation result: ${isValid ? "PASS" : "FAIL"}');
    notifyListeners();
    return isValid;
  }

  @override
  void reset() {
    _fields.forEach((name, field) {
      field.reset();
      log.info('  "$name" → reset to ${field.initialValue}');
    });
    _hasBeenSubmitted = false;

    notifyListeners();
  }

  @override
  Future<Map<String, dynamic>> submit() async {
    if (_isSubmitting) {
      log.info(
          'Submit called but already submitting, returning existing future');
      return _submissionCompleter!.future;
    }

    _submissionCompleter = Completer<Map<String, dynamic>>();
    _isSubmitting = true;
    _hasBeenSubmitted = true;
    notifyListeners();

    try {
      final isValid = await validateAsync();

      if (isValid) {
        log.info('Form is valid → completing submit with values');
        _submissionCompleter!.complete(values);
      } else {
        log.info('Form invalid → completing error with $errors');
        _submissionCompleter!.completeError(
            FormValidationException('Form validation failed', errors));
      }
    } catch (e) {
      log.info('Error during form validation: $e');
      _submissionCompleter!.completeError(e);
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }

    return _submissionCompleter!.future;
  }

  @override
  bool hasAsyncValidationInProgress() {
    return _fields.values.any((field) => field.asyncValidationInProgress);
  }
}
