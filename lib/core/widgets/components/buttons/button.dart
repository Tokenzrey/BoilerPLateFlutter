/// A comprehensive button system for Flutter applications.
///
/// This library provides a highly customizable button implementation that follows
/// Material Design guidelines while allowing extensive customization options
/// for building consistent UI components across your application.
///
/// {@template button_system}
/// # Button System
///
/// A comprehensive button styling system that provides extensive customization options
/// while maintaining strong defaults aligned with Material Design principles.
///
/// ## Button Variants
///
/// | Variant    | Description                               | Common Use Cases                        |
/// |------------|-------------------------------------------|----------------------------------------|
/// | primary    | Main brand color, high emphasis           | Primary actions, form submissions       |
/// | secondary  | Secondary brand color                     | Alternative actions, filters           |
/// | warning    | Amber/yellow, cautionary                  | Actions requiring attention            |
/// | neutral    | Neutral color, medium emphasis            | Secondary actions, cancellation        |
/// | danger     | Red/error color, destructive              | Delete, remove, destructive actions    |
/// | unstyled   | No background styling                     | Custom styled buttons                  |
/// | light      | Light background                          | Light mode alternative actions         |
/// | ghost      | No background, only hover effect          | Subtle actions, menu items             |
/// | outlined   | No background, with border                | Secondary options, toggles             |
/// | text       | Text only button                          | Links, subtle actions                  |
///
/// ## Button Sizes
///
/// | Size       | Text Variant      | Common Use Cases                     |
/// |------------|-------------------|-------------------------------------|
/// | extraSmall | labelSmall        | Dense UIs, compact spaces           |
/// | small      | labelMedium       | Form controls, toolbars             |
/// | normal     | labelLarge        | Standard actions                    |
/// | large      | titleSmall        | Featured actions                    |
/// | extraLarge | titleMedium       | Hero sections, CTAs                 |
///
/// ## Button Densities
///
/// | Density        | Description                              | Common Use Cases                     |
/// |----------------|------------------------------------------|-------------------------------------|
/// | compact        | 75% of normal padding                    | Dense UIs, tables, lists            |
/// | dense          | 85% of normal padding                    | Space-constrained layouts           |
/// | normal         | Standard padding                         | Most UI contexts                    |
/// | comfortable    | 125% of normal padding                   | Touch-friendly UIs                  |
/// | icon           | Equal padding (ideal for square buttons) | Icon-only buttons                   |
/// | iconComfortable| Larger equal padding                     | Featured icon buttons               |
///
/// ## Button Shapes
///
/// | Shape             | Description                        | Common Use Cases                     |
/// |-------------------|------------------------------------|------------------------------------- |
/// | fullRounded       | Pill-shaped (fully rounded sides)  | CTAs, floating action buttons        |
/// | rectangle         | No rounded corners                 | Toolbars, grids                     |
/// | roundedRectangle  | Standard rounded corners           | Most buttons                        |
/// | customRounded     | Custom border radius               | Special UI requirements              |
/// {@endtemplate}
library;

import 'package:boilerplate/core/widgets/components/typography.dart';
import 'package:flutter/material.dart';

/// {@template button_variant}
/// Defines the visual style of the button.
///
/// Each variant has distinct visual properties and semantic meaning in the UI:
///
/// - `primary`: High-emphasis button using primary brand color
/// - `secondary`: Medium-emphasis button using secondary brand color
/// - `warning`: Indicates caution or requires attention (typically amber/yellow)
/// - `neutral`: Standard emphasis button with neutral color
/// - `danger`: Indicates destructive or irreversible actions (typically red)
/// - `unstyled`: No default styling for complete customization
/// - `light`: Light background suitable for light themes
/// - `ghost`: Transparent background with hover effect
/// - `outlined`: Transparent with border for medium emphasis
/// - `text`: Text-only button for subtle actions
///
/// Example usage:
/// ```dart
/// Button(
///   text: 'Save',
///   variant: ButtonVariant.primary,
///   onPressed: () => saveDocument(),
/// )
/// ```
/// {@endtemplate}
enum ButtonVariant {
  /// High-emphasis button with the app's primary color.
  ///
  /// **Specifications:**
  /// - Background: Primary color
  /// - Text: OnPrimary color
  /// - Usage: Primary actions, main CTA, form submission
  primary,

  /// Medium-emphasis button with the app's secondary color.
  ///
  /// **Specifications:**
  /// - Background: Secondary color
  /// - Text: OnSecondary color
  /// - Usage: Alternative actions, secondary functions
  secondary,

  /// Button that indicates an action requiring attention.
  ///
  /// **Specifications:**
  /// - Background: Amber/yellow
  /// - Text: Dark (typically black)
  /// - Usage: Actions requiring caution or attention
  warning,

  /// Standard emphasis button with neutral coloring.
  ///
  /// **Specifications:**
  /// - Background: Surface color
  /// - Text: OnSurface color
  /// - Usage: Balanced emphasis actions, alternatives
  neutral,

  /// Button that indicates destructive or irreversible actions.
  ///
  /// **Specifications:**
  /// - Background: Error color
  /// - Text: OnError color
  /// - Usage: Delete, remove, or other destructive actions
  danger,

  /// Button with no default styling for complete customization.
  ///
  /// **Specifications:**
  /// - Background: Transparent
  /// - Text: OnSurface color
  /// - Usage: Custom styling needs
  unstyled,

  /// Button with light background color.
  ///
  /// **Specifications:**
  /// - Background: SurfaceContainerHighest
  /// - Text: OnSurfaceVariant color
  /// - Usage: Light mode UI alternatives
  light,

  /// Transparent button that reveals styling on interaction.
  ///
  /// **Specifications:**
  /// - Background: Transparent
  /// - Text: Primary color
  /// - Usage: Subtle actions, menu items, toggles
  ghost,

  /// Transparent button with a visible border.
  ///
  /// **Specifications:**
  /// - Background: Transparent
  /// - Border: Primary color
  /// - Text: Primary color
  /// - Usage: Secondary options, toggleable buttons
  outlined,

  /// Text-only button with minimal visual presence.
  ///
  /// **Specifications:**
  /// - Background: Transparent
  /// - Text: Primary color
  /// - Usage: Links, subtle actions, low-emphasis options
  text,
}

/// {@template button_size}
/// Controls the overall size dimensions of the button.
///
/// Button size affects padding, text size, and overall proportions:
///
/// - `extraSmall`: Minimal size for constrained spaces
/// - `small`: Compact size for tight layouts
/// - `normal`: Standard size for most use cases
/// - `large`: Prominent size for featured actions
/// - `extraLarge`: Maximum size for hero sections or CTAs
///
/// Each size is paired with an appropriate text variant to maintain
/// proportional typography.
///
/// Example usage:
/// ```dart
/// Button(
///   text: 'Menu',
///   size: ButtonSize.small,
///   onPressed: () => openMenu(),
/// )
/// ```
/// {@endtemplate}
enum ButtonSize {
  /// Smallest button size for very compact layouts.
  ///
  /// **Specifications:**
  /// - Horizontal padding: 10.0 (adjusted by density)
  /// - Vertical padding: 4.0 (adjusted by density)
  /// - Text variant: labelSmall
  /// - Usage: Dense UIs, toolbars, chips
  extraSmall,

  /// Compact button size for space-constrained interfaces.
  ///
  /// **Specifications:**
  /// - Horizontal padding: 12.0 (adjusted by density)
  /// - Vertical padding: 6.0 (adjusted by density)
  /// - Text variant: labelMedium
  /// - Usage: Form controls, filter buttons
  small,

  /// Standard button size for most use cases.
  ///
  /// **Specifications:**
  /// - Horizontal padding: 16.0 (adjusted by density)
  /// - Vertical padding: 8.0 (adjusted by density)
  /// - Text variant: labelLarge
  /// - Usage: Most UI button contexts
  normal,

  /// Larger button size for featured actions.
  ///
  /// **Specifications:**
  /// - Horizontal padding: 20.0 (adjusted by density)
  /// - Vertical padding: 10.0 (adjusted by density)
  /// - Text variant: titleSmall
  /// - Usage: Primary actions, important CTAs
  large,

  /// Largest button size for hero sections.
  ///
  /// **Specifications:**
  /// - Horizontal padding: 24.0 (adjusted by density)
  /// - Vertical padding: 12.0 (adjusted by density)
  /// - Text variant: titleMedium
  /// - Usage: Hero CTAs, landing page actions
  extraLarge
}

/// {@template button_density}
/// Controls the spacing density within the button.
///
/// Button density affects padding while maintaining the same overall
/// proportions of the selected size:
///
/// - `compact`: 75% of normal padding (space-saving)
/// - `dense`: 85% of normal padding (slightly reduced spacing)
/// - `normal`: Standard padding
/// - `comfortable`: 125% of normal padding (touch-friendly)
/// - `icon`: Equal padding (ideal for square buttons)
/// - `iconComfortable`: Larger equal padding (for featured icons)
///
/// Example usage:
/// ```dart
/// Button(
///   leftIcon: Icons.add,
///   text: 'Add Item',
///   density: ButtonDensity.comfortable,
///   onPressed: () => addItem(),
/// )
/// ```
/// {@endtemplate}
enum ButtonDensity {
  /// Very tight spacing for space-constrained UIs.
  ///
  /// **Specifications:**
  /// - Multiplies standard padding by 0.75
  /// - Usage: Dense UIs, tables, data grids
  compact,

  /// Slightly reduced spacing for moderately constrained layouts.
  ///
  /// **Specifications:**
  /// - Multiplies standard padding by 0.85
  /// - Usage: Toolbars, form controls in compact layouts
  dense,

  /// Standard spacing suitable for most contexts.
  ///
  /// **Specifications:**
  /// - Standard padding (1.0 multiplier)
  /// - Usage: Default for most buttons
  normal,

  /// Expanded spacing for more touch-friendly buttons.
  ///
  /// **Specifications:**
  /// - Multiplies standard padding by 1.25
  /// - Usage: Mobile-first UIs, touch targets
  comfortable,

  /// Equal padding on all sides, ideal for icon-only buttons.
  ///
  /// **Specifications:**
  /// - Uses vertical padding value for all sides
  /// - Usage: Icon buttons, square action buttons
  icon,

  /// Larger equal padding on all sides for featured icon buttons.
  ///
  /// **Specifications:**
  /// - Uses 1.5× vertical padding for icon-only buttons
  /// - Uses 0.75× horizontal padding for buttons with text
  /// - Usage: Featured icon buttons, FABs
  iconComfortable
}

/// {@template button_shape}
/// Defines the border shape of the button.
///
/// - `fullRounded`: Pill-shaped with fully rounded ends
/// - `rectangle`: Sharp corners with no rounding
/// - `roundedRectangle`: Standard rounded corners (default)
/// - `customRounded`: Custom border radius via layout property
///
/// Example usage:
/// ```dart
/// Button(
///   text: 'Send',
///   shape: ButtonShape.fullRounded,
///   onPressed: sendMessage,
/// )
/// ```
/// {@endtemplate}
enum ButtonShape {
  /// Pill-shaped button with fully rounded ends.
  ///
  /// **Specifications:**
  /// - BorderRadius: circular(100)
  /// - Usage: CTAs, floating action buttons, featured actions
  fullRounded,

  /// Button with sharp corners and no rounding.
  ///
  /// **Specifications:**
  /// - BorderRadius: zero
  /// - Usage: Toolbars, grids, technical interfaces
  rectangle,

