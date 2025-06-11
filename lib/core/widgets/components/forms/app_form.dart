import 'dart:async';
import 'package:flutter/widgets.dart';

/// Defines when form validation should be triggered.
enum ValidationMode {
  /// Validation happens only when the form is submitted.
  onSubmit,

  /// Validation happens whenever a field's value changes.
  onChange,

  /// Validation happens when a field loses focus.
  onBlur,
}

/// The base for all validation rules.
///
/// This abstract class provides the foundation for creating reusable
/// validation rules that can be applied to form fields.
abstract class ValidationRule<V> {
  /// Validates the given value for a field.
  ///
  /// Returns an error message string if the value is invalid,
  /// or null if the value is valid.
  ///
  /// [value] is the value to validate.
  /// [fieldName] is the name of the field being validated, which can
  /// be used to create more descriptive error messages.
  String? validate(V? value, String fieldName);
}

/// Validates that a value is not null or empty.
class RequiredRule<V> extends ValidationRule<V> {
  /// The error message to display when validation fails.
  final String message;

  /// Creates a rule that validates that a value is not null or empty.
  RequiredRule({this.message = 'This field is required'});

  @override
  String? validate(V? value, String fieldName) {
    if (value == null) {
      return message;
    }

    if (value is String && value.trim().isEmpty) {
      return message;
    }

    if (value is List && value.isEmpty) {
      return message;
    }

    if (value is Map && value.isEmpty) {
      return message;
    }

    return null;
  }
}

/// Validates that a string value has a minimum length.
class MinLengthRule extends ValidationRule<String> {
  /// The minimum length required.
  final int minLength;

  /// The error message to display when validation fails.
  final String message;

  /// Creates a rule that validates a string has a minimum length.
  MinLengthRule(this.minLength, {String? message})
      : message = message ?? 'Must be at least $minLength characters';

  @override
  String? validate(String? value, String fieldName) {
    if (value == null || value.length < minLength) {
      return message;
    }
    return null;
  }
}

/// Validates that a string value matches a regular expression pattern.
class PatternRule extends ValidationRule<String> {
  /// The pattern to match.
  final RegExp pattern;

  /// The error message to display when validation fails.
  final String message;

  /// Creates a rule that validates a string matches a pattern.
  PatternRule(this.pattern, {required this.message});

  @override
  String? validate(String? value, String fieldName) {
    if (value == null || !pattern.hasMatch(value)) {
      return message;
    }
    return null;
  }
}

/// Email validation rule using a common email regex pattern.
class EmailRule extends PatternRule {
  /// Creates a rule that validates an email address format.
  EmailRule({String message = 'Please enter a valid email'})
      : super(
          RegExp(r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+'),
          message: message,
        );
}

/// An immutable data class representing the complete state of a single form field.
class FieldState<V> {
  /// The current value of the field.
  final V? value;

  /// The validation error message, if any.
  final String? error;

  /// Whether the field has been interacted with (focused).
  final bool isTouched;

  /// Whether the field's value has been changed.
  final bool isDirty;

  /// Creates a new field state instance.
  const FieldState({
    this.value,
    this.error,
    this.isTouched = false,
    this.isDirty = false,
  });

  /// Creates a copy of this FieldState with the given fields replaced with new values.
  FieldState<V> copyWith({
    V? value,
    Object? error = const _Unset(),
    bool? isTouched,
    bool? isDirty,
  }) {
    return FieldState<V>(
      value: value ?? this.value,
      error: error is _Unset ? this.error : (error as String?),
      isTouched: isTouched ?? this.isTouched,
      isDirty: isDirty ?? this.isDirty,
    );
  }
}

/// Private class used to differentiate between a null value and an unset value
/// in the copyWith method.
class _Unset {
  const _Unset();
}

/// Manages the state and interactions for a single field.
class FieldController<V> {
  /// The name of the field in the form.
  final String name;

  /// List of validation rules for this field.
  final List<ValidationRule<V>> rules;

