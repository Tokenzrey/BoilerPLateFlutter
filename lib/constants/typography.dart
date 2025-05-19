import 'package:boilerplate/constants/font_family.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTypography {
  AppTypography._();

  // --- Skala Font Weight Umum ---
  static const FontWeight thin = FontWeight.w100;
  static const FontWeight extraLight = FontWeight.w200;
  static const FontWeight light = FontWeight.w300;
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semiBold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;
  static const FontWeight extraBold = FontWeight.w800;
  static const FontWeight black = FontWeight.w900;

  // --- Skala Ukuran Font Umum (Bisa disesuaikan) ---
  // Display
  static const double _displayLargeSize = 57.0;
  static const double _displayMediumSize = 45.0;
  static const double _displaySmallSize = 36.0;
  // Headline
  static const double _headlineLargeSize = 32.0;
  static const double _headlineMediumSize = 28.0;
  static const double _headlineSmallSize = 24.0;
  // Title
  static const double _titleLargeSize = 22.0;
  static const double _titleMediumSize = 16.0;
  static const double _titleSmallSize = 14.0;
  // Body
  static const double _bodyLargeSize = 16.0;
  static const double _bodyMediumSize = 14.0;
  static const double _bodySmallSize = 12.0;
  // Label
  static const double _labelLargeSize = 14.0;
  static const double _labelMediumSize = 12.0;
  static const double _labelSmallSize = 11.0;

  static final TextTheme poppins = TextTheme(
    // Display
    displayLarge:
        GoogleFonts.poppins(fontWeight: regular, fontSize: _displayLargeSize),
    displayMedium:
        GoogleFonts.poppins(fontWeight: regular, fontSize: _displayMediumSize),
    displaySmall:
        GoogleFonts.poppins(fontWeight: regular, fontSize: _displaySmallSize),
    // Headline
    headlineLarge:
        GoogleFonts.poppins(fontWeight: bold, fontSize: _headlineLargeSize),
    headlineMedium:
        GoogleFonts.poppins(fontWeight: bold, fontSize: _headlineMediumSize),
    headlineSmall:
        GoogleFonts.poppins(fontWeight: bold, fontSize: _headlineSmallSize),
    // Title
    titleLarge:
        GoogleFonts.poppins(fontWeight: semiBold, fontSize: _titleLargeSize),
    titleMedium:
        GoogleFonts.poppins(fontWeight: semiBold, fontSize: _titleMediumSize),
    titleSmall:
        GoogleFonts.poppins(fontWeight: medium, fontSize: _titleSmallSize),
    // Body
    bodyLarge:
        GoogleFonts.poppins(fontWeight: regular, fontSize: _bodyLargeSize),
    bodyMedium:
        GoogleFonts.poppins(fontWeight: regular, fontSize: _bodyMediumSize),
    bodySmall:
        GoogleFonts.poppins(fontWeight: regular, fontSize: _bodySmallSize),
    // Label
    labelLarge:
        GoogleFonts.poppins(fontWeight: medium, fontSize: _labelLargeSize),
    labelMedium:
        GoogleFonts.poppins(fontWeight: medium, fontSize: _labelMediumSize),
    labelSmall:
        GoogleFonts.poppins(fontWeight: medium, fontSize: _labelSmallSize),
  );

  static final TextTheme roboto = TextTheme(
    // Display
    displayLarge:
        GoogleFonts.roboto(fontWeight: regular, fontSize: _displayLargeSize),
    displayMedium:
        GoogleFonts.roboto(fontWeight: regular, fontSize: _displayMediumSize),
    displaySmall:
        GoogleFonts.roboto(fontWeight: regular, fontSize: _displaySmallSize),
    // Headline
    headlineLarge:
        GoogleFonts.roboto(fontWeight: bold, fontSize: _headlineLargeSize),
    headlineMedium:
        GoogleFonts.roboto(fontWeight: bold, fontSize: _headlineMediumSize),
    headlineSmall:
        GoogleFonts.roboto(fontWeight: bold, fontSize: _headlineSmallSize),
    // Title
    titleLarge:
        GoogleFonts.roboto(fontWeight: semiBold, fontSize: _titleLargeSize),
    titleMedium:
        GoogleFonts.roboto(fontWeight: semiBold, fontSize: _titleMediumSize),
    titleSmall:
        GoogleFonts.roboto(fontWeight: medium, fontSize: _titleSmallSize),
    // Body
    bodyLarge:
        GoogleFonts.roboto(fontWeight: regular, fontSize: _bodyLargeSize),
    bodyMedium:
        GoogleFonts.roboto(fontWeight: regular, fontSize: _bodyMediumSize),
    bodySmall:
        GoogleFonts.roboto(fontWeight: regular, fontSize: _bodySmallSize),
    // Label
    labelLarge:
        GoogleFonts.roboto(fontWeight: medium, fontSize: _labelLargeSize),
    labelMedium:
        GoogleFonts.roboto(fontWeight: medium, fontSize: _labelMediumSize),
    labelSmall:
        GoogleFonts.roboto(fontWeight: medium, fontSize: _labelSmallSize),
  );

  static final TextTheme helvetica = TextTheme(
    // Display
    displayLarge: TextStyle(
        fontFamily: FontFamily.helvetica,
        fontWeight: regular,
        fontSize: _displayLargeSize),
    displayMedium: TextStyle(
        fontFamily: FontFamily.helvetica,
        fontWeight: regular,
        fontSize: _displayMediumSize),
    displaySmall: TextStyle(
        fontFamily: FontFamily.helvetica,
        fontWeight: regular,
        fontSize: _displaySmallSize),
    // Headline
    headlineLarge: TextStyle(
        fontFamily: FontFamily.helvetica,
        fontWeight: bold,
        fontSize: _headlineLargeSize),
    headlineMedium: TextStyle(
        fontFamily: FontFamily.helvetica,
        fontWeight: bold,
        fontSize: _headlineMediumSize),
    headlineSmall: TextStyle(
        fontFamily: FontFamily.helvetica,
        fontWeight: bold,
        fontSize: _headlineSmallSize),
    // Title
    titleLarge: TextStyle(
        fontFamily: FontFamily.helvetica,
        fontWeight: semiBold,
        fontSize: _titleLargeSize),
    titleMedium: TextStyle(
        fontFamily: FontFamily.helvetica,
        fontWeight: semiBold,
        fontSize: _titleMediumSize),
    titleSmall: TextStyle(
        fontFamily: FontFamily.helvetica,
        fontWeight: medium,
        fontSize: _titleSmallSize),
    // Body
    bodyLarge: TextStyle(
        fontFamily: FontFamily.helvetica,
        fontWeight: regular,
        fontSize: _bodyLargeSize),
    bodyMedium: TextStyle(
        fontFamily: FontFamily.helvetica,
        fontWeight: regular,
        fontSize: _bodyMediumSize),
    bodySmall: TextStyle(
        fontFamily: FontFamily.helvetica,
        fontWeight: regular,
        fontSize: _bodySmallSize),
    // Label
    labelLarge: TextStyle(
        fontFamily: FontFamily.helvetica,
        fontWeight: medium,
        fontSize: _labelLargeSize),
    labelMedium: TextStyle(
        fontFamily: FontFamily.helvetica,
        fontWeight: medium,
        fontSize: _labelMediumSize),
    labelSmall: TextStyle(
        fontFamily: FontFamily.helvetica,
        fontWeight: medium,
        fontSize: _labelSmallSize),
  );
}
