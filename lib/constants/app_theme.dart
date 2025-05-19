import 'package:flutter/material.dart';
import 'colors.dart';
import 'typography.dart';

class AppThemeData {
  // --- Theme Configuration ---
  static final TextTheme _textTheme = AppTypography.poppins;
  static const double _defaultBorderRadius = 8.0;
  static const double _cardBorderRadius = 12.0;
  static const double _dialogBorderRadius = 16.0;

  // --- Color Definitions (Derived from AppColors) ---

  // Light Theme Colors
  static const Color _lightSurface = AppColors.foreground;
  static const Color _lightOnSurface = AppColors.background;
  static const Color _lightPrimary = AppColors.primary;
  static const Color _lightOnPrimary = AppColors.primaryForeground;
  static const Color _lightSecondary = AppColors.accent;
  static const Color _lightOnSecondary = AppColors.accentForeground;
  static const Color _lightTertiary = AppColors.secondary;
  static const Color _lightOnTertiary = AppColors.secondaryForeground;
  static const Color _lightError = AppColors.destructive;
  static const Color _lightOnError = AppColors.destructiveForeground;
  static const Color _lightOutline = AppColors.subtleBorder;
  static final Color _lightSurfaceContainerLowest = AppColors.neutral[50]!;
  static final Color _lightSurfaceContainerLow = AppColors.neutral[100]!;
  static final Color _lightSurfaceContainer = AppColors.neutral[100]!;
  static final Color _lightSurfaceContainerHigh = AppColors.neutral[200]!;
  static final Color _lightSurfaceContainerHighest = AppColors.neutral[300]!;
  static final Color _lightOnSurfaceVariant = AppColors.neutral[700]!;
  static final Color _lightInverseSurface =
      AppColors.background; // Dark surface
  static final Color _lightOnInverseSurface =
      AppColors.foreground; // Dark onSurface
  static final Color _lightShadow = AppColors.neutral[900]!;

  // Dark Theme Colors
  static const Color _darkSurface = AppColors.background;
  static const Color _darkOnSurface = AppColors.foreground;
  static const Color _darkPrimary = AppColors.primaryHover;
  static const Color _darkOnPrimary = AppColors.primaryForeground;
  static const Color _darkSecondary = AppColors.accentHover;
  static const Color _darkOnSecondary = AppColors.accentForeground;
  static final Color _darkTertiary = AppColors.secondary.withValues(alpha: 0.8);
  static final Color _darkOnTertiary = AppColors.secondaryForeground;
  static const Color _darkError = AppColors.destructiveHover;
  static const Color _darkOnError = AppColors.destructiveForeground;
  static const Color _darkOutline = AppColors.border;
  static final Color _darkSurfaceContainerLowest = AppColors.neutral[950]!;
  static final Color _darkSurfaceContainerLow = AppColors.neutral[900]!;
  static const Color _darkSurfaceContainer = AppColors.card; // Use card color
  static final Color _darkSurfaceContainerHigh = AppColors.neutral[800]!;
  static final Color _darkSurfaceContainerHighest = AppColors.neutral[700]!;
  static final Color _darkOnSurfaceVariant = AppColors.neutral[300]!;
  static final Color _darkInverseSurface =
      AppColors.foreground; // Light surface
  static final Color _darkOnInverseSurface =
      AppColors.background; // Light onSurface
  static final Color _darkShadow = AppColors.neutral[950]!;

  // --- Focus Colors ---
  static final Color _lightFocusColor = _lightPrimary.withValues(alpha: 0.3);
  static final Color _darkFocusColor = _darkPrimary.withValues(alpha: 0.3);

  // --- Public ThemeData Instances ---
  static final ThemeData lightThemeData =
      _createThemeData(_lightColorScheme, _lightFocusColor, _textTheme);
  static final ThemeData darkThemeData =
      _createThemeData(_darkColorScheme, _darkFocusColor, _textTheme);

