/// A comprehensive typography system for Flutter applications.
///
/// This library provides a consistent text styling implementation that follows
/// Material Design guidelines while ensuring a cohesive typography experience
/// across your entire application.
///
/// {@template typography_system}
/// # Typography System
///
/// A comprehensive text styling system that follows Material Design guidelines
/// while providing consistent typography across your application.
///
/// ## Font Weight Reference
///
/// The following font weights are available through AppTypography:
///
/// | Weight Name  | FontWeight    |
/// |--------------|---------------|
/// | Thin         | FontWeight.w100 |
/// | ExtraLight   | FontWeight.w200 |
/// | Light        | FontWeight.w300 |
/// | Regular      | FontWeight.w400 |
/// | Medium       | FontWeight.w500 |
/// | SemiBold     | FontWeight.w600 |
/// | Bold         | FontWeight.w700 |
/// | ExtraBold    | FontWeight.w800 |
/// | Black        | FontWeight.w900 |
///
/// ## Font Size Scale (Material Design)
///
/// ### Display
/// - `displayLarge`   — 57.0px
/// - `displayMedium`  — 45.0px
/// - `displaySmall`   — 36.0px
///
/// ### Headline
/// - `headlineLarge`  — 32.0px
/// - `headlineMedium` — 28.0px
/// - `headlineSmall`  — 24.0px
///
/// ### Title
/// - `titleLarge`     — 22.0px
/// - `titleMedium`    — 16.0px
/// - `titleSmall`     — 14.0px
///
/// ### Body
/// - `bodyLarge`      — 16.0px
/// - `bodyMedium`     — 14.0px
/// - `bodySmall`      — 12.0px
///
/// ### Label
/// - `labelLarge`     — 14.0px
/// - `labelMedium`    — 12.0px
/// - `labelSmall`     — 11.0px
/// {@endtemplate}
library;

import 'package:flutter/material.dart';
import 'package:boilerplate/constants/typography.dart';

/// {@macro typography_system}

/// {@template text_variant}
/// ## TextVariant
///
/// A collection of named text style variants that map directly to Material Design's
/// typography scale. Each variant has a specific purpose in the UI hierarchy.
///
/// Use these variants to maintain consistent typography across your app.
///
/// ```dart
/// // Example
/// AppText(
///   'Welcome to Our App',
///   variant: TextVariant.headlineLarge,
/// );
/// ```
/// {@endtemplate}
enum TextVariant {
  /// Largest display text, ideal for full-screen hero banners.
  ///
  /// **Specifications:**
  /// - Font size: 57.0
  /// - Font weight: Regular (w400)
  /// - Usage: Page titles, splash screens, or very large heroes
  displayLarge,

  /// Slightly smaller display text for section headers.
  ///
  /// **Specifications:**
  /// - Font size: 45.0
  /// - Font weight: Regular (w400)
  /// - Usage: Major section headers or feature introductions
  displayMedium,

  /// Compact display text for prominent labels or CTAs.
  ///
  /// **Specifications:**
  /// - Font size: 36.0
  /// - Font weight: Regular (w400)
  /// - Usage: Featured content titles or large call-to-actions
  displaySmall,

  /// Primary heading size for pages or modals.
  ///
  /// **Specifications:**
  /// - Font size: 32.0
  /// - Font weight: Bold (w700)
  /// - Usage: Main page headers or large modal titles
  headlineLarge,

  /// Sub-section title or dialog headings.
  ///
  /// **Specifications:**
  /// - Font size: 28.0
  /// - Font weight: Bold (w700)
  /// - Usage: Section headers within a page or large dialog titles
  headlineMedium,

  /// Smaller headline under a larger heading.
  ///
  /// **Specifications:**
  /// - Font size: 24.0
  /// - Font weight: Bold (w700)
  /// - Usage: Subheadings or tertiary titles
  headlineSmall,

  /// Card titles or form headings.
  ///
  /// **Specifications:**
  /// - Font size: 22.0
  /// - Font weight: SemiBold (w600)
  /// - Usage: Card headers, form section titles, or small dialog titles
  titleLarge,