  /// Standard button with slightly rounded corners.
  ///
  /// **Specifications:**
  /// - BorderRadius: circular(8.0)
  /// - Usage: Most buttons (default)
  roundedRectangle,

  /// Button with custom corner rounding.
  ///
  /// **Specifications:**
  /// - BorderRadius: Defined by layout.borderRadius
  /// - Usage: Special UI requirements
  customRounded
}

/// {@template text_transform}
/// Controls the automatic text case transformation.
///
/// - `none`: No transformation (preserves original casing)
/// - `uppercase`: Converts all characters to uppercase
/// - `lowercase`: Converts all characters to lowercase
/// - `capitalize`: Capitalizes first letter of each word
///
/// Example usage:
/// ```dart
/// Button(
///   text: 'submit form',
///   typography: ButtonTypography(transform: TextTransform.uppercase),
///   onPressed: submitForm,
/// )
/// // Displays as "SUBMIT FORM"
/// ```
/// {@endtemplate}
enum TextTransform {
  /// No text transformation (maintains original casing).
  none,

  /// Converts all text to UPPERCASE.
  uppercase,

  /// Converts all text to lowercase.
  lowercase,

  /// Capitalizes The First Letter Of Each Word.
  capitalize
}

/// {@template button_colors}
/// # ButtonColors
///
/// Comprehensive color configuration for custom buttons in Flutter.
///
/// This class allows you to deeply customize every aspect of button coloring, including:
///
/// - **Background colors**: Set solid colors or gradients for various states.
/// - **Text and icon colors**: Control foreground appearance for both enabled and disabled states.
/// - **Border colors**: Specify border color in normal and disabled states (for outlined/ghost variants).
/// - **State-specific colors**: Easily change appearance on hover, pressed, focus, and disabled states.
/// - **Ripple/splash effect color**: Customize the Material ripple animation color.
/// - **Gradient support**: Use linear or radial gradients for button backgrounds.
/// - **Advanced overlay color**: Fine-tune overlay/ink highlight using [WidgetStateProperty].
///
/// ## Example Usage
/// ```dart
/// Button(
///   text: 'Custom',
///   colors: ButtonColors(
///     background: Colors.purple,        // Solid background
///     text: Colors.white,               // Label color
///     hover: Colors.deepPurpleAccent,   // Background on hover
///     pressed: Colors.purple[700],      // Background when pressed
///     disabled: Colors.grey[300],       // Disabled background
///     icon: Colors.white,               // Icon color (if any)
///     border: Colors.purple[900],       // Border color (outlined/ghost)
///     gradient: LinearGradient(         // Gradient background
///       colors: [Colors.purple, Colors.pink],
///     ),
///     splash: Colors.purpleAccent.withOpacity(0.2), // Ripple color
///   ),
///   onPressed: customAction,
/// )
/// ```
///
/// ## Tips
/// - When a property is `null`, the button will use defaults from the app's theme or the selected [ButtonVariant].
/// - Use the `gradient` property to create modern, vibrant buttons.
/// - Use `overlayColor` for advanced, per-state overlay customization (rarely needed unless you want precise ripple/hover effects).
///
/// {@endtemplate}
class ButtonColors {
  /// The **background color** of the button in its normal state.
  ///
  /// *Type*: `Color?`
  ///
  /// - Accepts any [Color], e.g. `Colors.blue`, `Color(0xFF0000FF)`.
  /// - If `null`, falls back to the theme or [ButtonVariant] default.
  /// - Ignored if [gradient] is provided (gradient takes precedence).
  ///
  /// *Example*: `background: Colors.green`
  final Color? background;

  /// The **text color** for the button label in its enabled state.
  ///
  /// *Type*: `Color?`
  ///
  /// - Accepts any [Color], e.g. `Colors.white`, `Theme.of(context).colorScheme.onPrimary`.
  /// - Applies to text only, not icons (see [icon] for icon color).
  /// - If `null`, the color is derived from the theme or variant.
  ///
  /// *Example*: `text: Colors.black`
  final Color? text;

  /// The **border color** of the button.
  ///
  /// *Type*: `Color?`
  ///
  /// - Used for outlined or ghost-style buttons.
  /// - Accepts any [Color].
  /// - If `null`, uses a sensible default (typically the variant's main color).
  ///
  /// *Example*: `border: Colors.amber`
  final Color? border;

  /// The **icon color** for icons placed inside the button.
  ///
  /// *Type*: `Color?`
  ///
  /// - Accepts any [Color].
  /// - Only affects [Icon] widgets, not text.
  /// - If `null`, the icon color defaults to [text] or theme.
  ///
  /// *Example*: `icon: Colors.white`
  final Color? icon;

  /// The **background color** when the button is being hovered by a pointer (mouse/web).
  ///
  /// *Type*: `Color?`
  ///
  /// - Accepts any [Color].
  /// - If `null`, a slightly lighter/darker version of [background] is used.
  ///
  /// *Example*: `hover: Colors.blueAccent`
  final Color? hover;

  /// The **background color** when the button is pressed (tapped/clicked).
  ///
  /// *Type*: `Color?`
  ///
  /// - Accepts any [Color].
  /// - If `null`, a slightly darker version of [background] is used.
  ///
  /// *Example*: `pressed: Colors.blue[900]`
  final Color? pressed;

  /// The **background color** when the button is focused (via keyboard navigation or accessibility).
  ///
  /// *Type*: `Color?`
  ///
  /// - Accepts any [Color].
  /// - If `null`, falls back to [background].
  ///
  /// *Example*: `focus: Colors.blueGrey`
  final Color? focus;

  /// The **background color** of the button when disabled.
  ///
  /// *Type*: `Color?`
  ///
  /// - Accepts any [Color].
  /// - If `null`, uses a muted/greyed-out version of [background].
  ///
  /// *Example*: `disabled: Colors.grey[200]`
  final Color? disabled;

  /// The **text color** for the button label when disabled.
  ///
  /// *Type*: `Color?`
  ///
  /// - Accepts any [Color].
  /// - If `null`, uses a muted/greyed-out version of [text].
  ///
  /// *Example*: `disabledText: Colors.grey`
  final Color? disabledText;

  /// The **border color** when the button is disabled.
  ///
  /// *Type*: `Color?`
  ///
  /// - Used for outlined/ghost buttons.
  /// - If `null`, uses a faded version of [border].
  ///
  /// *Example*: `disabledBorder: Colors.grey[400]`
  final Color? disabledBorder;

  /// The **ripple/splash effect color** (Material ink animation) shown on tap.
  ///
  /// *Type*: `Color?`
  ///
  /// - Accepts any [Color].
  /// - If `null`, uses a semi-transparent version of [background] or theme default.
  ///
  /// *Example*: `splash: Colors.pinkAccent.withOpacity(0.2)`
  final Color? splash;

  /// The **gradient background** for the button.
  ///
  /// *Type*: `Gradient?`
  ///
  /// - Accepts a [LinearGradient], [RadialGradient], etc.
  /// - When set, overrides [background] color.
  ///
  /// *Example*:
  /// ```dart
  /// gradient: LinearGradient(
  ///   colors: [Colors.blue, Colors.purple],
  ///   begin: Alignment.topLeft,
  ///   end: Alignment.bottomRight,
  /// )
  /// ```
  final Gradient? gradient;

  /// Custom **overlay color property** for advanced per-state color handling.
  ///
  /// *Type*: `WidgetStateProperty<Color?>?`
  ///
  /// - Allows you to fine-tune overlay/ripple/hover effect color for each widget state.
  /// - Most use-cases do NOT need this—prefer [hover], [pressed], [splash] for common needs.
  /// - Use only if you need granular control over overlay appearance.
  ///
  /// *Example*:
  /// ```dart
  /// overlayColor: WidgetStateProperty.resolveWith((states) {
  ///   if (states.contains(WidgetState.pressed)) return Colors.red;
  ///   if (states.contains(WidgetState.hovered)) return Colors.amber;
  ///   return null;
  /// }),
  /// ```
  final WidgetStateProperty<Color?>? overlayColor;

  /// Creates a custom color configuration for a button.
  ///
  /// All parameters are optional. Any omitted property will use a default value from the current theme or button variant.
  const ButtonColors({
    this.background,
    this.text,
    this.border,
    this.icon,
    this.hover,
    this.pressed,
    this.focus,
    this.disabled,
    this.disabledText,
    this.disabledBorder,
    this.splash,
    this.gradient,
    this.overlayColor,
  });

  /// Returns a new [ButtonColors] object with the fields replaced by the given values.
  ///
  /// This is useful for overriding a few properties while maintaining others.
  ButtonColors copyWith({
    Color? background,
    Color? text,
    Color? border,
    Color? icon,
    Color? hover,
    Color? pressed,
    Color? focus,
    Color? disabled,
    Color? disabledText,
    Color? disabledBorder,
    Color? splash,
    Gradient? gradient,
    WidgetStateProperty<Color?>? overlayColor,
  }) =>
      ButtonColors(
        background: background ?? this.background,
        text: text ?? this.text,
        border: border ?? this.border,
        icon: icon ?? this.icon,
        hover: hover ?? this.hover,
        pressed: pressed ?? this.pressed,
        focus: focus ?? this.focus,
        disabled: disabled ?? this.disabled,
        disabledText: disabledText ?? this.disabledText,
        disabledBorder: disabledBorder ?? this.disabledBorder,
        splash: splash ?? this.splash,
        gradient: gradient ?? this.gradient,
        overlayColor: overlayColor ?? this.overlayColor,
      );
}

/// {@template button_typography}
/// # ButtonTypography
///
/// Comprehensive typography configuration for button text in Flutter.
///
/// This class allows you to control every aspect of button label styling, including:
///
/// - **Text variant**: Connects directly to your app's typography system ([TextVariant]).
/// - **Font configuration**: Choose font family, weight, style, and size.
/// - **Text alignment and transformation**: Align text, enforce uppercase/lowercase/capitalization.
/// - **Advanced styling**: Control color, line height, spacing, decorations, and overflow.
///
/// ## Example Usage
/// ```dart
/// Button(
///   text: 'Sign Up',
///   typography: ButtonTypography(
///     textVariant: TextVariant.titleLarge,      // Use a large title style
///     fontFamily: 'poppins',                    // Custom font family
///     fontWeight: FontWeight.bold,              // Bold text
///     transform: TextTransform.uppercase,       // UPPERCASE text
///     letterSpacing: 1.2,                       // Extra spacing
///     align: TextAlign.center,                  // Centered text
///     maxLines: 1,                              // Single line
///     overflow: TextOverflow.ellipsis,          // Fade/ellipsis if too long
///     color: Colors.white,                      // Override text color
///     height: 1.4,                              // Line height
///     fontStyle: FontStyle.italic,              // Italic
///     decoration: TextDecoration.underline,     // Underline
///   ),
///   onPressed: signUp,
/// )
/// ```
///
/// ## Tips
/// - Any property left `null` will use the button size/variant or app typography defaults.
/// - Use [transform] to enforce consistent case for button labels (recommended for design systems).
/// - Use [style] for quick overrides, but prefer dedicated properties for clarity and theme integration.
///
/// {@endtemplate}
class ButtonTypography {
  /// The **predefined text style variant** from your app's typography system.
  ///
  /// *Type*: `TextVariant?`
  ///
  /// - Use a value from the [TextVariant] enum (e.g. `TextVariant.labelLarge`, `TextVariant.titleMedium`).
  /// - If `null`, the button size/variant will determine the default.
  ///
  /// *Example*: `textVariant: TextVariant.titleLarge`
  final TextVariant? textVariant;

