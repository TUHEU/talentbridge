// lib/core/theme/app_theme.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_colors.dart';

class AppTheme {
  AppTheme._();

  // ── Shared input decoration ──────────────────────────────
  static InputDecorationTheme _inputTheme(bool dark) => InputDecorationTheme(
    filled: true,
    fillColor: dark ? AppColors.darkCard : AppColors.grey100,
    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(
          color: dark ? AppColors.darkBorder : AppColors.grey200, width: 1)),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: AppColors.primary, width: 2)),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: AppColors.error, width: 1)),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: AppColors.error, width: 2)),
    labelStyle: TextStyle(
        color: dark ? AppColors.grey400 : AppColors.grey500,
        fontFamily: 'Inter'),
    hintStyle: TextStyle(
        color: dark ? AppColors.grey500 : AppColors.grey400,
        fontFamily: 'Inter'),
    prefixIconColor: dark ? AppColors.grey400 : AppColors.grey500,
    suffixIconColor: dark ? AppColors.grey400 : AppColors.grey500,
  );

  static ElevatedButtonThemeData get _elevatedBtn => ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.white,
      elevation: 0,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14)),
      textStyle: const TextStyle(
          fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.w700),
    ),
  );

  static OutlinedButtonThemeData get _outlinedBtn => OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: AppColors.primary,
      side: const BorderSide(color: AppColors.primary, width: 1.5),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14)),
      textStyle: const TextStyle(
          fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.w700),
    ),
  );

  static const TextTheme _textTheme = TextTheme(
    displayLarge:  TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w800, fontSize: 36, letterSpacing: -1.0),
    displayMedium: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w700, fontSize: 28, letterSpacing: -0.5),
    displaySmall:  TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w700, fontSize: 24),
    headlineLarge: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w700, fontSize: 22),
    headlineMedium:TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600, fontSize: 20),
    headlineSmall: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600, fontSize: 18),
    titleLarge:    TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600, fontSize: 16),
    titleMedium:   TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w500, fontSize: 14),
    titleSmall:    TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w500, fontSize: 12),
    bodyLarge:     TextStyle(fontFamily: 'Inter', fontSize: 16, height: 1.6),
    bodyMedium:    TextStyle(fontFamily: 'Inter', fontSize: 14, height: 1.55),
    bodySmall:     TextStyle(fontFamily: 'Inter', fontSize: 12, height: 1.45),
    labelLarge:    TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600, fontSize: 14),
    labelMedium:   TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w500, fontSize: 12),
    labelSmall:    TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w500, fontSize: 11),
  );

  // ── LIGHT THEME ───────────────────────────────────────────
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    fontFamily: 'Inter',
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
      primary:   AppColors.primary,
      secondary: AppColors.secondary,
      tertiary:  AppColors.accent,
      surface:   AppColors.white,
      error:     AppColors.error,
    ),
    scaffoldBackgroundColor: AppColors.bg,
    appBarTheme: const AppBarTheme(
      elevation: 0,
      centerTitle: true,
      backgroundColor: Colors.transparent,
      foregroundColor: AppColors.white,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      titleTextStyle: TextStyle(
          fontFamily: 'Inter', fontSize: 18,
          fontWeight: FontWeight.w700, color: AppColors.white),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: AppColors.white,
      surfaceTintColor: Colors.transparent,
    ),
    inputDecorationTheme: _inputTheme(false),
    elevatedButtonTheme:  _elevatedBtn,
    outlinedButtonTheme:  _outlinedBtn,
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        textStyle: const TextStyle(
            fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w600),
      ),
    ),
    textTheme: _textTheme,
    dividerTheme: const DividerThemeData(color: AppColors.grey100, thickness: 1),
    chipTheme: ChipThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      labelStyle: const TextStyle(
          fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.w500),
      side: const BorderSide(color: AppColors.grey200),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      contentTextStyle: const TextStyle(fontFamily: 'Inter', fontSize: 14),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.white,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.grey400,
      showSelectedLabels: false,
      showUnselectedLabels: false,
      type: BottomNavigationBarType.fixed,
    ),
    listTileTheme: const ListTileThemeData(
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    ),
  );

  // ── DARK THEME ────────────────────────────────────────────
  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    fontFamily: 'Inter',
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.dark,
      primary:   AppColors.primary,
      secondary: AppColors.secondary,
      tertiary:  AppColors.accent,
      surface:   AppColors.darkSurface,
      error:     AppColors.error,
      onSurface: AppColors.darkText,
    ),
    scaffoldBackgroundColor: AppColors.darkBg,
    appBarTheme: const AppBarTheme(
      elevation: 0,
      centerTitle: true,
      backgroundColor: Colors.transparent,
      foregroundColor: AppColors.white,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      titleTextStyle: TextStyle(
          fontFamily: 'Inter', fontSize: 18,
          fontWeight: FontWeight.w700, color: AppColors.white),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: AppColors.darkCard,
      surfaceTintColor: Colors.transparent,
    ),
    inputDecorationTheme: _inputTheme(true),
    elevatedButtonTheme:  _elevatedBtn,
    outlinedButtonTheme:  _outlinedBtn,
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        textStyle: const TextStyle(
            fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w600),
      ),
    ),
    textTheme: _textTheme.apply(
      bodyColor: AppColors.darkText,
      displayColor: AppColors.white,
    ),
    dividerTheme: const DividerThemeData(color: AppColors.darkBorder, thickness: 1),
    chipTheme: ChipThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      labelStyle: const TextStyle(
          fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.w500),
      side: const BorderSide(color: AppColors.darkBorder),
      backgroundColor: AppColors.darkCard2,
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: AppColors.darkCard,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      contentTextStyle: const TextStyle(
          fontFamily: 'Inter', fontSize: 14, color: AppColors.white),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.darkSurface,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.grey500,
      showSelectedLabels: false,
      showUnselectedLabels: false,
      type: BottomNavigationBarType.fixed,
    ),
    listTileTheme: const ListTileThemeData(
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      textColor: AppColors.darkText,
      iconColor: AppColors.grey400,
    ),
  );
}