  /// List item titles or panel headers.
  ///
  /// **Specifications:**
  /// - Font size: 16.0
  /// - Font weight: SemiBold (w600)
  /// - Usage: List titles, menu items, or prominent interactive elements
  titleMedium,

  /// Button or tab labels.
  ///
  /// **Specifications:**
  /// - Font size: 14.0
  /// - Font weight: Medium (w500)
  /// - Usage: Button text, tab labels, or small interactive elements
  titleSmall,

  /// Emphasized paragraphs or featured quotes.
  ///
  /// **Specifications:**
  /// - Font size: 16.0
  /// - Font weight: Regular (w400)
  /// - Usage: Primary content text, emphasized paragraphs, or pull quotes
  bodyLarge,

  /// Standard paragraphs and long-form text.
  ///
  /// **Specifications:**
  /// - Font size: 14.0
  /// - Font weight: Regular (w400)
  /// - Usage: Main body text, descriptions, or general content
  bodyMedium,

  /// Captions, footnotes, or secondary info.
  ///
  /// **Specifications:**
  /// - Font size: 12.0
  /// - Font weight: Regular (w400)
  /// - Usage: Captions, helper text, or supplementary information
  bodySmall,

  /// Input labels or inline descriptors.
  ///
  /// **Specifications:**
  /// - Font size: 14.0
  /// - Font weight: Medium (w500)
  /// - Usage: Form field labels, inline notifications, or metadata
  labelLarge,

  /// Badges or small interface annotations.
  ///
  /// **Specifications:**
  /// - Font size: 12.0
  /// - Font weight: Medium (w500)
  /// - Usage: Status indicators, badges, or small UI annotations
  labelMedium,

  /// Timestamps or metadata annotations.
  ///
  /// **Specifications:**
  /// - Font size: 11.0
  /// - Font weight: Medium (w500)
  /// - Usage: Timestamps, version numbers, or subtle metadata
  labelSmall,
}

/// {@template app_text_widget}
/// # AppText Widget
///
/// A customizable and theme-aware text widget for Flutter applications that
/// streamlines typography implementation according to design system guidelines.
///
/// ## Features
///
/// - Predefined style variants based on Material Design 3 typography scale
/// - Support for custom font families (poppins, roboto, helvetica)
/// - Automatic theme-awareness for colors and text styles
/// - Comprehensive customization options for individual text properties
///
/// ## Usage Examples
///
/// ### Basic Usage
/// ```dart
/// AppText('Hello World')  // Uses default bodyMedium style
/// ```
///
/// ### Using Text Variants
/// ```dart
/// AppText(
///   'Welcome to Our App',
///   variant: TextVariant.headlineLarge,
/// )
/// ```
///
/// ### Custom Styling
/// ```dart
/// AppText(
///   'Important Message',
///   variant: TextVariant.titleMedium,
///   color: Colors.red,
///   fontWeight: FontWeight.bold,
/// )
/// ```
///
/// ### Advanced Configuration
/// ```dart
/// AppText(
///   'Lorem ipsum dolor sit amet...',
///   variant: TextVariant.bodyLarge,
///   maxLines: 2,
///   overflow: TextOverflow.ellipsis,
///   style: TextStyle(
///     decoration: TextDecoration.underline,
///     decorationColor: Colors.blue,
///   ),
/// )
/// ```
/// {@endtemplate}
class AppText extends StatelessWidget {
  /// The string content to display in the text widget.
  ///
  /// This is the only required parameter for creating an AppText widget.
  /// It accepts any String value, including empty strings.
  final String text;

  /// {@template text_variant_doc}
  /// Selects a predefined text style from [TextVariant] enum.
  ///
  /// The [TextVariant] corresponds to Material Design's typography scale.
  /// Each variant has specific font size and weight characteristics:
  ///
  /// - Display variants: Large, eye-catching text (57.0 - 36.0px)
  /// - Headline variants: Page and section headers (32.0 - 24.0px)
  /// - Title variants: Component headers and labels (22.0 - 14.0px)
  /// - Body variants: Content text in various sizes (16.0 - 12.0px)
  /// - Label variants: UI annotations and metadata (14.0 - 11.0px)
  ///
  /// Defaults to [TextVariant.bodyMedium] if not specified.
  /// {@endtemplate}
  final TextVariant variant;