  /// The **font family** for the button label.
  ///
  /// *Type*: `String?`
  ///
  /// - Set to your custom font family (e.g. `'poppins'`, `'roboto'`, `'helvetica'`).
  /// - Must match a font declared in your app's assets and pubspec.yaml.
  /// - If `null`, uses the default font family from the theme or [TextVariant].
  ///
  /// *Example*: `fontFamily: 'poppins'`
  final String? fontFamily;

  /// A **custom [TextStyle]** to merge with the resolved style.
  ///
  /// *Type*: `TextStyle?`
  ///
  /// - Use this for fine-grained control (e.g. adding shadows, underline, etc).
  /// - Properties in [style] take precedence over those from [textVariant], but are overridden by direct ButtonTypography fields if both are set.
  ///
  /// *Example*: `style: TextStyle(decoration: TextDecoration.lineThrough)`
  final TextStyle? style;

  /// **Text alignment** within the button widget.
  ///
  /// *Type*: `TextAlign?`
  ///
  /// - Use [TextAlign.left], [TextAlign.center], [TextAlign.right], [TextAlign.justify], etc.
  /// - If `null`, text is aligned according to button layout or locale direction.
  ///
  /// *Example*: `align: TextAlign.center`
  final TextAlign? align;

  /// The **text transformation/case** to apply.
  ///
  /// *Type*: `TextTransform`
  ///
  /// - Use [TextTransform.none] (default), [TextTransform.uppercase], [TextTransform.lowercase], or [TextTransform.capitalize].
  /// - Enforces a consistent text case for button labels.
  ///
  /// *Example*: `transform: TextTransform.uppercase`
  final TextTransform transform;

  /// The **maximum number of lines** for the button label.
  ///
  /// *Type*: `int?`
  ///
  /// - Limits label to a set number of lines.
  /// - If text exceeds this, [overflow] behavior is used.
  /// - If `null`, text will wrap as needed.
  ///
  /// *Example*: `maxLines: 2`
  final int? maxLines;

  /// How to **handle text overflow** when the label exceeds available space.
  ///
  /// *Type*: `TextOverflow?`
  ///
  /// - Use [TextOverflow.clip], [TextOverflow.ellipsis], [TextOverflow.fade], or [TextOverflow.visible].
  /// - If `null`, defaults to [TextOverflow.ellipsis] (shows "...").
  ///
  /// *Example*: `overflow: TextOverflow.fade`
  final TextOverflow? overflow;

  /// **Text color override** for the button label.
  ///
  /// *Type*: `Color?`
  ///
  /// - Use any [Color] (e.g. `Colors.white`, `Colors.black`).
  /// - If `null`, uses the variant's default or theme color.
  ///
  /// *Example*: `color: Colors.red`
  final Color? color;

  /// **Line height multiplier** for the text.
  ///
  /// *Type*: `double?`
  ///
  /// - Sets the vertical space for each line of text.
  /// - Typical values are `1.2` to `1.5` for readable body text.
  /// - If `null`, uses the default from the typography system or [TextVariant].
  ///
  /// *Example*: `height: 1.3`
  final double? height;

  /// **Font weight override** for the text.
  ///
  /// *Type*: `FontWeight?`
  ///
  /// - Use constants like [FontWeight.w400] (regular), [FontWeight.bold], etc.
  /// - If `null`, uses the weight from the [textVariant] or theme.
  ///
  /// *Example*: `fontWeight: FontWeight.w600`
  final FontWeight? fontWeight;

  /// **Font style** for the text: normal or italic.
  ///
  /// *Type*: `FontStyle?`
  ///
  /// - Use [FontStyle.normal] or [FontStyle.italic].
  /// - If `null`, uses the style from the variant or theme.
  ///
  /// *Example*: `fontStyle: FontStyle.italic`
  final FontStyle? fontStyle;

  /// **Spacing between letters** (tracking).
  ///
  /// *Type*: `double?`
  ///
  /// - Measured in logical pixels.
  /// - Positive values add space, negative values condense.
  /// - If `null`, uses the default from the variant or theme.
  ///
  /// *Example*: `letterSpacing: 1.2`
  final double? letterSpacing;

  /// **Text decoration** such as underline or strikethrough.
  ///
  /// *Type*: `TextDecoration?`
  ///
  /// - Use [TextDecoration.underline], [TextDecoration.lineThrough], [TextDecoration.overline], or [TextDecoration.none].
  /// - If `null`, uses the default (usually none).
  ///
  /// *Example*: `decoration: TextDecoration.underline`
  final TextDecoration? decoration;

  /// Creates a comprehensive typography configuration for button text.
  ///
  /// Any parameter left null will use button size/variant or app typography defaults.
  /// [transform] defaults to [TextTransform.none], preserving the original case of the text unless overridden.
  const ButtonTypography({
    this.textVariant,
    this.fontFamily,
    this.style,
    this.align,
    this.transform = TextTransform.none,
    this.maxLines,
    this.overflow,
    this.color,
    this.height,
    this.fontWeight,
    this.fontStyle,
    this.letterSpacing,
    this.decoration,
  });

  /// Returns a new [ButtonTypography] object with the fields replaced by the given values.
  ///
  /// Use this for easy, immutable customization.
  ButtonTypography copyWith({
    TextVariant? textVariant,
    String? fontFamily,
    TextStyle? style,
    TextAlign? align,
    TextTransform? transform,
    int? maxLines,
    TextOverflow? overflow,
    Color? color,
    double? height,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    TextDecoration? decoration,
  }) =>
      ButtonTypography(
        textVariant: textVariant ?? this.textVariant,
        fontFamily: fontFamily ?? this.fontFamily,
        style: style ?? this.style,
        align: align ?? this.align,
        transform: transform ?? this.transform,
        maxLines: maxLines ?? this.maxLines,
        overflow: overflow ?? this.overflow,
        color: color ?? this.color,
        height: height ?? this.height,
        fontWeight: fontWeight ?? this.fontWeight,
        fontStyle: fontStyle ?? this.fontStyle,
        letterSpacing: letterSpacing ?? this.letterSpacing,
        decoration: decoration ?? this.decoration,
      );
}

/// {@template button_layout}
/// # ButtonLayout
///
/// Comprehensive layout configuration for button dimensions, spacing, and alignment.
///
/// This class allows you to control the physical and spatial aspects of your button, including:
///
/// - **Size constraints**: Set minimum, maximum, or fixed width/height.
/// - **Padding and margins**: Control inner and outer spacing.
/// - **Content alignment**: Arrange text, icons, and other children.
/// - **Spacing**: Manage gaps between content and icons.
/// - **Border properties**: Fine-tune corner radius and border appearance.
/// - **Material-specific options**: Control tap targets and visual density.
///
/// ## Example Usage
/// ```dart
/// Button(
///   text: 'Continue',
///   layout: ButtonLayout(
///     expanded: true,
///     height: 56.0,
///     minWidth: 160.0,
///     borderRadius: BorderRadius.circular(16.0),
///     margin: EdgeInsets.symmetric(vertical: 8.0),
///     contentPadding: EdgeInsets.symmetric(horizontal: 24.0),
///     iconSpacing: 12.0,
///   ),
///   onPressed: continueAction,
/// )
/// ```
///
/// ## Tips
/// - Any property left `null` will use sensible defaults based on button size, variant, or app theme.
/// - Use [expanded] to make the button fill the available horizontal space (e.g., in a Row).
/// - [contentPadding] is for internal padding between content and button edge; [padding] applies to the whole button.
/// - [margin] places space outside the button widget.
/// - [iconSpacing] and [contentSpacing] allow precise control over layout in buttons with multiple children.
///
/// {@endtemplate}
class ButtonLayout {
  /// Whether the button should expand to fill all available horizontal space.
  ///
  /// *Type*: `bool`
  ///
  /// - Set to `true` to make the button stretch horizontally.
  /// - Set to `false` to size the button naturally to its content (default).
  ///
  /// *Example*: `expanded: true`
  final bool expanded;

  /// The **minimum width** the button can shrink to.
  ///
  /// *Type*: `double?`
  ///
  /// - Accepts any positive double value (e.g., `80.0`).
  /// - If `null`, the minimum width is determined by the button's content or theme.
  ///
  /// *Example*: `minWidth: 120.0`
  final double? minWidth;

  /// The **maximum width** the button can grow to.
  ///
  /// *Type*: `double?`
  ///
  /// - Accepts any positive double value (e.g., `300.0`).
  /// - If `null`, the button can grow as wide as its parent allows.
  ///
  /// *Example*: `maxWidth: 240.0`
  final double? maxWidth;

  /// The **minimum height** the button can shrink to.
  ///
  /// *Type*: `double?`
  ///
  /// - Accepts any positive double value (e.g., `40.0`).
  /// - If `null`, the minimum height is determined by content or theme.
  ///
  /// *Example*: `minHeight: 40.0`
  final double? minHeight;

  /// The **fixed height** for the button.
  ///
  /// *Type*: `double?`
  ///
  /// - Sets the button to a specific height, regardless of content.
  /// - If `null`, height is determined by content and padding.
  ///
  /// *Example*: `height: 56.0`
  final double? height;

  /// The **maximum height** the button can grow to.
  ///
  /// *Type*: `double?`
  ///
  /// - Limits button height to this value if set.
  /// - If `null`, height is unconstrained.
  ///
  /// *Example*: `maxHeight: 64.0`
  final double? maxHeight;

  /// **Padding** around the entire button content.
  ///
  /// *Type*: `EdgeInsetsGeometry?`
  ///
  /// - Sets inner spacing inside the button boundary.
  /// - Use [EdgeInsets.all], [EdgeInsets.symmetric], or [EdgeInsets.only].
  /// - If `null`, uses default padding based on size & density.
  ///
  /// *Example*: `padding: EdgeInsets.symmetric(horizontal: 16.0)`
  final EdgeInsetsGeometry? padding;

  /// Additional **content padding** around the button's child widgets.
  ///
  /// *Type*: `EdgeInsetsGeometry?`
  ///
  /// - Adds extra padding *inside* the button, between content and edges.
  /// - Useful for buttons with both icons and text.
  /// - If `null`, uses the default content padding.
  ///
  /// *Example*: `contentPadding: EdgeInsets.symmetric(horizontal: 20.0)`
  final EdgeInsetsGeometry? contentPadding;

  /// **Margin** around the entire button widget.
  ///
  /// *Type*: `EdgeInsetsGeometry?`
  ///
  /// - Adds space outside the button, separating it from other widgets.
  /// - Use [EdgeInsets.all], [EdgeInsets.symmetric], or [EdgeInsets.only].
  ///
  /// *Example*: `margin: EdgeInsets.only(bottom: 12.0)`
  final EdgeInsetsGeometry? margin;

  /// **Horizontal alignment** of content within the button ([Row] main axis).
  ///
  /// *Type*: `MainAxisAlignment`
  ///
  /// - Use [MainAxisAlignment.start], [MainAxisAlignment.center] (default), [MainAxisAlignment.end], etc.
  /// - Controls how icons, text, and other children are positioned horizontally.
  ///
  /// *Example*: `contentAlignment: MainAxisAlignment.spaceBetween`
  final MainAxisAlignment contentAlignment;

