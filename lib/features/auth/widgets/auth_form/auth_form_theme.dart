import 'package:flutter/material.dart';
import 'package:sickandflutter/app/app_palette.dart';

/// 构建认证表单专用主题。
ThemeData buildAuthFormTheme(ThemeData baseTheme) {
  final scheme = baseTheme.colorScheme.copyWith(
    primary: AppPalette.pineGreen,
    onPrimary: AppPalette.paperSnow,
    surface: AppPalette.paperSnow,
    onSurface: AppPalette.pineInk,
    onSurfaceVariant: const Color(0xFF66746A),
    surfaceContainerLowest: Color(0xFFFCFDF9),
    surfaceContainerLow: Color(0xFFF3F6F1),
    surfaceContainer: Color(0xFFEDEFEA),
    surfaceContainerHighest: Color(0xFFDDE4DB),
    primaryContainer: Color(0xFFDCE9DD),
    onPrimaryContainer: const Color(0xFF32503A),
    secondaryContainer: Color(0xFFE3EEE6),
    onSecondaryContainer: const Color(0xFF33483A),
    tertiaryContainer: Color(0xFFEEE5F0),
    onTertiaryContainer: const Color(0xFF5A4F62),
    outlineVariant: const Color(0xFFD5DCD3),
    errorContainer: const Color(0xFFF5E7E3),
    onErrorContainer: const Color(0xFF74443D),
  );

  return baseTheme.copyWith(
    colorScheme: scheme,
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppPalette.paperSnow,
      hintStyle: baseTheme.textTheme.bodyMedium?.copyWith(
        color: const Color(0xFF79857D),
      ),
      labelStyle: baseTheme.textTheme.bodyMedium?.copyWith(
        color: const Color(0xFF66746A),
        fontWeight: FontWeight.w700,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(22),
        borderSide: const BorderSide(color: Color(0xFFD5DCD3)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(22),
        borderSide: const BorderSide(color: Color(0xFFD5DCD3)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(22),
        borderSide: const BorderSide(color: AppPalette.softPine, width: 1.5),
      ),
      prefixIconColor: const Color(0xFF66746A),
      suffixIconColor: const Color(0xFF66746A),
    ),
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: ButtonStyle(
        padding: const WidgetStatePropertyAll(
          EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        ),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const Color(0xFFDCE9DD);
          }
          return AppPalette.paperSnow;
        }),
        foregroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const Color(0xFF32503A);
          }
          return const Color(0xFF66746A);
        }),
        side: const WidgetStatePropertyAll(
          BorderSide(color: Color(0x00000000)),
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: AppPalette.pineGreen),
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: const WidgetStatePropertyAll(AppPalette.pineGreen),
      side: const BorderSide(color: Color(0xFF9AA79A)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
    ),
  );
}
