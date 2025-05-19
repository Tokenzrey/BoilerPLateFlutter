/// {@template helper_text}
/// A customizable helper text widget that displays informational text with an optional icon.
/// Used to provide context, hints, or additional information for form fields and UI components.
/// {@endtemplate}
library;

import 'package:flutter/material.dart';

/// {@template helper_text}
/// Displays helper or informational text with an optional icon.
///
/// This widget is designed to show additional information or guidance in forms
/// with a consistent style. It's commonly used below form fields to provide
/// hints or context about the expected input.
/// {@endtemplate}
class HelperText extends StatelessWidget {
  /// The text content to display
  final String text;

  /// Optional custom text style. If not provided, defaults to the theme's bodySmall style.
  final TextStyle? style;

  /// The color for the text and icon. Defaults to a semi-transparent onSurface color.
  final Color? color;

  /// Text alignment for the helper text.
  final TextAlign textAlign;

  /// Optional icon to display alongside the text. If null, only text is shown.
  final IconData? icon;

  /// Size of the icon if one is displayed.
  final double? iconSize;

  /// {@template helper_text_constructor}
  /// Creates a helper text widget.
  ///
  /// [text] The informational text to display.
  /// [style] Optional style override for the text.
  /// [color] Optional color override for the text and icon.
  /// [textAlign] Text alignment for the displayed text.
  /// [icon] Optional icon to display before the text.
  /// [iconSize] The size of the icon if displayed.
  /// {@endtemplate}
  const HelperText(
    this.text, {
    super.key,
    this.style,
    this.color,
    this.textAlign = TextAlign.start,
    this.icon,
    this.iconSize = 14.0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final effectiveColor =
        color ?? theme.colorScheme.onSurface.withValues(alpha: 0.7);

    final effectiveStyle = style ??
        theme.textTheme.bodySmall?.copyWith(
          color: effectiveColor,
        );

    if (icon != null) {
      return Padding(
        padding: const EdgeInsets.only(top: 4.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon!,
              size: iconSize,
              color: effectiveStyle?.color,
            ),
            const SizedBox(width: 4.0),
            Flexible(
              child: Text(
                text,
                style: effectiveStyle,
                textAlign: textAlign,
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(top: 4.0),
      child: Text(
        text,
        style: effectiveStyle,
        textAlign: textAlign,
      ),
    );
  }
}
