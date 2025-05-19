/// {@template form_context_extension}
/// Extension methods on BuildContext to provide convenient access to form functionality.
/// Simplifies form operations like submission, reset, and status checking.
/// {@endtemplate}
library;

import 'package:flutter/material.dart';
import 'app_form.dart';
import 'form_controller.dart';
import 'form_provider.dart';

/// {@template form_context_extension}
/// Extension methods on BuildContext that make it easier to work with forms.
/// Provides direct access to common form operations from any widget with access to context.
/// {@endtemplate}
extension FormContextExtension on BuildContext {
  /// Gets the form controller from the nearest FormProvider ancestor
  FormController get form => FormProvider.of(this);

  /// Submits the form, delegating to AppForm if available, otherwise using the controller directly
  ///
  /// Returns a Future with the form values if validation succeeds
  Future<Map<String, dynamic>> submitForm() async {
    final appFormState = findAncestorStateOfType<AppFormState>();
    if (appFormState != null) {
      return appFormState.submitForm();
    } else {
      return FormProvider.of(this).submit();
    }
  }

  /// Resets the form, delegating to AppForm if available, otherwise using the controller directly
  void resetForm() {
    final appFormState = findAncestorStateOfType<AppFormState>();
    if (appFormState != null) {
      appFormState.resetForm();
    } else {
      FormProvider.of(this).reset();
    }
  }

  /// Whether the form is currently in the process of submitting
  bool get isFormSubmitting {
    final appFormState = findAncestorStateOfType<AppFormState>();
    if (appFormState != null) {
      return appFormState.isSubmitting;
    } else {
      return FormProvider.of(this).isSubmitting;
    }
  }

  /// Whether the form has been submitted at least once
  bool get hasFormBeenSubmitted {
    final appFormState = findAncestorStateOfType<AppFormState>();
    if (appFormState != null) {
      return appFormState.hasBeenSubmitted;
    } else {
      return FormProvider.of(this).hasBeenSubmitted;
    }
  }

  /// Whether any field in the form is currently performing asynchronous validation
  bool get hasAsyncValidationInProgress {
    final controller = FormProvider.of(this);
    return controller.hasAsyncValidationInProgress();
  }
}