  /// A notifier that emits the current field state.
  final ValueNotifier<FieldState<V>> _stateNotifier;

  /// The parent form controller.
  final FormController _formController;

  /// Stream controller for value changes.
  final StreamController<V> _valueStreamController;

  /// Creates a new field controller.
  FieldController(
    this.name,
    this._formController,
    V? defaultValue,
    this.rules,
  )   : _stateNotifier = ValueNotifier(FieldState<V>(value: defaultValue)),
        _valueStreamController = StreamController<V>.broadcast() {
    // Connect the state changes to the stream
    _stateNotifier.addListener(() {
      if (_stateNotifier.value.value != null) {
        _valueStreamController.add(_stateNotifier.value.value as V);
      }
    });
  }

  /// The current field state.
  FieldState<V> get state => _stateNotifier.value;

  /// A listenable that emits the current field state.
  ValueNotifier<FieldState<V>> get stateNotifier => _stateNotifier;

  /// A stream of value changes for this field.
  Stream<V> get valueStream => _valueStreamController.stream;

  /// The current value of the field.
  V? get value => state.value;

  /// The current error message, if any.
  String? get error => state.error;

  /// Whether the field has been touched.
  bool get isTouched => state.isTouched;

  /// Whether the field's value has changed.
  bool get isDirty => state.isDirty;

  /// Sets the value of this field.
  void setValue(V? value,
      {bool shouldValidate = false, bool markDirty = true}) {
    final newState = state.copyWith(
      value: value,
      isDirty: markDirty,
    );
    _stateNotifier.value = newState;

    // Update the form's internal value
    _formController._updateFieldValue(name, value);

    if (_formController._validationMode == ValidationMode.onChange ||
        shouldValidate) {
      validate();
    }
  }

  /// Marks the field as touched.
  void markAsTouched() {
    if (!state.isTouched) {
      _stateNotifier.value = state.copyWith(isTouched: true);
    }

    if (_formController._validationMode == ValidationMode.onBlur) {
      validate();
      _formController._updateFormState();
    }
  }

  /// Sets an error message for this field.
  void setError(String? errorMessage) {
    _stateNotifier.value = state.copyWith(error: errorMessage);
  }

  /// Clears any error message for this field.
  void clearError() {
    setError(null);
  }

  /// Validates this field against its validation rules.
  ///
  /// Returns true if the field is valid, false otherwise.
  bool validate() {
    bool isValid = true;
    for (final rule in rules) {
      final error = rule.validate(state.value, name);
      if (error != null) {
        setError(error);
        isValid = false;
        return false;
      }
    }

    clearError();
    return isValid;
  }

  /// Resets this field to its default value and clears its state.
  void reset(V? defaultValue) {
    _stateNotifier.value = FieldState<V>(value: defaultValue);
  }

  /// Disposes resources used by this controller.
  void dispose() {
    _stateNotifier.dispose();
    _valueStreamController.close();
  }
}

/// The central controller for the entire form.
///
/// Manages overall state, field registration, validation, and submission.
class FormController<T> {
  /// The validation mode for the form.
  final ValidationMode _validationMode;

  /// Function to convert from internal Map to type T.
  ///
  /// Converts a `Map&lt;String, dynamic&gt;` to type `T`.
  final T Function(Map<String, dynamic>) _fromJson;

  /// Function to convert from type T to internal Map.
  ///
  /// Converts a type `T` to `Map&lt;String, dynamic&gt;`.
  final Map<String, dynamic> Function(T) _toJson;

  /// The default values for the form.
  final Map<String, dynamic> _defaultValues;

  /// Internal map of field values.
  final Map<String, dynamic> _values = {};

  /// Map of registered field controllers.
  final Map<String, FieldController> _fields = {};

  /// Stream controller for value changes.
  final StreamController<Map<String, dynamic>> _valueStreamController;

  /// Notifier for the submitting state.
  final ValueNotifier<bool> _isSubmittingNotifier;

  /// Notifier for the form validity state.
  final ValueNotifier<bool> _isValidNotifier;