  /// **Vertical alignment** of content within the button ([Row] cross axis).
  ///
  /// *Type*: `CrossAxisAlignment`
  ///
  /// - Use [CrossAxisAlignment.center] (default), [CrossAxisAlignment.start], [CrossAxisAlignment.end], etc.
  /// - Controls vertical alignment of content in the button.
  ///
  /// *Example*: `crossAlignment: CrossAxisAlignment.start`
  final CrossAxisAlignment crossAlignment;

  /// **Space between items** in the button content (e.g. between icon and text).
  ///
  /// *Type*: `double?`
  ///
  /// - Number of logical pixels between children.
  /// - If `null`, uses a default based on button size/density.
  ///
  /// *Example*: `contentSpacing: 8.0`
  final double? contentSpacing;

  /// **Size of icons** within the button.
  ///
  /// *Type*: `double?`
  ///
  /// - Sets width/height for [Icon] widgets in the button.
  /// - If `null`, uses default icon size for button size.
  ///
  /// *Example*: `iconSize: 20.0`
  final double? iconSize;

  /// **Spacing between icons and text** in the button.
  ///
  /// *Type*: `double?`
  ///
  /// - Sets logical pixel gap between an icon and the adjacent text.
  /// - If `null`, uses the default for current button size.
  ///
  /// *Example*: `iconSpacing: 12.0`
  final double? iconSpacing;

  /// **Border radius** of the button's corners.
  ///
  /// *Type*: `BorderRadius?`
  ///
  /// - Use [BorderRadius.circular] for rounded corners, [BorderRadius.zero] for sharp.
  /// - Controls the roundness of button corners.
  /// - If `null`, uses the default for button shape/variant.
  ///
  /// *Example*: `borderRadius: BorderRadius.circular(16.0)`
  final BorderRadius? borderRadius;

  /// **Width of the button border** (for outlined/ghost variants).
  ///
  /// *Type*: `double?`
  ///
  /// - Sets the thickness of the border in logical pixels.
  /// - If `null`, uses default (usually `1.0` for outlined).
  ///
  /// *Example*: `borderWidth: 2.0`
  final double? borderWidth;

  /// **Style of the button border** (solid, dashed, etc).
  ///
  /// *Type*: `BorderStyle?`
  ///
  /// - Use [BorderStyle.solid] (default) or [BorderStyle.none].
  /// - Custom border styles (dashed, etc) may require a custom shape.
  ///
  /// *Example*: `borderStyle: BorderStyle.solid`
  final BorderStyle? borderStyle;

  /// **Material tap target size** configuration.
  ///
  /// *Type*: `MaterialTapTargetSize?`
  ///
  /// - Use [MaterialTapTargetSize.shrinkWrap] for compact buttons, or [MaterialTapTargetSize.padded] for increased hit area.
  /// - If `null`, uses theme or Material default.
  ///
  /// *Example*: `tapTargetSize: MaterialTapTargetSize.shrinkWrap`
  final MaterialTapTargetSize? tapTargetSize;

  /// **Visual density** for Material components.
  ///
  /// *Type*: `VisualDensity?`
  ///
  /// - Controls the density (spacing) of Material widgets.
  /// - Use [VisualDensity.compact], [VisualDensity.standard], etc.
  /// - If `null`, uses the app's default visual density.
  ///
  /// *Example*: `visualDensity: VisualDensity.compact`
  final VisualDensity? visualDensity;

  /// Creates a layout configuration for button dimensions and spacing.
  ///
  /// By default, [expanded] is false and alignment is centered.
  /// Any property left `null` will use the default for the size, variant, or theme.
  const ButtonLayout({
    this.expanded = false,
    this.minWidth,
    this.maxWidth,
    this.minHeight,
    this.height,
    this.maxHeight,
    this.padding,
    this.contentPadding,
    this.margin,
    this.contentAlignment = MainAxisAlignment.center,
    this.crossAlignment = CrossAxisAlignment.center,
    this.contentSpacing,
    this.iconSize,
    this.iconSpacing,
    this.borderRadius,
    this.borderWidth,
    this.borderStyle,
    this.tapTargetSize,
    this.visualDensity,
  });

  /// Returns a new [ButtonLayout] object with the fields replaced by the given values.
  ///
  /// Use this for easy, immutable customization.
  ButtonLayout copyWith({
    bool? expanded,
    double? minWidth,
    double? maxWidth,
    double? minHeight,
    double? height,
    double? maxHeight,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? contentPadding,
    EdgeInsetsGeometry? margin,
    MainAxisAlignment? contentAlignment,
    CrossAxisAlignment? crossAlignment,
    double? contentSpacing,
    double? iconSize,
    double? iconSpacing,
    BorderRadius? borderRadius,
    double? borderWidth,
    BorderStyle? borderStyle,
    MaterialTapTargetSize? tapTargetSize,
    VisualDensity? visualDensity,
  }) =>
      ButtonLayout(
        expanded: expanded ?? this.expanded,
        minWidth: minWidth ?? this.minWidth,
        maxWidth: maxWidth ?? this.maxWidth,
        minHeight: minHeight ?? this.minHeight,
        height: height ?? this.height,
        maxHeight: maxHeight ?? this.maxHeight,
        padding: padding ?? this.padding,
        contentPadding: contentPadding ?? this.contentPadding,
        margin: margin ?? this.margin,
        contentAlignment: contentAlignment ?? this.contentAlignment,
        crossAlignment: crossAlignment ?? this.crossAlignment,
        contentSpacing: contentSpacing ?? this.contentSpacing,
        iconSize: iconSize ?? this.iconSize,
        iconSpacing: iconSpacing ?? this.iconSpacing,
        borderRadius: borderRadius ?? this.borderRadius,
        borderWidth: borderWidth ?? this.borderWidth,
        borderStyle: borderStyle ?? this.borderStyle,
        tapTargetSize: tapTargetSize ?? this.tapTargetSize,
        visualDensity: visualDensity ?? this.visualDensity,
      );
}

/// {@template button_effects}
/// # ButtonEffects
///
/// Visual effects and interaction configuration for custom buttons.
///
/// This class enables fine-grained control over the button's animated and interactive visual properties, including:
///
/// - **Elevation and shadow**: Control depth and drop shadow on various states (normal, hover, focus, pressed, disabled).
/// - **Animation**: Configure the speed and curve of transition animations.
/// - **Interaction feedback**: Manage feedback (haptic/audio) and clipping of child content.
///
/// ## Example Usage
/// ```dart
/// Button(
///   text: 'Animate',
///   effects: ButtonEffects(
///     elevation: 2.0,                              // Default elevation (z-depth)
///     hoverElevation: 4.0,                         // Elevation on hover
///     shadowColor: Colors.purple.withOpacity(0.3), // Custom shadow color
///     animationDuration: Duration(milliseconds: 300), // Longer animation
///     animationCurve: Curves.easeOutBack,          // Springy animation
///     enableFeedback: true,                        // Haptic feedback on tap
///     clipBehavior: true,                          // Clip overflowing content
///   ),
///   onPressed: animateContent,
/// )
/// ```
///
/// ## Tips
/// - Any property left `null` will use a sensible default based on the button's theme or Material guidelines.
/// - Use per-state elevation (e.g. [hoverElevation], [pressedElevation]) for rich, interactive feedback.
/// - [animationDuration] and [animationCurve] create smooth transitions between states (hover, press, etc).
/// - Enable [clipBehavior] if your button has custom backgrounds or animated children that might overflow.
///
/// {@endtemplate}
class ButtonEffects {
  /// The **base elevation** (z-depth) of the button in its normal state.
  ///
  /// *Type*: `double?`
  ///
  /// - Accepts any non-negative double (e.g., `0.0` for flat, `2.0` for raised).
  /// - If `null`, uses the theme or Material default (usually `0` for flat, `2` for raised).
  ///
  /// *Example*: `elevation: 2.0`
  final double? elevation;

  /// The **elevation when the button is hovered** by mouse or pointer.
  ///
  /// *Type*: `double?`
  ///
  /// - Accepts any non-negative double.
  /// - If `null`, defaults to [elevation] or adds +1 to the base elevation.
  ///
  /// *Example*: `hoverElevation: 4.0`
  final double? hoverElevation;

  /// The **elevation when the button receives focus** (e.g., via keyboard).
  ///
  /// *Type*: `double?`
  ///
  /// - Accepts any non-negative double.
  /// - If `null`, uses [elevation] or theme default for focused state.
  ///
  /// *Example*: `focusElevation: 3.0`
  final double? focusElevation;

  /// The **elevation when the button is pressed** (actively tapped/clicked).
  ///
  /// *Type*: `double?`
  ///
  /// - Accepts any non-negative double.
  /// - If `null`, defaults to [elevation] + 2 or theme default.
  ///
  /// *Example*: `pressedElevation: 6.0`
  final double? pressedElevation;

  /// The **elevation when the button is disabled**.
  ///
  /// *Type*: `double?`
  ///
  /// - Accepts any non-negative double.
  /// - If `null`, uses [elevation] or theme's disabled elevation (often `0`).
  ///
  /// *Example*: `disabledElevation: 0.0`
  final double? disabledElevation;

  /// The **color of the button's drop shadow**.
  ///
  /// *Type*: `Color?`
  ///
  /// - Accepts any [Color].
  /// - If `null`, defaults to the theme's shadow color (often `Colors.black26`).
  ///
  /// *Example*: `shadowColor: Colors.black.withOpacity(0.2)`
  final Color? shadowColor;

  /// The **offset of the drop shadow** in logical pixels.
  ///
  /// *Type*: `Offset?`
  ///
  /// - Use [Offset(x, y)] to shift the shadow horizontally (x) or vertically (y).
  /// - If `null`, uses the Material default (often `Offset(0, 2)`).
  ///
  /// *Example*: `shadowOffset: Offset(0, 4)`
  final Offset? shadowOffset;

  /// The **duration of all state transition animations** (hover, press, focus, etc).
  ///
  /// *Type*: `Duration`
  ///
  /// - Default is `Duration(milliseconds: 200)`.
  /// - Use a longer duration for more dramatic effects or a shorter one for snappier transitions.
  ///
  /// *Example*: `animationDuration: Duration(milliseconds: 350)`
  final Duration animationDuration;

  /// The **curve used for state transition animations**.
  ///
  /// *Type*: `Curve`
  ///
  /// - Default is [Curves.easeInOut] for smooth motion.
  /// - Use other [Curve]s for bouncy, linear, or custom easing.
  ///
  /// *Example*: `animationCurve: Curves.easeInCubic`
  final Curve animationCurve;

  /// Whether to **provide feedback** (haptic, audio, etc) when the button is tapped.
  ///
  /// *Type*: `bool`
  ///
  /// - Default is `true`.
  /// - Set to `false` for silent or non-interactive buttons.
  ///
  /// *Example*: `enableFeedback: false`
  final bool enableFeedback;

  /// Whether to **clip content** that overflows the button's boundaries.
  ///
  /// *Type*: `bool`
  ///
  /// - If `true`, content that extends beyond the button will be clipped (using [Clip.antiAlias]).
  /// - If `false` (default), overflow is allowed.
  /// - Useful for buttons with animated backgrounds or child widgets.
  ///
  /// *Example*: `clipBehavior: true`
  final bool clipBehavior;

