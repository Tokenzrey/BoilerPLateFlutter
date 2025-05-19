// SwitchInputWidget(
//   title: "Notification Settings",
//   label: "Receive promotional emails",
//   value: receiveEmails,
//   onChanged: (value) => setState(() => receiveEmails = value),
//   helperText: "We'll send you occasional updates and offers",
// )

import 'package:flutter/material.dart';
import 'form_base/form_field_base.dart';
import 'label_text.dart';
import 'helper_text.dart';
import 'error_text.dart';

class FormSwitchField extends FormFieldBase<bool> {
  final String? title;
  final String? label;
  final String? helperText;
  final bool isRequired;
  final bool enabled;
  final CrossAxisAlignment crossAxisAlignment;
  final double verticalSpacing;
  final TextStyle? labelStyle;
  final Color? activeColor;
  final Color? trackColor;
  final Color? thumbColor;
  final ValueChanged<bool>? onChanged;

  const FormSwitchField({
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
    this.trackColor,
    this.thumbColor,
    this.onChanged,
  }) : assert(title != null || label != null,
            'Either title or label must be provided');

  @override
  State<FormSwitchField> createState() => _FormSwitchFieldState();
}

class _FormSwitchFieldState extends FormFieldBaseState<bool, FormSwitchField> {
  void _handleValueChanged(bool newValue) {
    updateValue(newValue);
    if (widget.onChanged != null) {
      widget.onChanged!(newValue);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SwitchInputWidget(
      title: widget.title,
      label: widget.label,
      helperText: widget.helperText,
      errorText: error,
      isRequired: widget.isRequired,
      value: value ?? false,
      onChanged: widget.enabled ? _handleValueChanged : null,
      enabled: widget.enabled,
      crossAxisAlignment: widget.crossAxisAlignment,
      verticalSpacing: widget.verticalSpacing,
      labelStyle: widget.labelStyle,
      activeColor: widget.activeColor,
      trackColor: widget.trackColor,
      thumbColor: widget.thumbColor,
    );
  }
}

class SwitchInputWidget extends StatelessWidget {
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
  final Color? trackColor;
  final Color? thumbColor;

  const SwitchInputWidget({
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
    this.trackColor,
    this.thumbColor,
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
          borderRadius: BorderRadius.circular(20),
          child: Row(
            children: [
              Switch(
                value: value,
                onChanged: enabled && onChanged != null
                    ? (newValue) => onChanged!(newValue)
                    : null,
                activeColor: activeColor ?? theme.colorScheme.primary,
                activeTrackColor: trackColor,
                inactiveThumbColor: thumbColor,
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
