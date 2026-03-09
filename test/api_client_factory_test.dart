import 'package:flutter_test/flutter_test.dart';
import 'package:sickandflutter/core/config/env_config.dart';
import 'package:sickandflutter/core/network/api_client_factory.dart';
import 'package:sickandflutter/shared/models/app_enums.dart';
import 'package:sickandflutter/shared/models/app_settings.dart';

void main() {
  test('ApiClientFactory keeps browser credentials opt-in', () {
    const baseUrl = 'http://127.0.0.1:8082';
    const factory = ApiClientFactory(
      envConfig: EnvConfig(
        flavor: BuildFlavor.development,
        baseUrl: baseUrl,
        enableLog: true,
      ),
      authorizationValue: null,
      cookieHeader: 'JSESSIONID=test-session',
      onUnauthorized: _noopUnauthorized,
    );

    final settings = AppSettings.defaults(
      buildFlavor: BuildFlavor.development,
      baseUrl: baseUrl,
      enableLog: true,
    );
    final publicClient = factory.create(settings: settings);
    final authClient = factory.create(
      settings: settings,
      includeBrowserCredentials: true,
    );

    expect(publicClient.includeBrowserCredentials, isFalse);
    expect(authClient.includeBrowserCredentials, isTrue);
    expect(authClient.cookieHeader, 'JSESSIONID=test-session');
  });
}

void _noopUnauthorized({String? message}) {}