  /// Creates a visual effects configuration for button interactivity and animation.
  ///
  /// By default, animations use a 200ms ease-in-out curve, feedback is enabled, and content is not clipped.
  const ButtonEffects({
    this.elevation,
    this.hoverElevation,
    this.focusElevation,
    this.pressedElevation,
    this.disabledElevation,
    this.shadowColor,
    this.shadowOffset,
    this.animationDuration = const Duration(milliseconds: 200),
    this.animationCurve = Curves.easeInOut,
    this.enableFeedback = true,
    this.clipBehavior = false,
  });

  /// Returns a new [ButtonEffects] object with the fields replaced by the given values.
  ///
  /// Use this method for immutable updates and chaining.
  ButtonEffects copyWith({
    double? elevation,
    double? hoverElevation,
    double? focusElevation,
    double? pressedElevation,
    double? disabledElevation,
    Color? shadowColor,
    Offset? shadowOffset,
    Duration? animationDuration,
    Curve? animationCurve,
    bool? enableFeedback,
    bool? clipBehavior,
  }) =>
      ButtonEffects(
        elevation: elevation ?? this.elevation,
        hoverElevation: hoverElevation ?? this.hoverElevation,
        focusElevation: focusElevation ?? this.focusElevation,
        pressedElevation: pressedElevation ?? this.pressedElevation,
        disabledElevation: disabledElevation ?? this.disabledElevation,
        shadowColor: shadowColor ?? this.shadowColor,
        shadowOffset: shadowOffset ?? this.shadowOffset,
        animationDuration: animationDuration ?? this.animationDuration,
        animationCurve: animationCurve ?? this.animationCurve,
        enableFeedback: enableFeedback ?? this.enableFeedback,
        clipBehavior: clipBehavior ?? this.clipBehavior,
      );
}

/// {@template button_loading_config}
/// # ButtonLoadingConfig
///
/// Configuration for the loading state of buttons, offering full control over the
/// indicator's appearance and behavior.
///
/// This class allows you to:
/// - Show a loading spinner or custom widget while an async operation is in progress.
/// - Customize the color, size, and stroke of the indicator.
/// - Seamlessly swap in a custom loading widget for advanced use-cases.
///
/// ## Example Usage
/// ```dart
/// Button(
///   text: 'Submit',
///   loading: ButtonLoadingConfig(
///     isLoading: _isLoading,        // Toggle loading state
///     color: Colors.white,          // Spinner color
///     size: 20.0,                   // Spinner size
///   ),
///   onPressed: _isLoading ? null : handleSubmit,
/// )
/// ```
///
/// ## Tips
/// - Use [isLoading] to toggle any loading UI on or off.
/// - Provide a [widget] to fully customize the loading placeholder (e.g., animated logo, shimmer, etc).
/// - If [widget] is not provided, a [CircularProgressIndicator] will be used with your specified [color], [size], and [strokeWidth].
///
/// {@endtemplate}
class ButtonLoadingConfig {
  /// Whether the button is currently in a loading state.
  ///
  /// *Type*: `bool`
  ///
  /// - Set to `true` to display a loading indicator and prevent user interaction.
  /// - Set to `false` for normal button behavior (default).
  ///
  /// *Example*: `isLoading: true`
  final bool isLoading;

  /// Custom widget to display as the loading indicator.
  ///
  /// *Type*: `Widget?`
  ///
  /// - Provide any widget for advanced loading visuals (e.g., a Lottie animation, custom SVG, shimmer, etc).
  /// - If `null`, a default [CircularProgressIndicator] is shown.
  ///
  /// *Example*: `widget: MyCustomSpinner()`
  final Widget? widget;

  /// Color of the default loading spinner.
  ///
  /// *Type*: `Color?`
  ///
  /// - Determines the color of the default [CircularProgressIndicator].
  /// - Has no effect if a custom [widget] is used.
  /// - If `null`, uses the button's foreground or theme color.
  ///
  /// *Example*: `color: Colors.white`
  final Color? color;

  /// Size (diameter) of the default loading spinner in logical pixels.
  ///
  /// *Type*: `double?`
  ///
  /// - Sets width and height of the default [CircularProgressIndicator].
  /// - Has no effect if a custom [widget] is used.
  /// - If `null`, uses a sensible default size (usually 18-24).
  ///
  /// *Example*: `size: 20.0`
  final double? size;

  /// Stroke width of the default loading spinner.
  ///
  /// *Type*: `double`
  ///
  /// - Controls the thickness of the [CircularProgressIndicator] stroke.
  /// - Has no effect if a custom [widget] is used.
  /// - Default is `2.0`.
  ///
  /// *Example*: `strokeWidth: 3.0`
  final double strokeWidth;

  /// Creates a loading state configuration for buttons.
  ///
  /// By default, [isLoading] is `false` and [strokeWidth] is `2.0`.
  /// All other properties are optional and fall back to reasonable defaults.
  const ButtonLoadingConfig({
    this.isLoading = false,
    this.widget,
    this.color,
    this.size,
    this.strokeWidth = 2.0,
  });

  /// Returns a copy of this config with fields replaced by new values.
  ///
  /// Use for immutable updates and chaining.
  ButtonLoadingConfig copyWith({
    bool? isLoading,
    Widget? widget,
    Color? color,
    double? size,
    double? strokeWidth,
  }) =>
      ButtonLoadingConfig(
        isLoading: isLoading ?? this.isLoading,
        widget: widget ?? this.widget,
        color: color ?? this.color,
        size: size ?? this.size,
        strokeWidth: strokeWidth ?? this.strokeWidth,
      );
}

/// {@template button_style_config}
/// # ButtonStyleConfig
///
/// The **central configuration class** that unifies all styling and behavioral aspects of a custom button.
///
/// Use this class to define or reuse a cohesive style for one or more buttons, encapsulating:
///
/// - **Button variant**: Visual type (primary, ghost, outlined, etc)
/// - **Size and density**: Large, small, compact, etc.
/// - **Shape**: Rounded, rectangle, fully rounded, etc.
/// - **Color scheme**: Detailed color settings for all states
/// - **Typography**: Font, case, size, and text styling
/// - **Layout**: Padding, margin, alignment, icon spacing, etc.
/// - **Visual effects**: Elevation, shadow, animation, feedback
/// - **Loading state**: Indicator appearance and behavior
///
/// ## Example Usage
/// ```dart
/// // Create a reusable style
/// final myCustomStyle = ButtonStyleConfig(
///   variant: ButtonVariant.ghost,                        // Ghost style
///   size: ButtonSize.small,                              // Small button
///   typography: ButtonTypography(transform: TextTransform.uppercase), // All caps label
///   colors: ButtonColors(text: Colors.indigo),           // Indigo label
/// );
///
/// // Use with multiple buttons
/// Button(
///   text: 'First Action',
///   styleConfig: myCustomStyle,
///   onPressed: firstAction,
/// )
/// Button(
///   text: 'Second Action',
///   styleConfig: myCustomStyle,
///   onPressed: secondAction,
/// )
/// ```
///
/// ## Tips
/// - Any property left `null` or with its default will use the best value based on the theme, button variant, or app typography system.
/// - Use [copyWith] to create subtle variations of a base style (e.g., only change color or size).
/// - [ButtonStyleConfig] is usually constructed by the Button widget, but you can also create and assign your own for maximum flexibility.
///
/// {@endtemplate}
class ButtonStyleConfig {
  /// The **visual variant** of the button.
  ///
  /// *Type*: `ButtonVariant`
  ///
  /// - Choose from: [ButtonVariant.primary], [ButtonVariant.secondary], [ButtonVariant.ghost], [ButtonVariant.outlined], [ButtonVariant.text], [ButtonVariant.warning], [ButtonVariant.neutral], [ButtonVariant.danger], [ButtonVariant.unstyled], [ButtonVariant.light].
  /// - Each variant applies a unique color and border style.
  /// - Default: [ButtonVariant.primary]
  ///
  /// *Example*: `variant: ButtonVariant.outlined`
  final ButtonVariant variant;

  /// The **size** of the button.
  ///
  /// *Type*: `ButtonSize`
  ///
  /// - Options: [ButtonSize.extraSmall], [ButtonSize.small], [ButtonSize.normal], [ButtonSize.large], [ButtonSize.extraLarge].
  /// - Controls height, font size, padding, and icon size.
  /// - Default: [ButtonSize.normal]
  ///
  /// *Example*: `size: ButtonSize.large`
  final ButtonSize size;

  /// The **internal density (spacing)** of the button.
  ///
  /// *Type*: `ButtonDensity`
  ///
  /// - Options: [ButtonDensity.compact], [ButtonDensity.dense], [ButtonDensity.normal], [ButtonDensity.comfortable], [ButtonDensity.icon], [ButtonDensity.iconComfortable].
  /// - Determines padding and spacing—for more compact or more spacious buttons.
  /// - Default: [ButtonDensity.normal]
  ///
  /// *Example*: `density: ButtonDensity.compact`
  final ButtonDensity density;

  /// The **shape** of the button's border.
  ///
  /// *Type*: `ButtonShape`
  ///
  /// - Options: [ButtonShape.fullRounded] (pill), [ButtonShape.rectangle], [ButtonShape.roundedRectangle] (default), [ButtonShape.customRounded] (use [ButtonLayout.borderRadius]).
  /// - Controls the roundness of corners.
  /// - Default: [ButtonShape.roundedRectangle]
  ///
  /// *Example*: `shape: ButtonShape.fullRounded`
  final ButtonShape shape;

  /// Whether the button is **disabled**.
  ///
  /// *Type*: `bool`
  ///
  /// - Set to `true` to disable the button (not tappable or focusable).
  /// - Disabled buttons use faded colors and ignore tap events.
  /// - Default: `false`
  ///
  /// *Example*: `disabled: true`
  final bool disabled;

  /// Whether the button is an **icon-only button** (no text).
  ///
  /// *Type*: `bool`
  ///
  /// - Set to `true` for icon-only buttons (FABs, icon toggles, etc).
  /// - Button content will only display the specified icon(s).
  /// - Default: `false`
  ///
  /// *Example*: `iconOnly: true`
  final bool iconOnly;

  /// The **color scheme** for the button.
  ///
  /// *Type*: [ButtonColors]
  ///
  /// - Use this for fine-grained color control of background, text, border, icon, hover, pressed, disabled, gradient, and overlay.
  /// - Each property in [ButtonColors] can be omitted for theme/variant defaults.
  /// - Default: `const ButtonColors()`
  ///
  /// *Example*: `colors: ButtonColors(background: Colors.red, text: Colors.white)`
  final ButtonColors colors;

  /// The **typography configuration** for the button label.
  ///
  /// *Type*: [ButtonTypography]
  ///
  /// - Controls font family, size, weight, casing, color, style, spacing, line height, and text decorations.
  /// - Each property in [ButtonTypography] can be omitted for default behavior.
  /// - Default: `const ButtonTypography()`
  ///
  /// *Example*: `typography: ButtonTypography(transform: TextTransform.uppercase)`
  final ButtonTypography typography;

  /// The **layout configuration** for the button's dimensions and spacing.
  ///
  /// *Type*: [ButtonLayout]
  ///
  /// - Controls padding, margin, min/max width/height, alignment, icon spacing, border radius, etc.
  /// - Use for responsive, aligned, or visually distinct buttons.
  /// - Default: `const ButtonLayout()`
  ///
  /// *Example*: `layout: ButtonLayout(expanded: true, height: 56.0)`
  final ButtonLayout layout;

