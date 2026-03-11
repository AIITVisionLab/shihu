import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

const String _bodyFontFamily = 'Noto Sans SC';
const List<String> _bodyFontFallback = <String>[
  'PingFang SC',
  'Microsoft YaHei',
  'Source Han Sans SC',
  'sans-serif',
];
const String _displayFontFamily = 'Noto Sans SC';
const List<String> _displayFontFallback = _bodyFontFallback;

/// 统一管理应用的 Material 3 主题设计令牌。
class AppTheme {
  /// 返回当前应用使用的浅色主题。
  static ThemeData light() {
    const seedColor = Color(0xFF1F857B);
    final colorScheme =
        ColorScheme.fromSeed(
          seedColor: seedColor,
          brightness: Brightness.light,
          surface: const Color(0xFFF4F2EC),
        ).copyWith(
          primary: const Color(0xFF1F857B),
          onPrimary: const Color(0xFFFFFFFF),
          primaryContainer: const Color(0xFFD4EFE8),
          onPrimaryContainer: const Color(0xFF083D38),
          secondary: const Color(0xFFA36E48),
          onSecondary: const Color(0xFFFFFFFF),
          secondaryContainer: const Color(0xFFF4E2D3),
          onSecondaryContainer: const Color(0xFF442616),
          tertiary: const Color(0xFF5A7F93),
          onTertiary: const Color(0xFFFFFFFF),
          tertiaryContainer: const Color(0xFFDCE9F2),
          onTertiaryContainer: const Color(0xFF17313F),
          error: const Color(0xFFBA4B42),
          onError: const Color(0xFFFFFFFF),
          errorContainer: const Color(0xFFF8DDD8),
          onErrorContainer: const Color(0xFF4A1712),
          surface: const Color(0xFFF4F2EC),
          surfaceContainerLowest: const Color(0xFFFFFFFF),
          surfaceContainerLow: const Color(0xFFF2EEE4),
          surfaceContainer: const Color(0xFFECE7DA),
          surfaceContainerHigh: const Color(0xFFE5DDCF),
          surfaceContainerHighest: const Color(0xFFD8D0C3),
          outline: const Color(0xFF756F67),
          outlineVariant: const Color(0xFFD0C6B7),
        );

    final baseTextTheme = Typography.material2021(
      platform: defaultTargetPlatform,
    ).black;
    final textTheme = baseTextTheme.copyWith(
      displaySmall: _displayStyle(
        size: 36,
        height: 1.08,
        weight: FontWeight.w800,
        letterSpacing: -0.6,
      ),
      headlineLarge: _displayStyle(
        size: 30,
        height: 1.12,
        weight: FontWeight.w800,
        letterSpacing: -0.3,
      ),
      headlineMedium: _displayStyle(
        size: 26,
        height: 1.16,
        weight: FontWeight.w800,
        letterSpacing: -0.2,
      ),
      headlineSmall: _displayStyle(
        size: 22,
        height: 1.22,
        weight: FontWeight.w800,
      ),
      titleLarge: _displayStyle(
        size: 19,
        height: 1.24,
        weight: FontWeight.w800,
      ),
      titleMedium: _bodyStyle(
        size: 15.5,
        height: 1.34,
        weight: FontWeight.w700,
      ),
      titleSmall: _bodyStyle(size: 13.5, height: 1.3, weight: FontWeight.w700),
      bodyLarge: _bodyStyle(size: 14.5, height: 1.62),
      bodyMedium: _bodyStyle(size: 13.5, height: 1.56),
      bodySmall: _bodyStyle(size: 12, height: 1.46),
      labelLarge: _bodyStyle(
        size: 13,
        height: 1.2,
        weight: FontWeight.w700,
        letterSpacing: 0.18,
      ),
      labelMedium: _bodyStyle(
        size: 12,
        height: 1.2,
        weight: FontWeight.w700,
        letterSpacing: 0.16,
      ),
      labelSmall: _bodyStyle(
        size: 11,
        height: 1.18,
        weight: FontWeight.w700,
        letterSpacing: 0.2,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      fontFamily: _bodyFontFamily,
      colorScheme: colorScheme,
      textTheme: textTheme,
      scaffoldBackgroundColor: colorScheme.surface,
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: <TargetPlatform, PageTransitionsBuilder>{
          TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.macOS: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.windows: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.linux: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.fuchsia: FadeForwardsPageTransitionsBuilder(),
        },
      ),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: colorScheme.onSurface,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(
          fontFamily: _displayFontFamily,
          fontFamilyFallback: _displayFontFallback,
          fontSize: 22,
          fontWeight: FontWeight.w800,
          color: colorScheme.onSurface,
        ),
      ),
      cardTheme: CardThemeData(
        color: colorScheme.surfaceContainerLow,
        elevation: 0,
        margin: EdgeInsets.zero,
        surfaceTintColor: Colors.transparent,
        shadowColor: const Color(0x12000000),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.32),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerLowest.withValues(alpha: 0.88),
        hintStyle: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurfaceVariant.withValues(alpha: 0.78),
        ),
        labelStyle: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w700,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.56),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.56),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: colorScheme.primary, width: 1.6),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF133E3A),
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: const Color(0xFFF8F6F2),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, 48),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          elevation: 0,
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          textStyle: textTheme.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, 48),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          foregroundColor: colorScheme.primary,
          side: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.88),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          textStyle: textTheme.labelLarge,
        ),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return colorScheme.primaryContainer;
            }
            return colorScheme.surfaceContainerLowest;
          }),
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return colorScheme.onPrimaryContainer;
            }
            return colorScheme.onSurface;
          }),
          side: WidgetStatePropertyAll(
            BorderSide(
              color: colorScheme.outlineVariant.withValues(alpha: 0.72),
            ),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.primary,
          textStyle: textTheme.labelLarge,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colorScheme.surfaceContainerLowest.withValues(
          alpha: 0.96,
        ),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        height: 74,
        indicatorColor: colorScheme.primaryContainer,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final isSelected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: isSelected
                ? colorScheme.primary
                : colorScheme.onSurfaceVariant,
          );
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final isSelected = states.contains(WidgetState.selected);
          return textTheme.labelMedium?.copyWith(
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            color: isSelected
                ? colorScheme.primary
                : colorScheme.onSurfaceVariant,
          );
        }),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: Colors.transparent,
        useIndicator: true,
        indicatorColor: colorScheme.primaryContainer,
        selectedIconTheme: IconThemeData(color: colorScheme.primary),
        unselectedIconTheme: IconThemeData(color: colorScheme.onSurfaceVariant),
        selectedLabelTextStyle: textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.w800,
          color: colorScheme.primary,
        ),
        unselectedLabelTextStyle: textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurfaceVariant,
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        backgroundColor: colorScheme.surfaceContainerLow,
        side: BorderSide.none,
        selectedColor: colorScheme.primaryContainer,
      ),
      listTileTheme: ListTileThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant.withValues(alpha: 0.48),
        thickness: 1,
        space: 1,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: colorScheme.primary,
        linearTrackColor: colorScheme.surfaceContainerHighest,
        circularTrackColor: colorScheme.surfaceContainerHighest,
      ),
    );
  }
}

TextStyle _displayStyle({
  required double size,
  required double height,
  required FontWeight weight,
  double? letterSpacing,
}) {
  return TextStyle(
    fontFamily: _displayFontFamily,
    fontFamilyFallback: _displayFontFallback,
    fontSize: size,
    height: height,
    fontWeight: weight,
    letterSpacing: letterSpacing,
  );
}

TextStyle _bodyStyle({
  required double size,
  required double height,
  FontWeight weight = FontWeight.w500,
  double? letterSpacing,
}) {
  return TextStyle(
    fontFamily: _bodyFontFamily,
    fontFamilyFallback: _bodyFontFallback,
    fontSize: size,
    height: height,
    fontWeight: weight,
    letterSpacing: letterSpacing,
  );
}
