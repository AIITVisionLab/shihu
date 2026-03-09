import 'package:flutter/material.dart';

/// 统一管理应用的 Material 3 主题设计令牌。
class AppTheme {
  /// 返回当前应用使用的浅色主题。
  static ThemeData light() {
    const seedColor = Color(0xFF2F6B54);
    final colorScheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: Brightness.light,
      surface: const Color(0xFFF4F1E8),
    );
    final textTheme = ThemeData(useMaterial3: true).textTheme.copyWith(
      displaySmall: const TextStyle(
        fontSize: 38,
        height: 1.08,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.8,
      ),
      headlineLarge: const TextStyle(
        fontSize: 34,
        height: 1.08,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.8,
      ),
      headlineMedium: const TextStyle(
        fontSize: 28,
        height: 1.14,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.5,
      ),
      titleLarge: const TextStyle(
        fontSize: 22,
        height: 1.2,
        fontWeight: FontWeight.w700,
      ),
      titleMedium: const TextStyle(
        fontSize: 17,
        height: 1.28,
        fontWeight: FontWeight.w700,
      ),
      bodyLarge: const TextStyle(fontSize: 15, height: 1.65),
      bodyMedium: const TextStyle(fontSize: 14, height: 1.6),
      labelLarge: const TextStyle(
        fontSize: 13,
        height: 1.2,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.1,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: textTheme,
      scaffoldBackgroundColor: const Color(0xFFF2EEE4),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: colorScheme.onSurface,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(
          fontSize: 23,
          fontWeight: FontWeight.w700,
          color: colorScheme.onSurface,
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white.withValues(alpha: 0.86),
        elevation: 0,
        margin: EdgeInsets.zero,
        surfaceTintColor: Colors.white,
        shadowColor: const Color(0x1B1F3A22),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
          side: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.42),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.92),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 18,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.64),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.64),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: BorderSide(color: colorScheme.primary, width: 1.8),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF203426),
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: const Color(0xFFF4F6F1),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          // 只约束高度，避免桌面端在 Row/Wrap 中被推导成无限宽。
          minimumSize: const Size(0, 52),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          elevation: 0,
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          textStyle: textTheme.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          // 只约束高度，避免桌面端在 Row/Wrap 中被推导成无限宽。
          minimumSize: const Size(0, 52),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          foregroundColor: colorScheme.primary,
          side: BorderSide(color: colorScheme.outlineVariant),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          textStyle: textTheme.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.primary,
          textStyle: textTheme.labelLarge,
        ),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        side: BorderSide.none,
        selectedColor: colorScheme.primaryContainer,
      ),
    );
  }
}