  /// Notifier for the touched state.
  final ValueNotifier<bool> _isTouchedNotifier;

  /// Notifier for the dirty state.
  final ValueNotifier<bool> _isDirtyNotifier;

  /// Notifier for the form errors.
  final ValueNotifier<Map<String, String?>> _errorsNotifier;

  FormController({
    T? defaultValues,
    ValidationMode mode = ValidationMode.onSubmit,
    required T Function(Map<String, dynamic>) fromJson,
    required Map<String, dynamic> Function(T) toJson,
  })  : _validationMode = mode,
        _fromJson = fromJson,
        _toJson = toJson,
        _defaultValues = defaultValues != null ? toJson(defaultValues) : {},
        _valueStreamController =
            StreamController<Map<String, dynamic>>.broadcast(),
        _isSubmittingNotifier = ValueNotifier(false),
        _isValidNotifier = ValueNotifier(true),
        _isTouchedNotifier = ValueNotifier(false),
        _isDirtyNotifier = ValueNotifier(false),
        _errorsNotifier = ValueNotifier({}) {
    // Initialize values with default values
    _values.addAll(_defaultValues);
  }

  // Add this to FormController class in app_form.dart
  ValidationMode get validationMode => _validationMode;

  /// Whether the form is currently being submitted.
  bool get isSubmitting => _isSubmittingNotifier.value;

  /// Whether the form is currently valid (no validation errors).
  bool get isValid => _isValidNotifier.value;

  /// Whether any field in the form has been touched.
  bool get isTouched => _isTouchedNotifier.value;

  /// Whether any field in the form is dirty (value has changed).
  bool get isDirty => _isDirtyNotifier.value;

  /// A map of field names to error messages.
  Map<String, String?> get errors => Map.unmodifiable(_errorsNotifier.value);

  /// A listenable that emits whether the form is being submitted.
  ValueNotifier<bool> get isSubmittingNotifier => _isSubmittingNotifier;

  /// A listenable that emits whether the form is currently valid.
  ValueNotifier<bool> get isValidNotifier => _isValidNotifier;

  /// A listenable that emits whether any field has been touched.
  ValueNotifier<bool> get isTouchedNotifier => _isTouchedNotifier;

  /// A listenable that emits whether any field is dirty.
  ValueNotifier<bool> get isDirtyNotifier => _isDirtyNotifier;

  /// A listenable that emits the current form errors.
  ValueNotifier<Map<String, String?>> get errorsNotifier => _errorsNotifier;

  /// Registers a field with the form.
  ///
  /// [name] is the unique identifier for the field.
  /// [defaultValue] is the initial value for the field.
  /// [rules] is a list of validation rules to apply to the field.
  ///
  /// Returns a [FieldController] that can be used to interact with the field.
  FieldController<V> register<V>(
    String name, {
    V? defaultValue,
    List<ValidationRule<V>> rules = const [],
  }) {
    // Check if field is already registered
    if (_fields.containsKey(name)) {
      return _fields[name] as FieldController<V>;
    }

    // Use default value from form defaults if provided
    final fieldDefaultValue = _defaultValues.containsKey(name)
        ? _defaultValues[name] as V?
        : defaultValue;

    // Create the field controller
    final controller = FieldController<V>(
      name,
      this,
      fieldDefaultValue,
      rules,
    );

    // Register the field
    _fields[name] = controller;
    _values[name] = fieldDefaultValue;

    return controller;
  }

  /// Updates a field's value in the internal values map.
  void _updateFieldValue(String name, dynamic value) {
    _values[name] = value;
    _updateFormState();
    _valueStreamController.add(Map.unmodifiable(_values));
  }

