/// {@template chip_library}
/// # Chip Widgets for Flutter
///
/// A flexible, accessible, and composable set of chip components for Flutter applications.
///
/// This library provides:
/// - A minimalistic [ChipButton] for unstyled, compact, zero-padding chips
/// - A highly flexible [Chip] widget that supports custom content, builder pattern, label/leading/trailing slots, and full Button API integration
///
/// ## Features
/// - Consistent API with your Button and design system
/// - Supports label, icon/avatar, close/delete actions, and full custom content
/// - Precise layout with compact density and customizable padding/radius
/// - Fully accessible with button semantics
/// - Optional trailing action (e.g., close/delete) with separate handler
///
/// ## Basic Usage
/// ```dart
/// // Simple chip with label
/// Chip(label: "Active", onPressed: () { ... });
///
/// // Chip with icon and trailing delete
/// Chip(
///   label: "Tag",
///   leading: Icon(Icons.tag),
///   trailing: Icon(Icons.close),
///   onPressedTrailing: () { ... },
/// );
///
/// // Custom chip with full control
/// Chip(
///   builder: (context) => Row(
///     children: [Icon(Icons.person), Text("User")],
///   ),
/// );
///
/// // Minimal chip button (unstyled)
/// ChipButton(child: Text("Minimal"), onPressed: () { ... });
/// ```
/// {@endtemplate}
library;

/// {@template chip_button}
/// # ChipButton
///
/// A minimalistic button styled as a chip:
/// - Uses [ButtonVariant.unstyled]
/// - Compact size, zero padding, no border radius, no elevation
///
/// Useful for "raw" chips, unstyled tags, or as a building block for complex chip UIs.
///
/// ## Usage
/// ```dart
/// ChipButton(child: Text("Raw Chip"), onPressed: () { ... });
/// ```
/// {@endtemplate}
import 'package:flutter/material.dart';
import 'package:boilerplate/core/widgets/components/buttons/button.dart';

class ChipButton extends StatelessWidget {
  /// The widget displayed inside the chip.
  final Widget child;

  /// Called when the chip is tapped.
  final VoidCallback? onPressed;

  /// {@macro chip_button}
  const ChipButton({
    super.key,
    required this.child,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Button(
      variant: ButtonVariant.unstyled,
      size: ButtonSize.small,
      density: ButtonDensity.compact,
      shape: ButtonShape.rectangle,
      layout: const ButtonLayout(
        padding: EdgeInsets.zero,
        contentPadding: EdgeInsets.zero,
        borderRadius: BorderRadius.zero,
      ),
      effects: const ButtonEffects(
        elevation: 0,
        hoverElevation: 0,
        pressedElevation: 0,
      ),
      onPressed: onPressed,
      child: child,
    );
  }
}

/// {@template chip}
/// # Chip
///
/// A highly flexible, accessible chip widget supporting label, icons, custom content,
/// builder pattern, and full integration with your Button design system.
///
/// - If [child] is provided, it replaces all other content.
/// - If [builder] is provided, it takes precedence over [label], [leading], and [trailing].
/// - [onPressed] is called when the chip is tapped.
/// - [onPressedTrailing] is called when the trailing widget is tapped (if provided).
/// - Fully customizable via [variant] and Button API options.
///
/// ## Features
/// - **Label**: Simple string label
/// - **Leading**: Optional leading widget (icon, avatar)
/// - **Trailing**: Optional trailing widget (icon, close/delete), with independent tap handling
/// - **Builder**: Full custom content layout
/// - **Child**: Complete content override
/// - **Button Integration**: All Button variants, shapes, densities, and typography supported
///
/// ## Usage Examples
/// ```dart
/// // Basic chip
/// Chip(label: "Active", onPressed: () {});
///
/// // Chip with icon and close button
/// Chip(
///   label: "Filter",
///   leading: Icon(Icons.filter_alt),
///   trailing: Icon(Icons.close),
///   onPressedTrailing: () { ... },
/// );
///
/// // Custom chip with builder
/// Chip(
///   builder: (context) => Row(
///     children: [Icon(Icons.star), Text("Favorite")],
///   ),
/// );
///
/// // Totally custom child
/// Chip(child: MyCustomWidget(), onPressed: () {});
/// ```
/// {@endtemplate}
class Chip extends StatelessWidget {
  /// Custom content for the chip. If non-null, overrides [label], [leading], [trailing], [builder].
  final Widget? child;

  /// Builder for complete chip content. Receives context and returns the content widget.
  final Widget Function(BuildContext context)? builder;

  /// Text label for the chip (ignored if [child] or [builder] is provided).
  final String? label;

  /// Leading widget (e.g., icon/avatar) before label.
  final Widget? leading;

  /// Trailing widget (e.g., close/delete icon) after label.
  final Widget? trailing;

  /// Called when the chip is tapped.
  final VoidCallback? onPressed;

  /// Called when the trailing widget is tapped.
  final VoidCallback? onPressedTrailing;

  /// Visual style variant for the chip.
  final ButtonVariant variant;

  /// {@macro chip}
  const Chip({
    super.key,
    this.child,
    this.builder,
    this.label,
    this.leading,
    this.trailing,
    this.onPressed,
    this.onPressedTrailing,
    this.variant = ButtonVariant.secondary,
  }) : assert(child != null || builder != null || label != null,
            'Chip requires either a child, builder, or label');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (child != null) {
      return Button(
        variant: variant,
        size: ButtonSize.small,
        density: ButtonDensity.compact,
        shape: ButtonShape.customRounded,
        layout: const ButtonLayout(
          borderRadius: BorderRadius.all(Radius.circular(16)),
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        ),
        onPressed: onPressed,
        child: child,
      );
    }

    if (builder != null) {
      return Button(
        variant: variant,
        size: ButtonSize.small,
        density: ButtonDensity.compact,
        shape: ButtonShape.customRounded,
        layout: const ButtonLayout(
          borderRadius: BorderRadius.all(Radius.circular(16)),
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        ),
        onPressed: onPressed,
        child: builder!(context),
      );
    }

    return Button(
      variant: variant,
      size: ButtonSize.small,
      density: ButtonDensity.compact,
      shape: ButtonShape.roundedRectangle,
      layout: const ButtonLayout(
        borderRadius: BorderRadius.all(Radius.circular(16)),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      ),
      typography: ButtonTypography(
        style: theme.textTheme.labelSmall,
      ),
      onPressed: onPressed,
      child: _ChipContent(
        label: label!,
        leading: leading,
        trailing: trailing,
        onPressedTrailing: onPressedTrailing,
      ),
    );
  }
}

/// {@template chip_content}
/// # _ChipContent (internal)
///
/// Internal widget for rendering chip content using [label], [leading], [trailing], and [onPressedTrailing].
///
/// - Handles layout, spacing, and trailing tap gesture if provided.
/// - Used only by [Chip], not exposed as a public widget.
/// {@endtemplate}
class _ChipContent extends StatelessWidget {
  final String label;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onPressedTrailing;

  /// {@macro chip_content}
  const _ChipContent({
    required this.label,
    this.leading,
    this.trailing,
    this.onPressedTrailing,
  });

  @override
  Widget build(BuildContext context) {
    final hasTrailingAction = trailing != null && onPressedTrailing != null;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (leading != null) ...[
          leading!,
          const SizedBox(width: 6),
        ],
        Flexible(
          child: Text(
            label,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: Theme.of(context).textTheme.labelSmall,
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: 6),
          hasTrailingAction
              ? GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: onPressedTrailing,
                  child: trailing,
                )
              : trailing!,
        ],
      ],
    );
  }
}
