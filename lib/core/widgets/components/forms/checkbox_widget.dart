// CheckboxWidget(
//   title: "Terms and Conditions",
//   label: "I agree to the terms of service and privacy policy",
//   value: termsAccepted,
//   onChanged: (value) => setState(() => termsAccepted = value),
//   helperText: "You must accept the terms to continue",
//   errorText: !termsAccepted ? "You must accept the terms to continue" : null,
//   isRequired: true,
// )

import 'package:flutter/material.dart';
import 'form_base/form_field_base.dart';
import 'label_text.dart';
import 'helper_text.dart';
import 'error_text.dart';

class FormCheckboxField extends FormFieldBase<bool> {
  final String? title;
  final String? label;
  final String? helperText;
  final bool isRequired;
  final bool enabled;
  final CrossAxisAlignment crossAxisAlignment;
  final double verticalSpacing;
  final TextStyle? labelStyle;
  final Color? activeColor;
  final Color? borderColor;
  final ValueChanged<bool>? onChanged;

  const FormCheckboxField({
    super.key,
    required super.name,
    super.initialValue = false,
    super.validator,
    this.title,
    this.label,
    this.helperText,
    this.isRequired = false,
    this.enabled = true,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.verticalSpacing = 8.0,
    this.labelStyle,
    this.activeColor,
    this.borderColor,
    this.onChanged,
  }) : assert(title != null || label != null,
            'Either title or label must be provided');

  @override
  State<FormCheckboxField> createState() => _FormCheckboxFieldState();
}

class _FormCheckboxFieldState
    extends FormFieldBaseState<bool, FormCheckboxField> {
  void _handleValueChange(bool newValue) {
    updateValue(newValue);

    if (widget.onChanged != null) {
      widget.onChanged!(newValue);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CheckboxWidget(
      title: widget.title,
      label: widget.label,
      helperText: widget.helperText,
      errorText: error,
      isRequired: widget.isRequired,
      value: value ?? false,
      onChanged: widget.enabled ? _handleValueChange : null,
      enabled: widget.enabled,
      crossAxisAlignment: widget.crossAxisAlignment,
      verticalSpacing: widget.verticalSpacing,
      labelStyle: widget.labelStyle,
      activeColor: widget.activeColor,
      borderColor: widget.borderColor,
    );
  }
}

class CheckboxWidget extends StatelessWidget {
  final String? title;
  final String? label;
  final String? helperText;
  final String? errorText;
  final bool isRequired;
  final bool value;
  final ValueChanged<bool>? onChanged;
  final bool enabled;
  final CrossAxisAlignment crossAxisAlignment;
  final double verticalSpacing;
  final TextStyle? labelStyle;
  final Color? activeColor;
  final Color? borderColor;

  const CheckboxWidget({
    super.key,
    this.title,
    this.label,
    this.helperText,
    this.errorText,
    this.isRequired = false,
    required this.value,
    required this.onChanged,
    this.enabled = true,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.verticalSpacing = 8.0,
    this.labelStyle,
    this.activeColor,
    this.borderColor,
  }) : assert(title != null || label != null,
            'Either title or label must be provided');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasError = errorText != null && errorText!.isNotEmpty;
    final effectiveLabelStyle = labelStyle ?? theme.textTheme.bodyMedium;

    return Column(
      crossAxisAlignment: crossAxisAlignment,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (title != null) ...[
          LabelText(
            title!,
            isRequired: isRequired,
          ),
          SizedBox(height: verticalSpacing),
        ],
        InkWell(
          onTap: enabled && onChanged != null ? () => onChanged!(!value) : null,
          borderRadius: BorderRadius.circular(4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 24,
                height: 24,
                child: Checkbox(
                  value: value,
                  onChanged: enabled && onChanged != null
                      ? (newValue) => onChanged!(newValue ?? false)
                      : null,
                  activeColor: activeColor ?? theme.colorScheme.primary,
                  side: borderColor != null
                      ? BorderSide(color: borderColor!)
                      : null,
                ),
              ),
              const SizedBox(width: 8),
              if (label != null)
                Expanded(
                  child: Text(
                    label!,
                    style: effectiveLabelStyle?.copyWith(
                      color: enabled ? null : theme.disabledColor,
                    ),
                  ),
                ),
            ],
          ),
        ),
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
}
