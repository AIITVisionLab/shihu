import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sickandflutter/app/app_localizations.dart';

void main() {
  test('AppLocalizations keeps fallback locale in supported locales', () {
    expect(
      AppLocalizations.supportedLocales,
      contains(AppLocalizations.fallbackLocale),
    );
  });

  test('AppLocalizations exposes required Flutter localization delegates', () {
    expect(AppLocalizations.delegates, isNotEmpty);
    expect(
      AppLocalizations.supportedLocales,
      contains(const Locale.fromSubtags(languageCode: 'en', countryCode: 'US')),
    );
  });
}
