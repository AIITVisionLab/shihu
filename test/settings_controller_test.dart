import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sickandflutter/core/config/env_config.dart';
import 'package:sickandflutter/core/constants/app_constants.dart';
import 'package:sickandflutter/features/settings/settings_controller.dart';
import 'package:sickandflutter/shared/models/app_enums.dart';

void main() {
  group('SettingsController', () {
    test(
      'migrates legacy public default base url to current backend default',
      () async {
        SharedPreferences.setMockInitialValues(<String, Object>{
          AppConstants.settingsStorageKey: jsonEncode(<String, Object>{
            'baseUrl': 'http://101.35.79.76:8082',
            'connectTimeoutMs': AppConstants.defaultConnectTimeoutMs,
            'receiveTimeoutMs': AppConstants.defaultReceiveTimeoutMs,
            'enableLog': true,
            'buildFlavor': BuildFlavor.development.value,
          }),
        });

        final container = ProviderContainer(
          overrides: [
            envConfigProvider.overrideWith(
              (ref) => const EnvConfig(
                flavor: BuildFlavor.development,
                baseUrl: 'http://101.35.79.76',
                enableLog: true,
              ),
            ),
          ],
        );
        addTearDown(container.dispose);

        final settings = await container.read(
          settingsControllerProvider.future,
        );
        final sharedPreferences = await SharedPreferences.getInstance();
        final persistedJson =
            jsonDecode(
                  sharedPreferences.getString(AppConstants.settingsStorageKey)!,
                )
                as Map<String, dynamic>;

        expect(settings.baseUrl, 'http://101.35.79.76');
        expect(persistedJson['baseUrl'], 'http://101.35.79.76');
      },
    );

    test(
      'migrates legacy direct java port to current reverse proxy url',
      () async {
        SharedPreferences.setMockInitialValues(<String, Object>{
          AppConstants.settingsStorageKey: jsonEncode(<String, Object>{
            'baseUrl': 'http://101.35.79.76:19081',
            'connectTimeoutMs': AppConstants.defaultConnectTimeoutMs,
            'receiveTimeoutMs': AppConstants.defaultReceiveTimeoutMs,
            'enableLog': true,
            'buildFlavor': BuildFlavor.development.value,
          }),
        });

        final container = ProviderContainer(
          overrides: [
            envConfigProvider.overrideWith(
              (ref) => const EnvConfig(
                flavor: BuildFlavor.development,
                baseUrl: 'http://101.35.79.76',
                enableLog: true,
              ),
            ),
          ],
        );
        addTearDown(container.dispose);

        final settings = await container.read(
          settingsControllerProvider.future,
        );
        final sharedPreferences = await SharedPreferences.getInstance();
        final persistedJson =
            jsonDecode(
                  sharedPreferences.getString(AppConstants.settingsStorageKey)!,
                )
                as Map<String, dynamic>;

        expect(settings.baseUrl, 'http://101.35.79.76');
        expect(persistedJson['baseUrl'], 'http://101.35.79.76');
      },
    );

    test('migrates legacy localhost base url to current env default', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        AppConstants.settingsStorageKey: jsonEncode(<String, Object>{
          'baseUrl': 'http://127.0.0.1:8085',
          'connectTimeoutMs': AppConstants.defaultConnectTimeoutMs,
          'receiveTimeoutMs': AppConstants.defaultReceiveTimeoutMs,
          'enableLog': true,
          'buildFlavor': BuildFlavor.development.value,
        }),
      });

      final container = ProviderContainer(
        overrides: [
          envConfigProvider.overrideWith(
            (ref) => const EnvConfig(
              flavor: BuildFlavor.development,
              baseUrl: 'http://192.168.1.20:8085',
              enableLog: true,
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      final settings = await container.read(settingsControllerProvider.future);
      final sharedPreferences = await SharedPreferences.getInstance();
      final persistedJson =
          jsonDecode(
                sharedPreferences.getString(AppConstants.settingsStorageKey)!,
              )
              as Map<String, dynamic>;

      expect(settings.baseUrl, 'http://192.168.1.20:8085');
      expect(persistedJson['baseUrl'], 'http://192.168.1.20:8085');
    });

    test('keeps user configured base url untouched', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        AppConstants.settingsStorageKey: jsonEncode(<String, Object>{
          'baseUrl': 'http://192.168.1.88:9000',
          'connectTimeoutMs': AppConstants.defaultConnectTimeoutMs,
          'receiveTimeoutMs': AppConstants.defaultReceiveTimeoutMs,
          'enableLog': true,
          'buildFlavor': BuildFlavor.development.value,
        }),
      });

      final container = ProviderContainer(
        overrides: [
          envConfigProvider.overrideWith(
            (ref) => const EnvConfig(
              flavor: BuildFlavor.development,
              baseUrl: 'http://127.0.0.1:8085',
              enableLog: true,
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      final settings = await container.read(settingsControllerProvider.future);
      final sharedPreferences = await SharedPreferences.getInstance();
      final persistedValue = sharedPreferences.getString(
        AppConstants.settingsStorageKey,
      );

      expect(settings.baseUrl, 'http://192.168.1.88:9000');
      expect(
        persistedValue,
        jsonEncode(<String, Object>{
          'baseUrl': 'http://192.168.1.88:9000',
          'connectTimeoutMs': AppConstants.defaultConnectTimeoutMs,
          'receiveTimeoutMs': AppConstants.defaultReceiveTimeoutMs,
          'enableLog': true,
          'buildFlavor': BuildFlavor.development.value,
        }),
      );
    });
  });
}