  /// The **visual effects** applied to the button for interaction and animation.
  ///
  /// *Type*: [ButtonEffects]
  ///
  /// - Use for elevation, shadow, animation timing/curve, feedback, and clipping.
  /// - Each property in [ButtonEffects] can be omitted for sensible defaults.
  /// - Default: `const ButtonEffects()`
  ///
  /// *Example*: `effects: ButtonEffects(elevation: 4.0, animationDuration: Duration(milliseconds: 300))`
  final ButtonEffects effects;

  /// The **loading state configuration** for the button.
  ///
  /// *Type*: [ButtonLoadingConfig]
  ///
  /// - Controls the appearance and behavior of the loading indicator.
  /// - Use for displaying spinners or custom widgets during async actions.
  /// - Default: `const ButtonLoadingConfig()`
  ///
  /// *Example*: `loading: ButtonLoadingConfig(isLoading: true, color: Colors.white)`
  final ButtonLoadingConfig loading;

  /// Creates a comprehensive style configuration for buttons.
  ///
  /// By default, creates a standard primary button with normal size and density,
  /// centered content, and no loading state.
  const ButtonStyleConfig({
    this.variant = ButtonVariant.primary,
    this.size = ButtonSize.normal,
    this.density = ButtonDensity.normal,
    this.shape = ButtonShape.roundedRectangle,
    this.disabled = false,
    this.iconOnly = false,
    this.colors = const ButtonColors(),
    this.typography = const ButtonTypography(),
    this.layout = const ButtonLayout(),
    this.effects = const ButtonEffects(),
    this.loading = const ButtonLoadingConfig(),
  });

  /// Returns a new [ButtonStyleConfig] object with the specified fields replaced by new values.
  ///
  /// Use this to create customized variations of an existing style for different button instances.
  ButtonStyleConfig copyWith({
    ButtonVariant? variant,
    ButtonSize? size,
    ButtonDensity? density,
    ButtonShape? shape,
    bool? disabled,
    bool? iconOnly,
    ButtonColors? colors,
    ButtonTypography? typography,
    ButtonLayout? layout,
    ButtonEffects? effects,
    ButtonLoadingConfig? loading,
  }) =>
      ButtonStyleConfig(
        variant: variant ?? this.variant,
        size: size ?? this.size,
        density: density ?? this.density,
        shape: shape ?? this.shape,
        disabled: disabled ?? this.disabled,
        iconOnly: iconOnly ?? this.iconOnly,
        colors: colors ?? this.colors,
        typography: typography ?? this.typography,
        layout: layout ?? this.layout,
        effects: effects ?? this.effects,
        loading: loading ?? this.loading,
      );
}

/// {@template button_widget}
/// # Button Widget
///
/// A highly customizable button widget for Flutter applications that
/// streamlines the creation of consistent UI components according to
/// design system guidelines.
///
/// ## Features
///
/// - 10 visual variants (primary, secondary, warning, etc.)
/// - 5 size options with appropriate text styling
/// - 6 density configurations for space optimization
/// - Comprehensive state handling (hover, focus, press, disabled)
/// - Loading state management
/// - Built-in icon support (left, right, or icon-only)
/// - Rich typography integration with the AppText system
/// - Extensive customization options for colors, layout, and effects
/// - Animation and interaction feedback
///
/// ## Usage Examples
///
/// ### Basic Button
/// ```dart
/// Button(
///   text: 'Click Me',
///   onPressed: () => print('Button clicked!'),
/// )
/// ```
///
/// ### Styled Variants
/// ```dart
/// // Primary button (default)
/// Button(
///   text: 'Save',
///   onPressed: handleSave,
/// )
///
/// // Outlined button
/// Button(
///   text: 'Cancel',
///   variant: ButtonVariant.outlined,
///   onPressed: handleCancel,
/// )
///
/// // Danger button
/// Button(
///   text: 'Delete',
///   variant: ButtonVariant.danger,
///   onPressed: handleDelete,
/// )
/// ```
///
/// ### With Icons
/// ```dart
/// // Left icon
/// Button(
///   text: 'Add Item',
///   leftIcon: Icons.add,
///   onPressed: addItem,
/// )
///
/// // Right icon
/// Button(
///   text: 'Next',
///   rightIcon: Icons.arrow_forward,
///   onPressed: goToNextStep,
/// )
///
/// // Icon-only button
/// Button(
///   leftIcon: Icons.favorite,
///   iconOnly: true,
///   variant: ButtonVariant.ghost,
///   onPressed: toggleFavorite,
/// )
/// ```
///
/// ### Advanced Styling
/// ```dart
/// Button(
///   text: 'Custom Button',
///   variant: ButtonVariant.light,
///   size: ButtonSize.large,
///   shape: ButtonShape.fullRounded,
///   colors: ButtonColors(
///     background: Colors.teal,
///     text: Colors.white,
///     hover: Colors.tealAccent,
///   ),
///   typography: ButtonTypography(
///     transform: TextTransform.uppercase,
///     letterSpacing: 1.2,
///   ),
///   layout: ButtonLayout(
///     expanded: true,
///     height: 56.0,
///     margin: EdgeInsets.symmetric(vertical: 16.0),
///   ),
///   effects: ButtonEffects(
///     elevation: 2.0,
///     hoverElevation: 4.0,
///     animationDuration: Duration(milliseconds: 300),
///   ),
///   onPressed: performAction,
/// )
/// ```
///
/// ### Loading State
/// ```dart
/// Button(
///   text: 'Submit',
///   loading: ButtonLoadingConfig(
///     isLoading: isSubmitting,
///     color: Colors.white,
///   ),
///   onPressed: isSubmitting ? null : handleSubmit,
/// )
/// ```
///
/// ### Custom Content Builder
/// ```dart
/// Button(
///   builder: (context, isPressed, isHovered, isFocused) {
///     return Row(
///       mainAxisSize: MainAxisSize.min,
///       children: [
///         Icon(
///           Icons.star,
///           color: isHovered ? Colors.amber : Colors.grey,
///         ),
///         SizedBox(width: 8),
///         Text(
///           'Rate: ${isPressed ? "Pressed!" : "Click me"}',
///           style: TextStyle(
///             fontWeight: isFocused ? FontWeight.bold : FontWeight.normal,
///           ),
///         ),
///       ],
///     );
///   },
///   onPressed: handleRating,
/// )
/// ```
///
/// ### Expanded Button
/// ```dart
/// Button(
///   text: 'Full Width Button',
///   layout: ButtonLayout(expanded: true),
///   onPressed: handleAction,
/// )
/// ```
/// {@endtemplate}
class Button extends StatefulWidget {
  /// {@template button_child}
  /// Custom child widget to display inside the button.
  ///
  /// *Type*: `Widget?`
  ///
  /// - Use this to provide full control over the button's content.
  /// - If set, [text], [textSpan], [leftIcon], [rightIcon], [builder], etc. are ignored.
  ///
  /// *Example*: `child: Row(children: [...])`
  /// {@endtemplate}
  final Widget? child;

  /// {@template button_text}
  /// The string label to display inside the button.
  ///
  /// *Type*: `String?`
  ///
  /// - Simple way to add a text label.
  /// - If both [text] and [child] are provided, [child] takes precedence.
  ///
  /// *Example*: `text: 'Submit'`
  /// {@endtemplate}
  final String? text;

  /// {@template button_textSpan}
  /// Rich text ([InlineSpan]) to display inside the button.
  ///
  /// *Type*: `InlineSpan?`
  ///
  /// - Use for complex/partially styled labels.
  /// - If both [textSpan] and [text] are provided, [textSpan] takes precedence.
  ///
  /// *Example*: `textSpan: TextSpan(children: [...])`
  /// {@endtemplate}
  final InlineSpan? textSpan;

  /// {@template button_leftIcon}
  /// Icon to display on the left side of the button's content.
  ///
  /// *Type*: `IconData?`
  ///
  /// - Use any Flutter icon (e.g. `Icons.add`, `Icons.arrow_back`).
  /// - If [iconOnly] is true, only this icon is shown.
  ///
  /// *Example*: `leftIcon: Icons.add`
  /// {@endtemplate}
  final IconData? leftIcon;

  /// {@template button_rightIcon}
  /// Icon to display on the right side of the button's content.
  ///
  /// *Type*: `IconData?`
  ///
  /// - Use any Flutter icon.
  /// - Only shown if [iconOnly] is false.
  ///
  /// *Example*: `rightIcon: Icons.arrow_forward`
  /// {@endtemplate}
  final IconData? rightIcon;

  /// {@template button_leftWidget}
  /// Custom widget to display on the left side of the button.
  ///
  /// *Type*: `Widget?`
  ///
  /// - Use for complex content (e.g., avatar, badge, animated widget).
  /// - If both [leftWidget] and [leftIcon] are set, [leftWidget] is used.
  ///
  /// *Example*: `leftWidget: MyCustomAvatarWidget()`
  /// {@endtemplate}
  final Widget? leftWidget;

  /// {@template button_rightWidget}
  /// Custom widget to display on the right side of the button.
  ///
  /// *Type*: `Widget?`
  ///
  /// - Use for complex content (e.g., badge, counter).
  /// - If both [rightWidget] and [rightIcon] are set, [rightWidget] is used.
  ///
  /// *Example*: `rightWidget: MyBadge()`
  /// {@endtemplate}
  final Widget? rightWidget;

  /// {@template button_builder}
  /// Builder function for completely custom button content.
  ///
  /// *Type*: `Widget Function(BuildContext, bool isPressed, bool isHovered, bool isFocused)?`
  ///
  /// - Use this for advanced scenarios where button content changes based on state.
  /// - Receives the current interaction states as parameters.
  /// - If set, all other content-related props are ignored.
  ///
  /// *Example*:
  /// ```dart
  /// builder: (context, isPressed, isHovered, isFocused) { ... }
  /// ```
  /// {@endtemplate}
  final Widget Function(BuildContext, bool, bool, bool)? builder;

  /// {@template button_onPressed}
  /// Callback function when the button is tapped or clicked.
  ///
  /// *Type*: `VoidCallback?`
  ///
  /// - Provide your action handler here.
  /// - If `null` or [styleConfig.disabled] is true, the button is disabled.
  ///
  /// *Example*: `onPressed: () => print('Clicked!')`
  /// {@endtemplate}
  final VoidCallback? onPressed;

  /// {@template button_onLongPress}
  /// Callback function when the button is long-pressed.
  ///
  /// *Type*: `VoidCallback?`
  ///
  /// - Optional; provide for long-press actions.
  ///
  /// *Example*: `onLongPress: () => showMenu()`
  /// {@endtemplate}
  final VoidCallback? onLongPress;

  /// {@template button_styleConfig}
  /// Complete style configuration for the button.
  ///
  /// *Type*: `ButtonStyleConfig`
  ///
  /// - Controls all aspects of variant, size, density, shape, colors, typography, layout, effects, and loading state.
  /// - Usually set automatically via other properties; override for full programmatic control.
  ///
  /// *Example*: `styleConfig: myCustomButtonStyle`
  /// {@endtemplate}
  final ButtonStyleConfig styleConfig;

