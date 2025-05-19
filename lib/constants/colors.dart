import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Base
  static const Color background = Color(0xFF252625);
  static const Color foreground = Color(0xFFF2E8DC);

  // Card & Popover
  static const Color card = Color(0xFF3A3B3A);
  static const Color cardForeground = Color(0xFFF2E8DC);

  // Primary (Teal)
  static const Color primary = Color(0xFF589EA6);
  static const Color primaryForeground = Color(0xFF06132D);
  static const Color primaryHover = Color(0xFF7AB8BF);
  static const Color primaryActive = Color(0xFF467E85);

  // Secondary (Dark Blue)
  static const Color secondary = Color(0xFF0C2659);
  static const Color secondaryForeground = Color(0xFFF2F0D8);

  // Muted (Brown)
  static const Color muted = Color(0xFF8C4D3F);
  static const Color mutedForeground = Color(0xFFD9AB91);

  // Accent (Orange)
  static const Color accent = Color(0xFFF28F38);
  static const Color accentForeground = Color(0xFF252625);
  static const Color accentHover = Color(0xFFF5A861);

  // Destructive (Deep Red)
  static const Color destructive = Color(0xFFD93D1A);
  static const Color destructiveForeground = Color(0xFFFAF5ED);
  static const Color destructiveHover = Color(0xFFE56B4D);

  // Border & Input
  static const Color border = Color(0xFF6E3C31);
  static const Color input = Color(0xFF6E3C31);
  static const Color inputForeground = Color(0xFFF2E8DC);
  static const Color ring = Color(0xFF7AB8BF);

  // Additional
  static const Color subtleBackground = Color(0xFF3A3B3A);
  static const Color subtleBorder = Color(0xFF8A8A8A);
  static const Color highlight = Color(0xFFF2F0D8);
  static const Color highlightForeground = Color(0xFF252625);

  static const Color success = Color(0xFF6A8C75);
  static const Color successForeground = Color(0xFFFAF5ED);

  static const Color warning = Color(0xFFD9674E);
  static const Color warningForeground = Color(0xFF252625);

  // Chart palette
  static const Color chart1 = Color(0xFFD9674E);
  static const Color chart2 = Color(0xFFD9AB91);
  static const Color chart3 = Color(0xFFF28F38);
  static const Color chart4 = Color(0xFF589EA6);
  static const Color chart5 = Color(0xFF0C2659);
  static const Color chart6 = Color(0xFF6A8C75);
  static const Color chart7 = Color(0xFFE6C7B8);

  // Orange swatch (example)
  static const MaterialColor orange = MaterialColor(
    0xFFE69138,
    <int, Color>{
      50: Color(0xFFFCF2E7),
      100: Color(0xFFF8DEC3),
      200: Color(0xFFF3C89C),
      300: Color(0xFFEEB274),
      400: Color(0xFFEAA256),
      500: Color(0xFFE69138),
      600: Color(0xFFE38932),
      700: Color(0xFFDF7E2B),
      800: Color(0xFFDB7424),
      900: Color(0xFFD56217),
    },
  );

  // Slate swatch
  static const MaterialColor slate = MaterialColor(
    0xFF475569,
    <int, Color>{
      50: Color(0xFFF8FAFC),
      100: Color(0xFFF1F5F9),
      200: Color(0xFFE2E8F0),
      300: Color(0xFFCBD5E1),
      400: Color(0xFF94A3B8),
      500: Color(0xFF64748B),
      600: Color(0xFF475569),
      700: Color(0xFF334155),
      800: Color(0xFF1E293B),
      900: Color(0xFF0F172A),
      950: Color(0xFF020617),
    },
  );

  // Neutral swatch
  static const MaterialColor neutral = MaterialColor(
    0xFFFAFAFA,
    <int, Color>{
      50: Color(0xFFFAFAFA),
      100: Color(0xFFF5F5F5),
      200: Color(0xFFE5E5E5),
      300: Color(0xFFD4D4D4),
      400: Color(0xFFA3A3A3),
      500: Color(0xFF737373),
      600: Color(0xFF525252),
      700: Color(0xFF404040),
      800: Color(0xFF262626),
      900: Color(0xFF171717),
      950: Color(0xFF0A0A0A),
    },
  );

  // Red swatch
  static const MaterialColor red = MaterialColor(
    0xFFDC2626,
    <int, Color>{
      50: Color(0xFFFEF2F2),
      100: Color(0xFFFEE2E2),
      200: Color(0xFFFECACA),
      300: Color(0xFFFCA5A5),
      400: Color(0xFFF87171),
      500: Color(0xFFEF4444),
      600: Color(0xFFDC2626),
      700: Color(0xFFB91C1C),
      800: Color(0xFF991B1B),
      900: Color(0xFF7F1D1D),
      950: Color(0xFF450A0A),
    },
  );

  // Green swatch
  static const MaterialColor green = MaterialColor(
    0xFF16A34A,
    <int, Color>{
      50: Color(0xFFF0FDF4),
      100: Color(0xFFDCFCE7),
      200: Color(0xFFBBF7D0),
      300: Color(0xFF86EFAC),
      400: Color(0xFF4ADE80),
      500: Color(0xFF22C55E),
      600: Color(0xFF16A34A),
      700: Color(0xFF15803D),
      800: Color(0xFF166534),
      900: Color(0xFF14532D),
      950: Color(0xFF052E16),
    },
  );

  // Blue swatch
  static const MaterialColor blue = MaterialColor(
    0xFF2563EB,
    <int, Color>{
      50: Color(0xFFEFF6FF),
      100: Color(0xFFDBEAFE),
      200: Color(0xFFBFDBFE),
      300: Color(0xFF93C5FD),
      400: Color(0xFF60A5FA),
      500: Color(0xFF3B82F6),
      600: Color(0xFF2563EB),
      700: Color(0xFF1D4ED8),
      800: Color(0xFF1E40AF),
      900: Color(0xFF1E3A8A),
      950: Color(0xFF172554),
    },
  );

  static final MaterialColor violet = MaterialColor(0xFF5B21B6, <int, Color>{
    50: Color(0xFFF5F3FF),
    100: Color(0xFFEDE9FE),
    200: Color(0xFFDDD6FE),
    300: Color(0xFFC4B5FD),
    400: Color(0xFFA78BFA),
    500: Color(0xFF8B5CF6),
    600: Color(0xFF7C3AED),
    700: Color(0xFF6D28D9),
    800: Color(0xFF5B21B6),
    900: Color(0xFF4C1D95),
    950: Color(0xFF1E1B4B),
  });

  // List swatches utama
  static final List<MaterialColor> primaries = [
    slate,
    neutral,
    red,
    orange,
    green,
    blue,
    violet
  ];
}