  /// Optionally override or merge additional text styling.
  ///
  /// This [TextStyle] is merged with the style determined by [variant].
  /// Properties specified in this style will override those from the variant.
  ///
  /// Example:
  /// ```dart
  /// AppText(
  ///   'Custom Style',
  ///   variant: TextVariant.bodyMedium,
  ///   style: TextStyle(
  ///     shadows: [Shadow(color: Colors.grey, blurRadius: 2)],
  ///     decoration: TextDecoration.underline,
  ///   ),
  /// )
  /// ```
  final TextStyle? style;

  /// Align the text within its bounds.
  ///
  /// Controls horizontal alignment of text:
  /// - TextAlign.left: Align text to the left edge
  /// - TextAlign.center: Center text horizontally
  /// - TextAlign.right: Align text to the right edge
  /// - TextAlign.justify: Stretch lines to fill width
  ///
  /// If null, defaults to the direction-sensitive start alignment.
  final TextAlign? textAlign;

  /// How visual overflow should be handled.
  ///
  /// Determines what happens when text exceeds available space:
  /// - TextOverflow.clip: Simply cuts off text at the boundary
  /// - TextOverflow.ellipsis: Shows "..." at the end of truncated text
  /// - TextOverflow.fade: Fades out the text at the boundary
  /// - TextOverflow.visible: Allows text to overflow visibly
  final TextOverflow? overflow;

  /// Maximum number of lines for the text.
  ///
  /// If text exceeds this number of lines, it will be handled according to
  /// the [overflow] property.
  ///
  /// Common values:
  /// - 1: Single line text (often used with ellipsis overflow)
  /// - 2-3: Preview text with limited height
  /// - null: Unlimited lines (text wraps based on available width)
  final int? maxLines;

  /// Optionally override the text color.
  ///
  /// Takes precedence over color defined in [variant] or [style].
  /// Colors should match your app's design system.
  ///
  /// For theme-aware coloring, consider using Theme.of(context) colors:
  /// ```dart
  /// AppText(
  ///   'Themed Text',
  ///   color: Theme.of(context).colorScheme.primary,
  /// )
  /// ```
  final Color? color;

  /// The line height multiplier.
  ///
  /// Adjusts the vertical space allocated for each line of text:
  /// - Values > 1.0: Increase line spacing (more readable long text)
  /// - Value = 1.0: Normal line spacing
  /// - Values < 1.0: Decrease line spacing (more compact text)
  ///
  /// Standard values often range between 1.2 and 1.5 for body text.
  final double? height;

  /// Optionally override the font weight.
  ///
  /// Controls text boldness level using predefined constants:
  /// - FontWeight.w100: Thin
  /// - FontWeight.w200: Extra Light
  /// - FontWeight.w300: Light
  /// - FontWeight.w400: Regular (normal)
  /// - FontWeight.w500: Medium
  /// - FontWeight.w600: Semi Bold
  /// - FontWeight.w700: Bold
  /// - FontWeight.w800: Extra Bold
  /// - FontWeight.w900: Black (heaviest)
  final FontWeight? fontWeight;

  /// Optionally override the font style (normal/italic).
  ///
  /// Use [FontStyle.italic] for italicized text, and [FontStyle.normal]
  /// for regular text (which is the default).
  final FontStyle? fontStyle;

  /// Adjust letter spacing.
  ///
  /// Controls horizontal spacing between characters in the text:
  /// - Positive values: Increase spacing (more spacious text)
  /// - Zero: Normal letter spacing
  /// - Negative values: Decrease spacing (more condensed text)
  ///
  /// Measured in logical pixels.
  final double? letterSpacing;

