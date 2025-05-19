/// {@template app_form}
/// A high-level widget that manages a form and handles common form scenarios.
/// Provides autovalidation, submission handling, and error reporting.
/// {@endtemplate}
library;

import 'package:flutter/material.dart';
import 'form_controller.dart';
import 'form_provider.dart';
import 'form_validation_exception.dart';

/// {@template app_form}
/// A full-featured form widget that combines FormController and Flutter's Form widget.
/// Handles validation modes, submission callbacks, and error reporting.
/// {@endtemplate}
class AppForm extends StatefulWidget {
  /// The child widget (form content)
  final Widget child;

  /// Optional external form controller
  final FormController? controller;

  /// Callback for successful form submission
  final Function(Map<String, dynamic> values)? onSubmit;

  /// Callback for validation errors
  final Function(Map<String, String?> errors)? onError;

  /// Callback when form is reset
  final VoidCallback? onReset;

  /// Controls when validation happens automatically
  final AutovalidateMode autovalidateMode;

  /// Padding applied to the form content
  final EdgeInsets padding;

  /// {@template app_form_constructor}
  /// Creates an AppForm widget.
  ///
  /// [child] The form content widget tree
  /// [controller] Optional external form controller (one will be created if not provided)
  /// [onSubmit] Optional callback for when form is successfully submitted
  /// [onError] Optional callback for when form validation fails
  /// [onReset] Optional callback for when form is reset
  /// [autovalidateMode] When validation should happen automatically
  /// [padding] Padding to apply around form content
  /// {@endtemplate}
  const AppForm({
    super.key,
    required this.child,
    this.controller,
    this.onSubmit,
    this.onError,
    this.onReset,
    this.autovalidateMode = AutovalidateMode.disabled,
    this.padding = EdgeInsets.zero,
  });

  @override
  State<AppForm> createState() => AppFormState();
}

/// {@template app_form_state}
/// State class for AppForm that manages validation modes and form lifecycle.
/// {@endtemplate}
class AppFormState extends State<AppForm> {
  /// The form controller used by this form
  late FormController _controller;

  /// Current validation mode, may change based on form interaction
  AutovalidateMode _currentValidateMode;

  /// Whether the form is currently in the submission process
  bool get isSubmitting => _controller.isSubmitting;

  /// Whether the form has been submitted at least once
  bool get hasBeenSubmitted => _controller.hasBeenSubmitted;

  /// Creates an AppFormState with validation initially disabled
  AppFormState() : _currentValidateMode = AutovalidateMode.disabled;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? FormController();
    _currentValidateMode = widget.autovalidateMode;

    // Set up listeners based on validation mode
    if (_currentValidateMode == AutovalidateMode.always) {
      _controller.addListener(_validateIfNeeded);
    }

    _controller.addListener(_checkSubmissionStatus);
  }

  /// Updates the validation mode when submission status changes
  void _checkSubmissionStatus() {
    if (_controller.hasBeenSubmitted &&
        _currentValidateMode == AutovalidateMode.disabled) {
      setState(() {
        _currentValidateMode = AutovalidateMode.onUserInteraction;
      });
    }
  }

  /// Triggers validation if the current validation mode requires it
  void _validateIfNeeded() {
    if (_currentValidateMode == AutovalidateMode.always) {
      _controller.validate();
    } else if (_currentValidateMode == AutovalidateMode.onUserInteraction &&
        _controller.hasBeenSubmitted) {
      _controller.validate();
    }
  }

  /// Submits the form and handles callbacks
  ///
  /// Returns a Future with the form values if validation succeeds
  Future<Map<String, dynamic>> submitForm() async {
    try {
      // If first submission, enable validation on user interaction from now on
      if (_currentValidateMode == AutovalidateMode.disabled) {
        setState(() {
          _currentValidateMode = AutovalidateMode.onUserInteraction;
        });
      }

      final result = await _controller.submit();
      if (widget.onSubmit != null) {
        widget.onSubmit!(result);
      }
      return result;
    } catch (e) {
      if (e is FormValidationException && widget.onError != null) {
        widget.onError!(e.fieldErrors);
      }
      rethrow;
    }
  }

  /// Resets the form to initial values and triggers the onReset callback
  void resetForm() {
    _controller.reset();
    if (widget.onReset != null) {
      widget.onReset!();
    }
  }

  @override
  void didUpdateWidget(AppForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update validation mode if changed (and not after submission)
    if (widget.autovalidateMode != oldWidget.autovalidateMode &&
        !_controller.hasBeenSubmitted) {
      _currentValidateMode = widget.autovalidateMode;
    }
  }

  @override
  void dispose() {
    // Only dispose the controller if we created it internally
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FormProvider(
      controller: _controller,
      child: Builder(
        builder: (context) {
          return Form(
            onChanged: () {
              if (_currentValidateMode == AutovalidateMode.onUserInteraction) {
                _validateIfNeeded();
              }
            },
            child: Padding(
              padding: widget.padding,
              child: widget.child,
            ),
          );
        },
      ),
    );
  }
}
