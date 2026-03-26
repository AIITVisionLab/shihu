import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

/// 应用级本地化配置，统一声明默认语言与委托。
///
/// 当前客户端界面文案以中文为主，同时保留英文回退，
/// 避免 Web 端浏览器返回异常语言标签时影响应用启动。
final class AppLocalizations {
  /// 默认界面语言。
  static const Locale fallbackLocale = Locale.fromSubtags(
    languageCode: 'zh',
    countryCode: 'CN',
  );

  /// 当前应用支持的语言列表。
  static const List<Locale> supportedLocales = <Locale>[
    fallbackLocale,
    Locale.fromSubtags(languageCode: 'en', countryCode: 'US'),
  ];

  /// `MaterialApp` 需要接入的本地化委托。
  static const List<LocalizationsDelegate<dynamic>> delegates =
      <LocalizationsDelegate<dynamic>>[
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ];
}