  /// {@template button_focusNode}
  /// The [FocusNode] for managing keyboard focus of the button.
  ///
  /// *Type*: `FocusNode?`
  ///
  /// - Use to programmatically control or listen to button focus.
  ///
  /// *Example*: `focusNode: myFocusNode`
  /// {@endtemplate}
  final FocusNode? focusNode;

  /// {@template button_autofocus}
  /// Whether the button should be focused automatically when the widget tree is built.
  ///
  /// *Type*: `bool`
  ///
  /// - Set to `true` to autofocus the button on build.
  /// - Default is `false`.
  ///
  /// *Example*: `autofocus: true`
  /// {@endtemplate}
  final bool autofocus;

  /// {@template button_mouseCursor}
  /// Custom mouse cursor to show when hovering over the button.
  ///
  /// *Type*: `MouseCursor?`
  ///
  /// - Use [SystemMouseCursors.click], [SystemMouseCursors.forbidden], or a custom cursor.
  /// - If `null`, defaults to standard pointer.
  ///
  /// *Example*: `mouseCursor: SystemMouseCursors.click`
  /// {@endtemplate}
  final MouseCursor? mouseCursor;

  /// Creates a highly customizable button widget for Flutter applications.
  ///
  /// {@macro button_widget}
  ///
  /// {@macro button_child}
  /// {@macro button_text}
  /// {@macro button_textSpan}
  /// {@macro button_leftIcon}
  /// {@macro button_rightIcon}
  /// {@macro button_leftWidget}
  /// {@macro button_rightWidget}
  /// {@macro button_builder}
  /// {@macro button_onPressed}
  /// {@macro button_onLongPress}
  /// {@macro button_styleConfig}
  /// {@macro button_focusNode}
  /// {@macro button_autofocus}
  /// {@macro button_mouseCursor}
  ///
  /// ---
  /// See also:
  /// - [ButtonColors], [ButtonTypography], [ButtonLayout], [ButtonEffects], [ButtonLoadingConfig], [ButtonStyleConfig]
  Button({
    super.key,
    this.child,
    this.text,
    this.textSpan,
    this.leftIcon,
    this.rightIcon,
    this.leftWidget,
    this.rightWidget,
    this.builder,
    this.onPressed,
    this.onLongPress,
    ButtonVariant variant = ButtonVariant.primary,
    ButtonSize size = ButtonSize.normal,
    ButtonDensity density = ButtonDensity.normal,
    ButtonShape shape = ButtonShape.roundedRectangle,
    bool disabled = false,
    bool iconOnly = false,
    ButtonColors colors = const ButtonColors(),
    ButtonTypography typography = const ButtonTypography(),
    ButtonLayout layout = const ButtonLayout(),
    ButtonEffects effects = const ButtonEffects(),
    ButtonLoadingConfig loading = const ButtonLoadingConfig(),
    this.focusNode,
    this.autofocus = false,
    this.mouseCursor,
  })  : styleConfig = ButtonStyleConfig(
          variant: variant,
          size: size,
          density: density,
          shape: shape,
          disabled: disabled,
          iconOnly: iconOnly,
          colors: colors,
          typography: typography,
          layout: layout,
          effects: effects,
          loading: loading,
        ),
        assert(
          text != null ||
              textSpan != null ||
              child != null ||
              builder != null ||
              iconOnly ||
              leftIcon != null ||
              rightIcon != null ||
              leftWidget != null ||
              rightWidget != null,
          'Button must have text, child, builder, icon, or custom widgets',
        );

  @override
  State<Button> createState() => _ButtonState();
}

class _ButtonState extends State<Button> {
  bool isHovered = false, isPressed = false, isFocused = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final config = widget.styleConfig;
    final ButtonStyle buttonStyle = _getButtonStyle(theme);

    Widget buttonContent = _buildButtonContent(theme);
    if (config.loading.isLoading) {
      buttonContent = _buildLoadingState(buttonContent, theme, config);
    }

    if (config.layout.margin != null) {
      buttonContent = Padding(
        padding: config.layout.margin!,
        child: buttonContent,
      );
    }

    Widget button = TextButton(
      style: buttonStyle,
      onPressed:
          config.disabled || config.loading.isLoading ? null : widget.onPressed,
      onLongPress: config.disabled || config.loading.isLoading
          ? null
          : widget.onLongPress,
      focusNode: widget.focusNode,
      autofocus: widget.autofocus,
      clipBehavior: config.effects.clipBehavior ? Clip.antiAlias : Clip.none,
      child: buttonContent,
    );

    button = _wrapWithStateTrackers(button, config);

