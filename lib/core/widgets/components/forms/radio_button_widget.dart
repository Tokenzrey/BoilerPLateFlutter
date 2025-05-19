// RadioButtonWidget<String>(
//   label: "Select Payment Method",
//   isRequired: true,
//   options: [
//     RadioOption(value: "credit", label: "Credit Card"),
//     RadioOption(value: "debit", label: "Debit Card"),
//     RadioOption(value: "paypal", label: "PayPal"),
//     RadioOption(value: "wallet", label: "E-Wallet", enabled: false),
//   ],
//   value: selectedPayment,
//   onChanged: (value) => setState(() => selectedPayment = value),
//   helperText: "Choose your preferred payment method",
//   errorText: paymentError,
//   horizontal: false,
// )

import 'package:flutter/material.dart';
import 'form_base/form_field_base.dart';
import 'label_text.dart';
import 'helper_text.dart';
import 'error_text.dart';

class FormRadioField<T> extends FormFieldBase<T> {
  final String? label;
  final String? helperText;
  final bool isRequired;
  final List<RadioOption<T>> options;
  final bool horizontal;
  final CrossAxisAlignment crossAxisAlignment;
  final double spacing;
  final double verticalSpacing;
  final TextStyle? radioLabelStyle;
  final Color? activeColor;
  final ValueChanged<T>? onChanged;

  const FormRadioField({
    super.key,
    required super.name,
    super.initialValue,
    super.validator,
    this.label,
    this.helperText,
    this.isRequired = false,
    required this.options,
    this.horizontal = false,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.spacing = 12.0,
    this.verticalSpacing = 8.0,
    this.radioLabelStyle,
    this.activeColor,
    this.onChanged,
  });

  @override
  State<FormRadioField<T>> createState() => _FormRadioFieldState<T>();
}

class _FormRadioFieldState<T> extends FormFieldBaseState<T, FormRadioField<T>> {
  void _handleValueChange(T newValue) {
    updateValue(newValue);
    if (widget.onChanged != null) {
      widget.onChanged!(newValue);
    }
  }

  @override
  Widget build(BuildContext context) {
    return RadioButtonWidget<T>(
      label: widget.label,
      helperText: widget.helperText,
      errorText: error,
      isRequired: widget.isRequired,
      options: widget.options,
      value: value,
      onChanged: _handleValueChange,
      horizontal: widget.horizontal,
      crossAxisAlignment: widget.crossAxisAlignment,
      spacing: widget.spacing,
      verticalSpacing: widget.verticalSpacing,
      radioLabelStyle: widget.radioLabelStyle,
      activeColor: widget.activeColor,
    );
  }
}

class RadioOption<T> {
  final T value;
  final String label;
  final bool enabled;

  const RadioOption({
    required this.value,
    required this.label,
    this.enabled = true,
  });
}

class RadioButtonWidget<T> extends StatelessWidget {
  final String? label;
  final String? helperText;
  final String? errorText;
  final bool isRequired;
  final List<RadioOption<T>> options;
  final T? value;
  final ValueChanged<T>? onChanged;
  final bool horizontal;
  final CrossAxisAlignment crossAxisAlignment;
  final double spacing;
  final double verticalSpacing;
  final TextStyle? radioLabelStyle;
  final Color? activeColor;

  const RadioButtonWidget({
    super.key,
    this.label,
    this.helperText,
    this.errorText,
    this.isRequired = false,
    required this.options,
    required this.value,
    required this.onChanged,
    this.horizontal = false,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.spacing = 12.0,
    this.verticalSpacing = 8.0,
    this.radioLabelStyle,
    this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasError = errorText != null && errorText!.isNotEmpty;
    final effectiveLabelStyle = radioLabelStyle ?? theme.textTheme.bodyMedium;

    return Column(
      crossAxisAlignment: crossAxisAlignment,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          LabelText(
            label!,
            isRequired: isRequired,
          ),
          SizedBox(height: verticalSpacing),
        ],
        horizontal
            ? _buildHorizontalRadios(theme, effectiveLabelStyle)
            : _buildVerticalRadios(theme, effectiveLabelStyle),
        if (helperText != null && helperText!.isNotEmpty && !hasError) ...[
          SizedBox(height: verticalSpacing),
          HelperText(helperText!),
        ],
        if (hasError) ...[
          SizedBox(height: verticalSpacing),
          ErrorMessage(errorText: errorText),
        ],
      ],
    );
  }

  Widget _buildVerticalRadios(ThemeData theme, TextStyle? labelStyle) {
    return Column(
      crossAxisAlignment: crossAxisAlignment,
      children: options.map((option) {
        return Padding(
          padding:
              EdgeInsets.only(bottom: option != options.last ? spacing : 0),
          child: _buildRadioOption(option, theme, labelStyle),
        );
      }).toList(),
    );
  }

  Widget _buildHorizontalRadios(ThemeData theme, TextStyle? labelStyle) {
    return Wrap(
      spacing: spacing,
      runSpacing: spacing,
      children: options.map((option) {
        return _buildRadioOption(option, theme, labelStyle);
      }).toList(),
    );
  }

  Widget _buildRadioOption(
      RadioOption<T> option, ThemeData theme, TextStyle? labelStyle) {
    return InkWell(
      onTap: option.enabled && onChanged != null
          ? () => onChanged!(option.value)
          : null,
      borderRadius: BorderRadius.circular(20),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Radio<T>(
            value: option.value,
            groupValue: value,
            onChanged: option.enabled && onChanged != null
                ? (newValue) => onChanged!(newValue as T)
                : null,
            activeColor: activeColor ?? theme.colorScheme.primary,
          ),
          Flexible(
            child: Text(
              option.label,
              style: labelStyle?.copyWith(
                color: option.enabled ? null : theme.disabledColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
