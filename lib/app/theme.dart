import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sickandflutter/app/app_palette.dart';

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
      brightness: Brightness.light,
      primary: AppPalette.pineGreen,
      onPrimary: AppPalette.paperSnow,
      secondary: AppPalette.softPine,
      onSecondary: AppPalette.deepPine,
      error: Color(0xFFB7776C),
      onError: Color(0xFFFEF7F5),
      surface: AppPalette.paperSnow,
      onSurface: AppPalette.pineInk,
      onSurfaceVariant: Color(0xFF6E675C),
      primaryContainer: Color(0xFFD9E4D8),
      onPrimaryContainer: Color(0xFF32503A),
      secondaryContainer: Color(0xFFE5E8DC),
      onSecondaryContainer: Color(0xFF33483A),
      tertiary: AppPalette.softLavender,
      onTertiary: Color(0xFF473F4D),
      tertiaryContainer: Color(0xFFEEE6E8),
      onTertiaryContainer: Color(0xFF5A4F62),
      errorContainer: Color(0xFFF5E7E3),
      onErrorContainer: Color(0xFF74443D),
      surfaceDim: AppPalette.paperShade,
      surfaceBright: Color(0xFFFEFAF1),
      surfaceContainerLowest: Color(0xFFFDF8EF),
      surfaceContainerLow: Color(0xFFF6EFE3),
      surfaceContainer: Color(0xFFF0E8DA),
      surfaceContainerHigh: Color(0xFFE8DECF),
      surfaceContainerHighest: Color(0xFFE1D6C5),
      outline: Color(0xFFA89D8C),
      outlineVariant: AppPalette.outlineSoft,
      shadow: Color(0xFF221C14),
      scrim: Color(0xFF000000),
      inverseSurface: Color(0xFF2B342D),
      onInverseSurface: AppPalette.paperSnow,
      inversePrimary: AppPalette.linenOlive,
    );

    final baseTextTheme = Typography.material2021(
      platform: defaultTargetPlatform,
    ).black;
    final textTheme = baseTextTheme.copyWith(
      displaySmall: _displayStyle(
        size: 38,
        height: 1.04,
        weight: FontWeight.w800,
        letterSpacing: -0.8,
      ),
      headlineLarge: _displayStyle(
        size: 31,
        height: 1.06,
        weight: FontWeight.w800,
        letterSpacing: -0.6,
      ),
      headlineMedium: _displayStyle(
        size: 26,
        height: 1.12,
        weight: FontWeight.w800,
        letterSpacing: -0.3,
      ),
      headlineSmall: _displayStyle(
        size: 22,
        height: 1.14,
        weight: FontWeight.w800,
        letterSpacing: -0.2,
      ),
      titleLarge: _displayStyle(
        size: 20,
        height: 1.18,
        weight: FontWeight.w800,
      ),
      titleMedium: _bodyStyle(size: 16, height: 1.3, weight: FontWeight.w800),
      titleSmall: _bodyStyle(size: 14, height: 1.26, weight: FontWeight.w700),
      bodyLarge: _bodyStyle(size: 15, height: 1.56),
      bodyMedium: _bodyStyle(size: 13.5, height: 1.58),
      bodySmall: _bodyStyle(size: 11.5, height: 1.46),
      labelLarge: _bodyStyle(
        size: 12.5,
        height: 1.14,
        weight: FontWeight.w700,
        letterSpacing: 0.28,
      ),
      labelMedium: _bodyStyle(
        size: 11.5,
        height: 1.12,
        weight: FontWeight.w700,
        letterSpacing: 0.24,
      ),
      labelSmall: _bodyStyle(
        size: 10.5,
        height: 1.12,
        weight: FontWeight.w700,
        letterSpacing: 0.26,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
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
          fontSize: 21,
          fontWeight: FontWeight.w800,
          color: colorScheme.onSurface,
        ),
      ),
      cardTheme: CardThemeData(
        color: colorScheme.surfaceContainerLow,
        elevation: 0,
        margin: EdgeInsets.zero,
        surfaceTintColor: Colors.transparent,
        shadowColor: const Color(0x12212C25),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(32),
          side: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.86),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerLowest,
        hintStyle: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
        labelStyle: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w700,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 17,
        ),
        prefixIconColor: colorScheme.onSurfaceVariant,
        suffixIconColor: colorScheme.onSurfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: BorderSide(color: colorScheme.primary, width: 1.4),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: colorScheme.surfaceContainerHighest,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurface,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, 48),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          elevation: 0,
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          textStyle: textTheme.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, 48),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          foregroundColor: colorScheme.onSurface,
          side: BorderSide(color: colorScheme.outlineVariant),
          backgroundColor: colorScheme.surfaceBright.withValues(alpha: 0.9),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
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
              return colorScheme.primaryContainer.withValues(alpha: 0.96);
            }
            return colorScheme.surfaceContainerLowest;
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
        backgroundColor: colorScheme.surfaceBright.withValues(alpha: 0.98),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        height: 72,
        indicatorColor: AppPalette.softPine.withValues(alpha: 0.46),
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
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
        indicatorColor: AppPalette.softPine.withValues(alpha: 0.4),
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        minWidth: 72,
        minExtendedWidth: 204,
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
        backgroundColor: colorScheme.surfaceBright,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        backgroundColor: colorScheme.surfaceContainerHigh.withValues(
          alpha: 0.76,
        ),
        side: BorderSide(
          color: colorScheme.outlineVariant.withValues(alpha: 0.4),
        ),
        selectedColor: colorScheme.primaryContainer,
        labelStyle: textTheme.labelLarge?.copyWith(
          color: colorScheme.onSurface,
        ),
      ),
      listTileTheme: ListTileThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
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