  /// Updates the overall form state based on field states.
  void _updateFormState() {
    bool isFormTouched = false;
    bool isFormDirty = false;
    final errors = <String, String?>{};

    for (final entry in _fields.entries) {
      final fieldController = entry.value;
      final fieldName = entry.key;

      if (fieldController.isTouched) {
        isFormTouched = true;
      }

      if (fieldController.isDirty) {
        isFormDirty = true;
      }

      if (fieldController.error != null) {
        errors[fieldName] = fieldController.error;
      }
    }

    _isTouchedNotifier.value = isFormTouched;
    _isDirtyNotifier.value = isFormDirty;
    _isValidNotifier.value = errors.isEmpty;
    _errorsNotifier.value = Map.unmodifiable(errors);
  }

  /// Sets a field's value programmatically.
  ///
  /// [name] is the name of the field to update.
  /// [value] is the new value to set.
  /// [shouldValidate] determines whether to validate the field after setting.
  /// [markDirty] determines whether to mark the field as dirty.
  void setValue<V>(String name, V value,
      {bool shouldValidate = false, bool markDirty = true}) {
    final field = _fields[name];
    if (field != null) {
      (field as FieldController<V>).setValue(value,
          shouldValidate: shouldValidate, markDirty: markDirty);
    } else {
      _values[name] = value;
      _valueStreamController.add(Map.unmodifiable(_values));
    }
  }

  /// Sets an error for a specific field.
  ///
  /// [name] is the name of the field to set the error for.
  /// [message] is the error message to set.
  void setError(String name, String message) {
    final field = _fields[name];
    if (field != null) {
      field.setError(message);
      _updateFormState();
    }
  }

  /// Clears errors for a specific field or all fields.
  ///
  /// If [name] is provided, clears errors only for that field.
  /// If [name] is omitted, clears errors for all fields.
  void clearErrors([String? name]) {
    if (name != null) {
      final field = _fields[name];
      if (field != null) {
        field.clearError();
      }
    } else {
      for (final field in _fields.values) {
        field.clearError();
      }
    }
    _updateFormState();
  }

  /// Retrieves the current value of a single field.
  ///
  /// [name] is the name of the field to get the value for.
  dynamic getValue(String name) {
    return _values[name];
  }

  /// Converts the internal form values map into a strongly-typed T object.
  T getValues() {
    return _fromJson(Map.unmodifiable(_values));
  }

  /// Returns a Stream that emits new values whenever the specified field changes.
  ///
  /// [name] is the name of the field to watch.
  Stream<V> watch<V>(String name) {
    final field = _fields[name];
    if (field != null) {
      return (field as FieldController<V>).valueStream;
    }

    // If field is not registered yet, create a stream that will emit once
    // when the field is registered
    final controller = StreamController<V>.broadcast();
    register<V>(name).stateNotifier.addListener(() {
      final value = _values[name];
      if (value != null) {
        controller.add(value as V);
      }
    });
    return controller.stream;
  }

  /// Returns a Stream that emits the entire map of form values on any change.
  Stream<Map<String, dynamic>> watchAll() {
    return _valueStreamController.stream;
  }

  /// Validates all fields in the form.
  ///
  /// Returns true if all fields are valid, false otherwise.
  bool validate() {
    bool isValid = true;

    for (final field in _fields.values) {
      final fieldValid = field.validate();
      if (!fieldValid) {
        isValid = false;
      }
    }

    _updateFormState();
    return isValid;
  }

  /// Handles form submission.
  ///
  /// First triggers validation on all fields. If valid, it calls [onValid]
  /// with the type-safe data. If invalid, it calls [onInvalid] with a map
  /// of errors.
  ///
  /// [onValid] callback function called with form data when validation passes.
  /// [onInvalid] optional callback function called with errors when validation fails.
  Future<void> handleSubmit(
    FutureOr<void> Function(T data) onValid, {
    void Function(Map<String, String?> errors)? onInvalid,
  }) async {
    _isSubmittingNotifier.value = true;

    try {
      final isValid = validate();

      if (isValid) {
        final data = getValues();
        await onValid(data);
      } else {
        onInvalid?.call(errors);
      }
    } finally {
      _isSubmittingNotifier.value = false;
    }
  }

