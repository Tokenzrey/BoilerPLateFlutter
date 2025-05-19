/// {@template error_message}
/// A customizable error message widget that displays text with an optional icon.
/// Used to show validation errors or other error states in forms and UI components.
/// {@endtemplate}
// ignore_for_file: deprecated_member_use

library;

import 'package:flutter/material.dart';

/// {@template error_message}
/// Displays an error message with an optional icon.
///
/// This widget is designed to show validation errors in forms with a consistent style,
/// but can be customized for various use cases. When no error text is provided,
/// the widget renders as an empty SizedBox to maintain layout consistency.
/// {@endtemplate}
class ErrorMessage extends StatelessWidget {
  /// The error text to display. If null or empty, the widget won't be visible.
  final String? errorText;

  /// Optional custom text style. If not provided, defaults to the theme's error text style.
  final TextStyle? style;

  /// The color for the error message and icon. Defaults to theme's error color.
  final Color? errorColor;

  /// Text alignment for the error message.
  final TextAlign textAlign;

  /// Whether to show the error icon.
  final bool showIcon;

  /// Icon to display next to the error message.
  final IconData icon;

  /// Size of the error icon.
  final double iconSize;

  /// {@template error_message_constructor}
  /// Creates an error message widget.
  ///
  /// [errorText] The error message to display. If null or empty, renders a SizedBox.shrink.
  /// [style] Optional style override for the error text.
  /// [errorColor] Optional color override for the error text and icon.
  /// [textAlign] Text alignment for the error message.
  /// [showIcon] Whether to show an icon before the error message.
  /// [icon] The icon to show before the error message.
  /// [iconSize] The size of the icon.
  /// {@endtemplate}
  const ErrorMessage({
    super.key,
    this.errorText,
    this.style,
    this.errorColor,
    this.textAlign = TextAlign.start,
    this.showIcon = true,
    this.icon = Icons.error_outline,
    this.iconSize = 14.0,
  });

  @override
  Widget build(BuildContext context) {
    if (errorText == null || errorText!.isEmpty) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);

    final effectiveErrorColor = errorColor ?? theme.colorScheme.error;

    final effectiveStyle = style ??
        theme.textTheme.bodySmall?.copyWith(
          color: effectiveErrorColor,
        );

    return Padding(
      padding: const EdgeInsets.only(top: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showIcon) ...[
            Icon(
              icon,
              size: iconSize,
              color: effectiveErrorColor,
            ),
            const SizedBox(width: 4.0),
          ],
          Flexible(
            child: Text(
              errorText!,
              style: effectiveStyle,
              textAlign: textAlign,
            ),
          ),
        ],
      ),
    );
  }
}
