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
  /// 返回当前应用使用的主题。
  static ThemeData light() {
    const colorScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xFF64BCFF),
      onPrimary: Color(0xFF021224),
      secondary: Color(0xFF9CD9FF),
      onSecondary: Color(0xFF03172A),
      error: Color(0xFFF59A92),
      onError: Color(0xFF461613),
      surface: Color(0xFF030814),
      onSurface: Color(0xFFE9F6FF),
      onSurfaceVariant: Color(0xFF93ACC9),
      primaryContainer: Color(0xFF0C2442),
      onPrimaryContainer: Color(0xFFD9EEFF),
      secondaryContainer: Color(0xFF0D1F36),
      onSecondaryContainer: Color(0xFFD8ECFF),
      tertiary: Color(0xFF62EFFF),
      onTertiary: Color(0xFF022230),
      tertiaryContainer: Color(0xFF0B293A),
      onTertiaryContainer: Color(0xFFD4FAFF),
      errorContainer: Color(0xFF43201F),
      onErrorContainer: Color(0xFFFFDAD6),
      surfaceDim: Color(0xFF040913),
      surfaceBright: Color(0xFF15233A),
      surfaceContainerLowest: Color(0xFF08111F),
      surfaceContainerLow: Color(0xFF0B1627),
      surfaceContainer: Color(0xFF0F1B2D),
      surfaceContainerHigh: Color(0xFF132133),
      surfaceContainerHighest: Color(0xFF18283D),
      outline: Color(0xFF476A8D),
      outlineVariant: Color(0xFF1B314A),
      shadow: Color(0xFF000000),
      scrim: Color(0xFF000000),
      inverseSurface: Color(0xFFE9F6FF),
      onInverseSurface: Color(0xFF0F1925),
      inversePrimary: Color(0xFF92CAFF),
    );

    final baseTextTheme = Typography.material2021(
      platform: defaultTargetPlatform,
    ).white;
    final textTheme = baseTextTheme.copyWith(
      displaySmall: _displayStyle(
        size: 36,
        height: 1.04,
        weight: FontWeight.w800,
        letterSpacing: -0.7,
      ),
      headlineLarge: _displayStyle(
        size: 30,
        height: 1.08,
        weight: FontWeight.w800,
        letterSpacing: -0.4,
      ),
      headlineMedium: _displayStyle(
        size: 26,
        height: 1.12,
        weight: FontWeight.w800,
        letterSpacing: -0.2,
      ),
      headlineSmall: _displayStyle(
        size: 22,
        height: 1.16,
        weight: FontWeight.w800,
      ),
      titleLarge: _displayStyle(
        size: 19,
        height: 1.22,
        weight: FontWeight.w800,
      ),
      titleMedium: _bodyStyle(
        size: 15.5,
        height: 1.34,
        weight: FontWeight.w700,
      ),
      titleSmall: _bodyStyle(size: 13.5, height: 1.3, weight: FontWeight.w700),
      bodyLarge: _bodyStyle(size: 14.5, height: 1.58),
      bodyMedium: _bodyStyle(size: 13.5, height: 1.52),
      bodySmall: _bodyStyle(size: 12, height: 1.44),
      labelLarge: _bodyStyle(
        size: 13,
        height: 1.18,
        weight: FontWeight.w700,
        letterSpacing: 0.18,
      ),
      labelMedium: _bodyStyle(
        size: 12,
        height: 1.16,
        weight: FontWeight.w700,
        letterSpacing: 0.16,
      ),
      labelSmall: _bodyStyle(
        size: 11,
        height: 1.14,
        weight: FontWeight.w700,
        letterSpacing: 0.18,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: _bodyFontFamily,
      colorScheme: colorScheme,
      textTheme: textTheme,
      scaffoldBackgroundColor: colorScheme.surface,
      canvasColor: colorScheme.surface,
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: <TargetPlatform, PageTransitionsBuilder>{
          TargetPlatform.android: _InstantPageTransitionsBuilder(),
          TargetPlatform.iOS: _InstantPageTransitionsBuilder(),
          TargetPlatform.macOS: _InstantPageTransitionsBuilder(),
          TargetPlatform.windows: _InstantPageTransitionsBuilder(),
          TargetPlatform.linux: _InstantPageTransitionsBuilder(),
          TargetPlatform.fuchsia: _InstantPageTransitionsBuilder(),
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
        shadowColor: const Color(0x66000000),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.9),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainer,
        hintStyle: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
        labelStyle: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w700,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
        ),
        prefixIconColor: colorScheme.onSurfaceVariant,
        suffixIconColor: colorScheme.onSurfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: colorScheme.primary, width: 1.4),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF0E171F),
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurface,
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
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: textTheme.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, 48),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          foregroundColor: colorScheme.onSurface,
          side: BorderSide(color: colorScheme.outlineVariant),
          backgroundColor: colorScheme.surfaceContainerLow.withValues(
            alpha: 0.55,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: textTheme.labelLarge,
        ),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return colorScheme.primaryContainer;
            }
            return colorScheme.surfaceContainerLow;
          }),
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return colorScheme.onPrimaryContainer;
            }
            return colorScheme.onSurfaceVariant;
          }),
          side: WidgetStatePropertyAll(
            BorderSide(color: colorScheme.outlineVariant),
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
        backgroundColor: colorScheme.surfaceContainerLowest,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        height: 72,
        indicatorColor: colorScheme.primaryContainer,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final isSelected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: isSelected
                ? colorScheme.onPrimaryContainer
                : colorScheme.onSurfaceVariant,
          );
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final isSelected = states.contains(WidgetState.selected);
          return textTheme.labelMedium?.copyWith(
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            color: isSelected
                ? colorScheme.onPrimaryContainer
                : colorScheme.onSurfaceVariant,
          );
        }),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: Colors.transparent,
        useIndicator: true,
        indicatorColor: colorScheme.primaryContainer,
        selectedIconTheme: IconThemeData(color: colorScheme.onPrimaryContainer),
        unselectedIconTheme: IconThemeData(color: colorScheme.onSurfaceVariant),
        selectedLabelTextStyle: textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.w800,
          color: colorScheme.onPrimaryContainer,
        ),
        unselectedLabelTextStyle: textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurfaceVariant,
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: colorScheme.surfaceContainer,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        backgroundColor: colorScheme.surfaceContainerHigh,
        side: BorderSide.none,
        selectedColor: colorScheme.primaryContainer,
        labelStyle: textTheme.labelLarge?.copyWith(
          color: colorScheme.onSurface,
        ),
      ),
      listTileTheme: ListTileThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant,
        thickness: 1,
        space: 1,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: colorScheme.primary,
        linearTrackColor: colorScheme.surfaceContainerHighest,
        circularTrackColor: colorScheme.surfaceContainerHighest,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.primary;
          }
          return colorScheme.onSurfaceVariant;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.primaryContainer;
          }
          return colorScheme.surfaceContainerHighest;
        }),
      ),
    );
  }
}

class _InstantPageTransitionsBuilder extends PageTransitionsBuilder {
  const _InstantPageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return child;
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
