/// {@template label_text}
/// A customizable label text widget that displays a field label with an optional required indicator.
/// Used to provide consistent labeling for form fields and other UI components.
/// {@endtemplate}
library;

import 'package:flutter/material.dart';

/// {@template label_text}
/// Displays a label text with an optional required indicator.
///
/// This widget is designed for form fields to show a consistent label style
/// with the ability to indicate required fields. The required indicator
/// (typically an asterisk) can be customized.
/// {@endtemplate}
class LabelText extends StatelessWidget {
  /// The label text to display
  final String text;

  /// Whether this field is required
  final bool isRequired;

  /// Optional custom text style. If not provided, uses theme defaults.
  final TextStyle? style;

  /// Color for the required indicator. Defaults to theme's error color.
  final Color? requiredColor;

  /// Text alignment for the label
  final TextAlign textAlign;

  /// Spacing between the label text and required indicator
  final double requiredSpacing;

  /// Whether to show the required indicator for required fields
  final bool showRequiredIndicator;

  /// Character or string to use as the required indicator
  final String requiredIndicator;

  /// {@template label_text_constructor}
  /// Creates a label text widget.
  ///
  /// [text] The label text to display.
  /// [isRequired] Whether this field is required, affecting indicator display.
  /// [style] Optional style override for the label text.
  /// [requiredColor] Optional color override for the required indicator.
  /// [textAlign] Text alignment for the label.
  /// [requiredSpacing] Space between label and required indicator.
  /// [showRequiredIndicator] Whether to show the required indicator.
  /// [requiredIndicator] Character or string to use as the required indicator.
  /// {@endtemplate}
  const LabelText(
    this.text, {
    super.key,
    this.isRequired = false,
    this.style,
    this.requiredColor,
    this.textAlign = TextAlign.start,
    this.requiredSpacing = 2.0,
    this.showRequiredIndicator = true,
    this.requiredIndicator = '*',
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final effectiveStyle = style ??
        theme.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w500,
          color: theme.colorScheme.onSurface,
        );

    final showAsterisk = isRequired && showRequiredIndicator;

    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              text,
              style: effectiveStyle,
              textAlign: textAlign,
            ),
          ),
          if (showAsterisk) ...[
            SizedBox(width: requiredSpacing),
            Text(
              requiredIndicator,
              style: effectiveStyle?.copyWith(
                color: requiredColor ?? theme.colorScheme.error,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
