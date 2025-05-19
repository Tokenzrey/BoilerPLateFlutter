/// {@template form_provider}
/// Widget provider for FormController dependency injection.
/// Allows descendant widgets to access form functionality via InheritedWidget pattern.
/// {@endtemplate}
library;

import 'package:flutter/material.dart';
import 'form_controller.dart';

/// {@template form_provider}
/// InheritedNotifier widget that provides form controller access to the widget tree.
/// Use FormProvider.of(context) in descendant widgets to access the form controller.
/// {@endtemplate}
class FormProvider extends InheritedNotifier<FormController> {
  /// {@template form_provider_constructor}
  /// Creates a FormProvider widget.
  ///
  /// [controller] The form controller to provide to descendants
  /// [child] The child widget
  /// {@endtemplate}
  const FormProvider({
    super.key,
    required FormController controller,
    required super.child,
  }) : super(notifier: controller);

  /// Retrieves the form controller from the closest FormProvider ancestor
  static FormController of(BuildContext context) {
    final provider = context.dependOnInheritedWidgetOfExactType<FormProvider>();
    if (provider == null) {
      throw Exception('FormProvider not found in widget tree. '
          'Make sure to wrap your form with a FormProvider widget.');
    }
    return provider.notifier!;
  }
}