  // --- Theme Data Factory ---
  static ThemeData _createThemeData(
      ColorScheme colorScheme, Color focusColor, TextTheme textTheme) {
    final isLight = colorScheme.brightness == Brightness.light;
    final outlineColor = colorScheme.outline;
    final surfaceContainerHigh =
        isLight ? _lightSurfaceContainerHigh : _darkSurfaceContainerHigh;
    final onSurfaceVariant = colorScheme.onSurfaceVariant;

    return ThemeData(
      colorScheme: colorScheme,
      textTheme: textTheme,
      primaryColor: colorScheme.primary,
      canvasColor: colorScheme.surface,
      scaffoldBackgroundColor: colorScheme.surface,
      highlightColor: Colors.transparent,
      focusColor: focusColor,
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        iconTheme: IconThemeData(color: colorScheme.onSurface),
        titleTextStyle:
            textTheme.titleLarge?.apply(color: colorScheme.onSurface),
      ),
      iconTheme: IconThemeData(color: colorScheme.onSurface),
      cardTheme: CardTheme(
        clipBehavior: Clip.antiAlias,
        elevation: 0,
        color: colorScheme.surfaceContainer,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_cardBorderRadius),
          side: BorderSide(
            color: outlineColor.withValues(alpha: 0.5),
            width: 1.0,
          ),
        ),
        margin: const EdgeInsets.symmetric(vertical: 4),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceContainerHigh,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_defaultBorderRadius),
          borderSide: BorderSide(color: outlineColor.withValues(alpha: 0.7)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_defaultBorderRadius),
          borderSide: BorderSide(color: outlineColor.withValues(alpha: 0.7)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_defaultBorderRadius),
          borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_defaultBorderRadius),
          borderSide: BorderSide(color: colorScheme.error, width: 1.0),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_defaultBorderRadius),
          borderSide: BorderSide(color: colorScheme.error, width: 1.5),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_defaultBorderRadius),
          borderSide: BorderSide(color: outlineColor.withValues(alpha: 0.3)),
        ),
        labelStyle: textTheme.bodyMedium?.apply(color: onSurfaceVariant),
        hintStyle: textTheme.bodyMedium
            ?.apply(color: onSurfaceVariant.withValues(alpha: 0.7)),
        errorStyle: textTheme.bodySmall?.apply(color: colorScheme.error),
        floatingLabelBehavior: FloatingLabelBehavior.auto,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          textStyle: textTheme.labelLarge
              ?.copyWith(fontWeight: AppTypography.semiBold),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_defaultBorderRadius),
          ),
          elevation: 1,
          shadowColor: colorScheme.shadow.withValues(alpha: 0.2),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.primary,
          textStyle: textTheme.labelLarge
              ?.copyWith(fontWeight: AppTypography.semiBold),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          side: BorderSide(color: outlineColor),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_defaultBorderRadius),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.primary,
          textStyle: textTheme.labelLarge
              ?.copyWith(fontWeight: AppTypography.semiBold),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_defaultBorderRadius),
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surfaceContainerHigh,
        disabledColor: outlineColor.withValues(alpha: 0.1),
        selectedColor: colorScheme.primaryContainer,
        secondarySelectedColor: colorScheme.secondaryContainer,
        labelStyle: textTheme.labelMedium?.apply(color: onSurfaceVariant),
        secondaryLabelStyle: textTheme.labelMedium
            ?.apply(color: colorScheme.onSecondaryContainer),
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
            side: BorderSide(color: outlineColor.withValues(alpha: 0.5))),
        iconTheme: IconThemeData(color: onSurfaceVariant, size: 18),
        brightness: colorScheme.brightness,
        elevation: 0,
        pressElevation: 0,
      ),
      dialogTheme: DialogTheme(
        backgroundColor: colorScheme.surfaceContainerHighest,
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_dialogBorderRadius),
          side: BorderSide(
            color: outlineColor.withValues(alpha: 0.3),
            width: 1.0,
          ),
        ),
        titleTextStyle:
            textTheme.titleLarge?.apply(color: colorScheme.onSurface),
        contentTextStyle: textTheme.bodyMedium?.apply(color: onSurfaceVariant),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colorScheme.surfaceContainer,
        modalBackgroundColor: colorScheme.surfaceContainer,
        elevation: 2,
        modalElevation: 2,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: colorScheme.inverseSurface, // Use inverse surface
        contentTextStyle: textTheme.bodyMedium?.apply(
            color: colorScheme.onInverseSurface // Use inverse text color
            ),
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_defaultBorderRadius),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: outlineColor.withValues(alpha: 0.5),
        thickness: 1,
        space: 1,
      ),
      tooltipTheme: TooltipThemeData(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        textStyle:
            textTheme.bodySmall?.apply(color: colorScheme.onInverseSurface),
        decoration: BoxDecoration(
          color: colorScheme.inverseSurface.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(4),
        ),
        waitDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  // --- Color Scheme Definitions ---
  static final ColorScheme _lightColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: _lightPrimary,
    onPrimary: _lightOnPrimary,
    primaryContainer: AppColors.primaryHover,
    onPrimaryContainer: AppColors.primaryForeground,
    secondary: _lightSecondary,
    onSecondary: _lightOnSecondary,
    secondaryContainer: AppColors.accentHover,
    onSecondaryContainer: AppColors.accentForeground,
    tertiary: _lightTertiary,
    onTertiary: _lightOnTertiary,
    tertiaryContainer: AppColors.secondary.withValues(alpha: 0.1),
    onTertiaryContainer: _lightTertiary,
    error: _lightError,
    onError: _lightOnError,
    errorContainer: AppColors.destructive.withValues(alpha: 0.1),
    onErrorContainer: _lightError,
    surface: _lightSurface,
    onSurface: _lightOnSurface,
    surfaceDim: AppColors.neutral[400]!,
    surfaceBright: _lightSurfaceContainerLow,
    surfaceContainerLowest: _lightSurfaceContainerLowest,
    surfaceContainerLow: _lightSurfaceContainerLow,
    surfaceContainer: _lightSurfaceContainer,
    surfaceContainerHigh: _lightSurfaceContainerHigh,
    surfaceContainerHighest: _lightSurfaceContainerHighest,
    onSurfaceVariant: _lightOnSurfaceVariant,
    outline: _lightOutline,
    outlineVariant: AppColors.neutral[300]!,
    shadow: _lightShadow,
    scrim: AppColors.neutral[950]!.withValues(alpha: 0.2),
    inverseSurface: _lightInverseSurface,
    onInverseSurface: _lightOnInverseSurface,
    inversePrimary: _darkPrimary,
    surfaceTint: _lightPrimary,
  );

  static final ColorScheme _darkColorScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: _darkPrimary,
    onPrimary: _darkOnPrimary,
    primaryContainer: AppColors.primaryActive,
    onPrimaryContainer: AppColors.foreground,
    secondary: _darkSecondary,
    onSecondary: _darkOnSecondary,
    secondaryContainer: AppColors.accent,
    onSecondaryContainer: AppColors.accentForeground,
    tertiary: _darkTertiary,
    onTertiary: _darkOnTertiary,
    tertiaryContainer: AppColors.secondary.withValues(alpha: 0.1),
    onTertiaryContainer: _darkOnTertiary,
    error: _darkError,
    onError: _darkOnError,
    errorContainer: AppColors.destructiveHover.withValues(alpha: 0.1),
    onErrorContainer: _darkError,
    surface: _darkSurface,
    onSurface: _darkOnSurface,
    surfaceDim: AppColors.neutral[800]!,
    surfaceBright: _darkSurfaceContainerHigh,
    surfaceContainerLowest: _darkSurfaceContainerLowest,
    surfaceContainerLow: _darkSurfaceContainerLow,
    surfaceContainer: _darkSurfaceContainer,
    surfaceContainerHigh: _darkSurfaceContainerHigh,
    surfaceContainerHighest: _darkSurfaceContainerHighest,
    onSurfaceVariant: _darkOnSurfaceVariant,
    outline: _darkOutline,
    outlineVariant: AppColors.neutral[700]!,
    shadow: _darkShadow,
    scrim: AppColors.neutral[950]!.withValues(alpha: 0.3),
    inverseSurface: _darkInverseSurface,
    onInverseSurface: _darkOnInverseSurface,
    inversePrimary: _lightPrimary,
    surfaceTint: _darkPrimary,
  );
}