    return config.layout.expanded
        ? Row(children: [Expanded(child: button)])
        : button;
  }

  Widget _buildLoadingState(
      Widget buttonContent, ThemeData theme, ButtonStyleConfig config) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Opacity(opacity: 0.0, child: buttonContent),
        config.loading.widget ??
            SizedBox(
              width: config.loading.size ?? _getIconSize(),
              height: config.loading.size ?? _getIconSize(),
              child: CircularProgressIndicator(
                strokeWidth: config.loading.strokeWidth,
                valueColor: AlwaysStoppedAnimation<Color>(
                  config.loading.color ?? _getContentColor(theme),
                ),
              ),
            ),
      ],
    );
  }

  Widget _wrapWithStateTrackers(Widget button, ButtonStyleConfig config) {
    return AnimatedContainer(
      duration: config.effects.animationDuration,
      curve: config.effects.animationCurve,
      child: MouseRegion(
        onEnter: (_) => setState(() => isHovered = true),
        onExit: (_) => setState(() => isHovered = false),
        cursor: config.disabled
            ? SystemMouseCursors.forbidden
            : widget.mouseCursor ?? SystemMouseCursors.click,
        child: GestureDetector(
          onTapDown: (_) => setState(() => isPressed = true),
          onTapUp: (_) => setState(() => isPressed = false),
          onTapCancel: () => setState(() => isPressed = false),
          child: Focus(
            onFocusChange: (focused) => setState(() => isFocused = focused),
            child: button,
          ),
        ),
      ),
    );
  }

  TextVariant _buttonSizeToTextVariant(ButtonSize size) {
    switch (size) {
      case ButtonSize.extraSmall:
        return TextVariant.labelSmall;
      case ButtonSize.small:
        return TextVariant.labelMedium;
      case ButtonSize.normal:
        return TextVariant.labelLarge;
      case ButtonSize.large:
        return TextVariant.titleSmall;
      case ButtonSize.extraLarge:
        return TextVariant.titleMedium;
    }
  }

  Widget _buildButtonContent(ThemeData theme) {
    final config = widget.styleConfig;
    final Color contentColor = _getContentColor(theme);
    final double spacing =
        config.layout.iconSpacing ?? _getDefaultIconSpacing();
    final double iconSize = config.layout.iconSize ?? _getIconSize();

    if (widget.builder != null) {
      return widget.builder!(context, isPressed, isHovered, isFocused);
    }
    if (widget.child != null) return widget.child!;

    if (config.iconOnly) {
      if (widget.leftWidget != null) return widget.leftWidget!;
      if (widget.rightWidget != null) return widget.rightWidget!;
      if (widget.leftIcon != null) {
        return Icon(widget.leftIcon,
            color: config.colors.icon ?? contentColor, size: iconSize);
      }
      if (widget.rightIcon != null) {
        return Icon(widget.rightIcon,
            color: config.colors.icon ?? contentColor, size: iconSize);
      }
      return const SizedBox(width: 24, height: 24);
    }

    final List<Widget> rowChildren = [];

    void addIconOrWidget(Widget? widget, IconData? icon) {
      if (widget != null) {
        rowChildren.add(widget);
      } else if (icon != null) {
        rowChildren.add(Icon(icon,
            color: config.colors.icon ?? contentColor, size: iconSize));
      }
    }

    // Left
    if (widget.leftWidget != null || widget.leftIcon != null) {
      addIconOrWidget(widget.leftWidget, widget.leftIcon);
      if (widget.text != null || widget.textSpan != null) {
        rowChildren.add(SizedBox(width: spacing));
      }
    }

    // Text
    if (widget.text != null || widget.textSpan != null) {
      TextVariant variant = config.typography.textVariant ??
          _buttonSizeToTextVariant(config.size);

      Widget textWidget;
      if (widget.textSpan != null) {
        textWidget = RichText(
          text: widget.textSpan!,
          textAlign: config.typography.align ?? TextAlign.center,
          overflow: config.typography.overflow ?? TextOverflow.ellipsis,
          maxLines: config.typography.maxLines ?? 1,
        );
      } else {
        String processedText = widget.text!;
        switch (config.typography.transform) {
          case TextTransform.uppercase:
            processedText = processedText.toUpperCase();
            break;
          case TextTransform.lowercase:
            processedText = processedText.toLowerCase();
            break;
          case TextTransform.capitalize:
            processedText = processedText
                .split(' ')
                .map((word) => word.isNotEmpty
                    ? '${word[0].toUpperCase()}${word.substring(1)}'
                    : '')
                .join(' ');
            break;
          case TextTransform.none:
            break;
        }
        textWidget = AppText(
          processedText,
          variant: variant,
          style: config.typography.style?.copyWith(color: contentColor),
          textAlign: config.typography.align,
          overflow: config.typography.overflow ?? TextOverflow.ellipsis,
          maxLines: config.typography.maxLines ?? 1,
          color: contentColor,
          height: config.typography.height,
          fontWeight: config.typography.fontWeight,
          fontStyle: config.typography.fontStyle,
          decoration: config.typography.decoration,
          fontFamily: config.typography.fontFamily,
        );
      }
      rowChildren.add(Flexible(child: textWidget));
    }

    // Right
    if (widget.rightWidget != null || widget.rightIcon != null) {
      if (widget.text != null || widget.textSpan != null) {
        rowChildren.add(SizedBox(width: spacing));
      }
      addIconOrWidget(widget.rightWidget, widget.rightIcon);
    }

    Widget content = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: config.layout.contentAlignment,
      crossAxisAlignment: config.layout.crossAlignment,
      children: rowChildren,
    );

    if (config.layout.contentPadding != null) {
      content = Padding(padding: config.layout.contentPadding!, child: content);
    }

    return content;
  }

  ButtonStyle _getButtonStyle(ThemeData theme) {
    final config = widget.styleConfig;
    final colorScheme = theme.colorScheme;

    Color? backgroundColor, foregroundColor, overlayColor, borderColor;

    switch (config.variant) {
      case ButtonVariant.primary:
        backgroundColor = config.colors.background ?? colorScheme.primary;
        foregroundColor = config.colors.text ?? colorScheme.onPrimary;
        overlayColor = colorScheme.onPrimary.withValues(alpha: 0.1);
        break;
      case ButtonVariant.secondary:
        backgroundColor = config.colors.background ?? colorScheme.secondary;
        foregroundColor = config.colors.text ?? colorScheme.onSecondary;
        overlayColor = colorScheme.onSecondary.withValues(alpha: 0.1);
        break;
      case ButtonVariant.warning:
        backgroundColor = config.colors.background ?? Colors.amber;
        foregroundColor = config.colors.text ?? Colors.black87;
        overlayColor = Colors.black12;
        break;
      case ButtonVariant.neutral:
        backgroundColor = config.colors.background ?? colorScheme.surface;
        foregroundColor = config.colors.text ?? colorScheme.onSurface;
        overlayColor = colorScheme.onSurface.withValues(alpha: 0.05);
        break;
      case ButtonVariant.danger:
        backgroundColor = config.colors.background ?? colorScheme.error;
        foregroundColor = config.colors.text ?? colorScheme.onError;
        overlayColor = colorScheme.onError.withValues(alpha: 0.1);
        break;
      case ButtonVariant.unstyled:
        backgroundColor = config.colors.background ?? Colors.transparent;
        foregroundColor = config.colors.text ?? colorScheme.onSurface;
        overlayColor = Colors.transparent;
        break;
      case ButtonVariant.light:
        backgroundColor =
            config.colors.background ?? colorScheme.surfaceContainerHighest;
        foregroundColor = config.colors.text ?? colorScheme.onSurfaceVariant;
        overlayColor = colorScheme.onSurfaceVariant.withValues(alpha: 0.05);
        break;
      case ButtonVariant.ghost:
        backgroundColor = Colors.transparent;
        foregroundColor = config.colors.text ?? colorScheme.primary;
        overlayColor = colorScheme.primary.withValues(alpha: 0.05);
        break;
      case ButtonVariant.outlined:
        backgroundColor = Colors.transparent;
        foregroundColor = config.colors.text ?? colorScheme.primary;
        borderColor = config.colors.border ?? colorScheme.primary;
        overlayColor = colorScheme.primary.withValues(alpha: 0.05);
        break;
      case ButtonVariant.text:
        backgroundColor = Colors.transparent;
        foregroundColor = config.colors.text ?? colorScheme.primary;
        overlayColor = colorScheme.primary.withValues(alpha: 0.05);
        break;
    }

    if (config.disabled) {
      const double opacity = 0.5;
      backgroundColor =
          config.colors.disabled ?? backgroundColor.withValues(alpha: opacity);
      foregroundColor = config.colors.disabledText ??
          foregroundColor.withValues(alpha: opacity);
      if (borderColor != null) {
        borderColor = config.colors.disabledBorder ??
            borderColor.withValues(alpha: opacity);
      }
    }

    final backgroundColorProperty = WidgetStateProperty.resolveWith((states) {
      if (config.colors.gradient != null &&
          !states.contains(WidgetState.disabled)) {
        return Colors.transparent;
      }
      if (states.contains(WidgetState.disabled)) {
        return config.colors.disabled ??
            backgroundColor?.withValues(alpha: 0.5);
      }
      if (states.contains(WidgetState.pressed)) {
        return config.colors.pressed ?? _darkenColor(backgroundColor!, 0.1);
      }
      if (states.contains(WidgetState.hovered)) {
        return config.colors.hover ?? _lightenColor(backgroundColor!, 0.05);
      }
      if (states.contains(WidgetState.focused)) {
        return config.colors.focus ?? backgroundColor;
      }
      return backgroundColor;
    });

    final EdgeInsetsGeometry effectivePadding =
        config.layout.padding ?? _getPadding();
    final BorderRadius effectiveBorderRadius =
        config.layout.borderRadius ?? _getBorderRadius();

    BorderSide? borderSide;
    if (borderColor != null || config.variant == ButtonVariant.outlined) {
      borderSide = BorderSide(
        color: borderColor ?? colorScheme.primary,
        width: config.layout.borderWidth ?? 1.0,
        style: config.layout.borderStyle ?? BorderStyle.solid,
      );
    }

    final WidgetStateProperty<BorderSide?> side =
        WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.disabled) && borderSide != null) {
        return BorderSide(
          color: config.colors.disabledBorder ??
              borderSide.color.withValues(alpha: 0.5),
          width: borderSide.width,
          style: borderSide.style,
        );
      }
      return borderSide;
    });

    final WidgetStateProperty<Color?> overlayColorProperty =
        config.colors.overlayColor ??
            WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.pressed)) {
                return config.colors.splash ?? overlayColor;
              }
              if (states.contains(WidgetState.hovered)) {
                return Colors.transparent;
              }
              if (states.contains(WidgetState.focused)) {
                return overlayColor?.withValues(alpha: 0.2);
              }
              return Colors.transparent;
            });

    final WidgetStateProperty<double> elevationProperty =
        WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.disabled)) {
        return config.effects.disabledElevation ??
            config.effects.elevation ??
            0;
      }
      if (states.contains(WidgetState.pressed)) {
        return config.effects.pressedElevation ??
            (config.effects.elevation ?? 0) + 2;
      }
      if (states.contains(WidgetState.hovered)) {
        return config.effects.hoverElevation ??
            (config.effects.elevation ?? 0) + 1;
      }
      if (states.contains(WidgetState.focused)) {
        return config.effects.focusElevation ?? config.effects.elevation ?? 0;
      }
      return config.effects.elevation ?? 0;
    });

    final WidgetStateProperty<MouseCursor> mouseCursorProperty =
        WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.disabled)) {
        return SystemMouseCursors.forbidden;
      }
      return widget.mouseCursor ?? SystemMouseCursors.click;
    });

    return ButtonStyle(
      backgroundColor: backgroundColorProperty,
      foregroundColor: WidgetStateProperty.all(foregroundColor),
      overlayColor: overlayColorProperty,
      padding: WidgetStateProperty.all(effectivePadding),
      minimumSize: WidgetStateProperty.all(Size(config.layout.minWidth ?? 0,
          config.layout.minHeight ?? config.layout.height ?? 0)),
      maximumSize:
          config.layout.maxWidth != null || config.layout.maxHeight != null
              ? WidgetStateProperty.all(
                  Size(config.layout.maxWidth ?? double.infinity,
                      config.layout.maxHeight ?? double.infinity),
                )
              : null,
      fixedSize: config.layout.height != null
          ? WidgetStateProperty.all(Size.fromHeight(config.layout.height!))
          : null,
      shape: WidgetStateProperty.all(
          RoundedRectangleBorder(borderRadius: effectiveBorderRadius)),
      side: side,
      elevation: elevationProperty,
      shadowColor: WidgetStateProperty.all(
          config.effects.shadowColor ?? theme.shadowColor),
      tapTargetSize: config.layout.tapTargetSize ?? theme.materialTapTargetSize,
      visualDensity: config.layout.visualDensity,
      enableFeedback: config.effects.enableFeedback,
      mouseCursor: mouseCursorProperty,
      animationDuration: config.effects.animationDuration,
    );
  }

  EdgeInsetsGeometry _getPadding() {
    final config = widget.styleConfig;
    double horizontal, vertical;
    switch (config.size) {
      case ButtonSize.extraSmall:
        horizontal = 10.0;
        vertical = 4.0;
        break;
      case ButtonSize.small:
        horizontal = 12.0;
        vertical = 6.0;
        break;
      case ButtonSize.normal:
        horizontal = 16.0;
        vertical = 8.0;
        break;
      case ButtonSize.large:
        horizontal = 20.0;
        vertical = 10.0;
        break;
      case ButtonSize.extraLarge:
        horizontal = 24.0;
        vertical = 12.0;
        break;
    }
    double horizontalMultiplier, verticalMultiplier;
    switch (config.density) {
      case ButtonDensity.compact:
        horizontalMultiplier = 0.75;
        verticalMultiplier = 0.75;
        break;
      case ButtonDensity.dense:
        horizontalMultiplier = 0.85;
        verticalMultiplier = 0.85;
        break;
      case ButtonDensity.normal:
        horizontalMultiplier = 1.0;
        verticalMultiplier = 1.0;
        break;
      case ButtonDensity.comfortable:
        horizontalMultiplier = 1.25;
        verticalMultiplier = 1.25;
        break;
      case ButtonDensity.icon:
        return EdgeInsets.all(config.iconOnly ? vertical : horizontal * 0.5);
      case ButtonDensity.iconComfortable:
        return EdgeInsets.all(
            config.iconOnly ? vertical * 1.5 : horizontal * 0.75);
    }
    horizontal *= horizontalMultiplier;
    vertical *= verticalMultiplier;
    if (config.iconOnly) return EdgeInsets.all(vertical);
    return EdgeInsets.symmetric(horizontal: horizontal, vertical: vertical);
  }

  BorderRadius _getBorderRadius() {
    final config = widget.styleConfig;
    switch (config.shape) {
      case ButtonShape.fullRounded:
        return BorderRadius.circular(100);
      case ButtonShape.rectangle:
        return BorderRadius.zero;
      case ButtonShape.roundedRectangle:
        return BorderRadius.circular(8.0);
      case ButtonShape.customRounded:
        return config.layout.borderRadius ?? BorderRadius.circular(8.0);
    }
  }

  Color _getContentColor(ThemeData theme) {
    final config = widget.styleConfig;
    if (config.disabled) {
      return config.colors.disabledText ??
          (config.colors.text ?? theme.colorScheme.onSurface)
              .withValues(alpha: 0.5);
    }
    switch (config.variant) {
      case ButtonVariant.primary:
        return config.colors.text ?? theme.colorScheme.onPrimary;
      case ButtonVariant.secondary:
        return config.colors.text ?? theme.colorScheme.onSecondary;
      case ButtonVariant.warning:
        return config.colors.text ?? Colors.black87;
      case ButtonVariant.neutral:
        return config.colors.text ?? theme.colorScheme.onSurface;
      case ButtonVariant.danger:
        return config.colors.text ?? theme.colorScheme.onError;
      case ButtonVariant.unstyled:
        return config.colors.text ?? theme.colorScheme.onSurface;
      case ButtonVariant.light:
        return config.colors.text ?? theme.colorScheme.onSurfaceVariant;
      case ButtonVariant.ghost:
      case ButtonVariant.outlined:
      case ButtonVariant.text:
        return config.colors.text ?? theme.colorScheme.primary;
    }
  }

  double _getDefaultIconSpacing() {
    final config = widget.styleConfig;
    double base;
    switch (config.size) {
      case ButtonSize.extraSmall:
        base = 4;
        break;
      case ButtonSize.small:
        base = 6;
        break;
      case ButtonSize.normal:
        base = 8;
        break;
      case ButtonSize.large:
        base = 10;
        break;
      case ButtonSize.extraLarge:
        base = 12;
        break;
    }
    switch (config.density) {
      case ButtonDensity.compact:
        return base * 0.75;
      case ButtonDensity.dense:
        return base * 0.85;
      case ButtonDensity.normal:
        return base;
      case ButtonDensity.comfortable:
        return base * 1.25;
      case ButtonDensity.icon:
      case ButtonDensity.iconComfortable:
        return base;
    }
  }

  double _getIconSize() {
    final config = widget.styleConfig;
    if (config.layout.iconSize != null) return config.layout.iconSize!;
    switch (config.size) {
      case ButtonSize.extraSmall:
        return 14;
      case ButtonSize.small:
        return 16;
      case ButtonSize.normal:
        return 18;
      case ButtonSize.large:
        return 20;
      case ButtonSize.extraLarge:
        return 24;
    }
  }

  Color _darkenColor(Color color, double amount) {
    assert(amount >= 0 && amount <= 1, 'Amount must be between 0 and 1');
    final hsl = HSLColor.fromColor(color);
    return hsl
        .withLightness((hsl.lightness - amount).clamp(0.0, 1.0))
        .toColor();
  }

  Color _lightenColor(Color color, double amount) {
    assert(amount >= 0 && amount <= 1, 'Amount must be between 0 and 1');
    final hsl = HSLColor.fromColor(color);
    return hsl
        .withLightness((hsl.lightness + amount).clamp(0.0, 1.0))
        .toColor();
  }
}