  /// Add underline, strikethrough, or other text decorations.
  ///
  /// Common values include:
  /// - TextDecoration.underline: Adds a line below the text
  /// - TextDecoration.lineThrough: Adds a strikethrough line
  /// - TextDecoration.overline: Adds a line above the text
  /// - TextDecoration.none: No decoration (default)
  final TextDecoration? decoration;

  /// Optionally select font family: "poppins", "roboto", "helvetica".
  ///
  /// Specifies which font to use for this text. Must match a font that has
  /// been included in your pubspec.yaml file and the app's font configuration.
  ///
  /// If null or not matched, uses the theme default font.
  final String? fontFamily;

  /// Optionally provide a key for the underlying [Text] widget.
  ///
  /// Useful for:
  /// - Testing: Finding the widget in test scripts
  /// - Navigation: Used with focus management
  /// - Animation: Preserving widget state during animations
  /// - State preservation: Maintaining state across rebuilds
  final Key? textKey;

  /// Creates a customizable and theme-aware text widget.
  ///
  /// {@macro app_text_widget}
  ///
  /// {@macro typography_system}
  ///
  /// {@macro text_variant}
  const AppText(
    this.text, {
    super.key,
    this.variant = TextVariant.bodyMedium,
    this.style,
    this.textAlign,
    this.overflow,
    this.maxLines,
    this.color,
    this.height,
    this.fontWeight,
    this.fontStyle,
    this.letterSpacing,
    this.decoration,
    this.fontFamily,
    this.textKey,
  });

  /// Returns the appropriate [TextTheme] based on [fontFamily].
  ///
  /// This method selects the correct typography theme based on the specified
  /// font family, falling back to the app's default theme if none is specified.
  ///
  /// Available font families:
  /// - 'poppins': A geometric sans-serif with rounded terminals
  /// - 'roboto': Android's system font with natural reading rhythm
  /// - 'helvetica': Classic sans-serif with neutral appearance
  TextTheme _getTypography(BuildContext context) {
    switch (fontFamily?.toLowerCase()) {
      case 'poppins':
        return AppTypography.poppins;
      case 'roboto':
        return AppTypography.roboto;
      case 'helvetica':
        return AppTypography.helvetica;
      default:
        return Theme.of(context).textTheme;
    }
  }

  /// Returns the default [TextStyle] for the selected [variant].
  ///
  /// This internal method maps each [TextVariant] enum value to its
  /// corresponding style in the Material [TextTheme].
  TextStyle? _getDefaultStyle(BuildContext context) {
    final TextTheme t = _getTypography(context);
    switch (variant) {
      case TextVariant.displayLarge:
        return t.displayLarge;
      case TextVariant.displayMedium:
        return t.displayMedium;
      case TextVariant.displaySmall:
        return t.displaySmall;
      case TextVariant.headlineLarge:
        return t.headlineLarge;
      case TextVariant.headlineMedium:
        return t.headlineMedium;
      case TextVariant.headlineSmall:
        return t.headlineSmall;
      case TextVariant.titleLarge:
        return t.titleLarge;
      case TextVariant.titleMedium:
        return t.titleMedium;
      case TextVariant.titleSmall:
        return t.titleSmall;
      case TextVariant.bodyLarge:
        return t.bodyLarge;
      case TextVariant.bodyMedium:
        return t.bodyMedium;
      case TextVariant.bodySmall:
        return t.bodySmall;
      case TextVariant.labelLarge:
        return t.labelLarge;
      case TextVariant.labelMedium:
        return t.labelMedium;
      case TextVariant.labelSmall:
        return t.labelSmall;
    }
  }

  @override
  Widget build(BuildContext context) {
    final defaultStyle = _getDefaultStyle(context);

    TextStyle combined = defaultStyle!.copyWith(
      color: color,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      height: height,
      decoration: decoration,
    );

    final effectiveStyle = style != null ? combined.merge(style) : combined;

    return Text(
      text,
      key: textKey,
      style: effectiveStyle,
      textAlign: textAlign,
      overflow: overflow,
      maxLines: maxLines,
    );
  }
}
