/// {@template multi_value_form_field_base}
/// Specialized base classes for form fields that handle multiple values.
/// Provides additional utilities for manipulating collections of values.
/// {@endtemplate}
library;

import 'form_field_base.dart';

/// {@template multi_value_form_field_base}
/// Base widget for form fields that handle multiple values, such as checkboxes,
/// multi-select dropdowns, or tag inputs.
/// {@endtemplate}
abstract class MultiValueFormFieldBase<T> extends FormFieldBase<List<T>> {
  /// {@template multi_value_form_field_base_constructor}
  /// Creates a multi-value form field base widget.
  ///
  /// [name] Unique identifier for this field
  /// [initialValue] Initial list of values
  /// [validator] Optional validator function for the entire list
  /// [asyncValidator] Optional async validator function
  /// {@endtemplate}
  const MultiValueFormFieldBase({
    super.key,
    required super.name,
    super.initialValue,
    super.validator,
    super.asyncValidator,
    super.isMultiValue = true, // Always true for multi-value fields
  });
}

/// {@template multi_value_form_field_base_state}
/// Base state class for multi-value form fields that provides helper methods
/// for managing collections of values.
/// {@endtemplate}
abstract class MultiValueFormFieldBaseState<T,
        W extends MultiValueFormFieldBase<T>>
    extends FormFieldBaseState<List<T>, W> {
  /// Gets the current list of values, defaulting to an empty list if null
  List<T> get valuesList => value ?? [];

  /// Adds a new value to the collection
  ///
  /// [item] The item to add
  void addValue(T item) {
    final currentValues = valuesList;
    updateValue([...currentValues, item]);
  }

  /// Removes a specific value from the collection
  ///
  /// [item] The item to remove
  void removeValue(T item) {
    final currentValues = valuesList;
    updateValue(currentValues.where((element) => element != item).toList());
  }

  /// Removes the value at a specific index
  ///
  /// [index] The index to remove
  void removeValueAt(int index) {
    final currentValues = valuesList;
    if (index >= 0 && index < currentValues.length) {
      final newValues = List<T>.from(currentValues)..removeAt(index);
      updateValue(newValues);
    }
  }

  /// Updates the value at a specific index
  ///
  /// [index] The index to update
  /// [newValue] The new value
  void updateValueAt(int index, T newValue) {
    final currentValues = valuesList;
    if (index >= 0 && index < currentValues.length) {
      final newValues = List<T>.from(currentValues)..[index] = newValue;
      updateValue(newValues);
    }
  }

  /// Reorders values within the collection
  ///
  /// [oldIndex] The current index of the item
  /// [newIndex] The target index to move the item to
  void reorderValues(int oldIndex, int newIndex) {
    final currentValues = valuesList;
    if (oldIndex >= 0 &&
        oldIndex < currentValues.length &&
        newIndex >= 0 &&
        newIndex <= currentValues.length) {
      final item = currentValues[oldIndex];
      final newValues = List<T>.from(currentValues)..removeAt(oldIndex);

      // Adjust the insert index if moving forward
      if (newIndex > oldIndex) {
        newIndex--;
      }

      newValues.insert(newIndex, item);
      updateValue(newValues);
    }
  }
}
