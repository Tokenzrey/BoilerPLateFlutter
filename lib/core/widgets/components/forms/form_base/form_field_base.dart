/// {@template form_field_base}
/// Base widget class for form fields that integrates with the form management system.
/// Provides common configuration options and lifecycle management for form fields.
/// {@endtemplate}
library;

import 'package:flutter/material.dart';
import 'form_contracts.dart';
import 'form_controller.dart';
import 'form_provider.dart';

/// {@template form_field_base}
/// Abstract base widget for creating form fields that automatically register with
/// the form controller and manage their lifecycle.
///
/// This class handles the common configuration needed for all form fields.
/// {@endtemplate}
abstract class FormFieldBase<T> extends StatefulWidget {
  /// Unique identifier for this field within the form
  final String name;

  /// Initial value for this field
  final T? initialValue;

  /// Synchronous validator function
  final FormValidatorFn<T>? validator;

  /// Asynchronous validator function
  final AsyncFormValidatorFn<T>? asyncValidator;

  /// Whether this field contains multiple values
  final bool isMultiValue;

  /// {@template form_field_base_constructor}
  /// Creates a new form field base widget.
  ///
  /// [name] Unique identifier for this field
  /// [initialValue] Initial value
  /// [validator] Optional synchronous validator function
  /// [asyncValidator] Optional asynchronous validator function
  /// [isMultiValue] Whether this field accepts multiple values
  /// {@endtemplate}
  const FormFieldBase({
    super.key,
    required this.name,
    this.initialValue,
    this.validator,
    this.asyncValidator,
    this.isMultiValue = false,
  });
}

/// {@template form_field_base_state}
/// Base state class for form field widgets, handling registration with the form controller,
/// value updates, and validation.
/// {@endtemplate}
abstract class FormFieldBaseState<T, W extends FormFieldBase<T>>
    extends State<W> {
  /// The form controller this field is registered with
  FormController? _formController;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    try {
      // Get form controller from the provider
      _formController = FormProvider.of(context);

      // Register this field with the form controller
      _formController?.registerField<T>(
        name: widget.name,
        initialValue: widget.initialValue,
        validator: widget.validator,
        asyncValidator: widget.asyncValidator,
        isMultiValue: widget.isMultiValue,
      );
    } catch (e) {
      throw Exception(
        'FormFieldBaseState must be used within a FormProvider widget. '
        'Ensure this widget is a descendant of a FormProvider.',
      );
    }
  }

  @override
  void dispose() {
    // Clean up by unregistering the field when the widget is disposed
    _formController?.unregisterField(widget.name);
    super.dispose();
  }

  /// Gets the current value for this field
  T? get value => _formController?.getValue<T>(widget.name);

  /// Gets the current values list for a multi-value field
  List<T>? get values => _formController?.getValues<T>(widget.name);

  /// Gets the current validation error for this field
  String? get error => _formController?.getError(widget.name);

  /// Whether this field is currently performing async validation
  bool get isAsyncValidating =>
      _formController?.isFieldAsyncValidating(widget.name) ?? false;

  /// Updates the field's value and marks it as touched
  ///
  /// [newValue] The new value to set
  void updateValue(T? newValue) {
    if (_formController != null) {
      _formController?.setFieldValue(widget.name, newValue);
      _formController?.touchField(widget.name);
    }
  }

  /// Updates multiple values for a multi-value field and marks it as touched
  ///
  /// [newValues] The new list of values to set
  void updateValues(List<T> newValues) {
    if (_formController != null && widget.isMultiValue) {
      _formController?.setFieldValues<T>(widget.name, newValues);
      _formController?.touchField(widget.name);
    }
  }

  /// Performs asynchronous validation of this field
  ///
  /// Returns true if the field is valid, false otherwise
  Future<bool> validateAsync() async {
    if (_formController != null) {
      return await _formController!.validateFieldAsync(widget.name);
    }
    return true;
  }

  /// Performs synchronous validation of this field
  ///
  /// Returns true if the field is valid, false otherwise
  bool validate() {
    return _formController?.validateField(widget.name) ?? true;
  }
}