  /// Resets the entire form's state.
  ///
  /// If [data] is provided, the form resets to that data's values.
  /// Otherwise, it resets to the initial [defaultValues].
  void reset({T? data}) {
    final values = data != null
        ? _toJson(data)
        : Map<String, dynamic>.from(_defaultValues);

    _values.clear();
    _values.addAll(values);

    for (final entry in _fields.entries) {
      final fieldName = entry.key;
      final fieldController = entry.value;
      final fieldValue = _values[fieldName];
      fieldController.reset(fieldValue);
    }

    _updateFormState();
    _valueStreamController.add(Map.unmodifiable(_values));
  }

  /// Disposes resources used by this controller.
  void dispose() {
    for (final field in _fields.values) {
      field.dispose();
    }
    _fields.clear();

    _valueStreamController.close();
    _isSubmittingNotifier.dispose();
    _isValidNotifier.dispose();
    _isTouchedNotifier.dispose();
    _isDirtyNotifier.dispose();
    _errorsNotifier.dispose();
  }
}

/// Provides the FormController instance to the widget tree.
///
/// Used to access the FormController of type `T` from descendant widgets.
class FormScope<T> extends InheritedWidget {
  /// The form controller instance that will be provided to descendants.
  final FormController<T> controller;

  /// Creates a new form scope.
  const FormScope({
    super.key,
    required this.controller,
    required super.child,
  });

  /// Gets the FormController of type `T` from the closest FormScope ancestor.
  static FormController<T> of<T>(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<FormScope<T>>();
    if (scope == null) {
      throw FlutterError.fromParts([
        ErrorSummary('No FormScope found in widget tree'),
        ErrorDescription(
          'FormScope.of() was called with a context that does not contain a FormScope.',
        ),
        ErrorHint(
          'To use a FormController, ensure there is a FormScope or FormBuilder '
          'above the widget tree where FormScope.of() is called.',
        ),
      ]);
    }
    return scope.controller;
  }

  /// Gets the FormController of type `T` without rebuilding when the form changes.
  static FormController<T> read<T>(BuildContext context) {
    final scope = context
        .getElementForInheritedWidgetOfExactType<FormScope<T>>()
        ?.widget as FormScope<T>?;
    if (scope == null) {
      throw FlutterError.fromParts([
        ErrorSummary('No FormScope found in widget tree'),
        ErrorDescription(
          'FormScope.read() was called with a context that does not contain a FormScope.',
        ),
        ErrorHint(
          'To use a FormController, ensure there is a FormScope or FormBuilder '
          'above the widget tree where FormScope.read() is called.',
        ),
      ]);
    }
    return scope.controller;
  }

  @override
  bool updateShouldNotify(FormScope<T> oldWidget) {
    return controller != oldWidget.controller;
  }
}

/// A convenience widget that instantiates the FormController and provides it via FormScope.
class FormBuilder<T> extends StatefulWidget {
  /// The default values for the form.
  final T? defaultValues;

  /// When form validation should be triggered.
  final ValidationMode validationMode;

  /// Function to convert from internal Map to type T.
  final T Function(Map<String, dynamic>) fromJson;

  /// Function to convert from type T to internal Map.
  final Map<String, dynamic> Function(T) toJson;

  /// The builder function that builds the form UI.
  final Widget Function(BuildContext context, FormController<T> controller)
      builder;

  /// Creates a new form builder.
  const FormBuilder({
    super.key,
    this.defaultValues,
    this.validationMode = ValidationMode.onSubmit,
    required this.fromJson,
    required this.toJson,
    required this.builder,
  });

  @override
  State<FormBuilder<T>> createState() => _FormBuilderState<T>();
}

class _FormBuilderState<T> extends State<FormBuilder<T>> {
  late FormController<T> _controller;

  @override
  void initState() {
    super.initState();
    _controller = FormController<T>(
      defaultValues: widget.defaultValues,
      mode: widget.validationMode,
      fromJson: widget.fromJson,
      toJson: widget.toJson,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FormScope<T>(
      controller: _controller,
      child: Builder(
        builder: (context) => widget.builder(context, _controller),
      ),
    );
  }
}
