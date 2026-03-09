import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sickandflutter/core/config/env_config.dart';
import 'package:sickandflutter/core/network/api_client.dart';
import 'package:sickandflutter/features/realtime/realtime_detect_controller.dart';
import 'package:sickandflutter/features/settings/device_state_repository.dart';
import 'package:sickandflutter/shared/models/app_enums.dart';
import 'package:sickandflutter/shared/models/app_settings.dart';
import 'package:sickandflutter/shared/models/device_state_info.dart';

void main() {
  test(
    'RealtimeDetectController polls device state while auto refresh is on',
    () async {
      final repository = _QueueDeviceStateRepository(
        states: <DeviceStateInfo>[
          const DeviceStateInfo(
            deviceId: 'dev_1',
            deviceName: '石斛培育柜',
            temperature: 24.5,
            humidity: 82.0,
            light: 1500,
            mq2: 18,
            errorCode: 0,
            ledOn: true,
            updatedAt: 1741399200000,
          ),
          const DeviceStateInfo(
            deviceId: 'dev_1',
            deviceName: '石斛培育柜',
            temperature: 25.3,
            humidity: 80.0,
            light: 1520,
            mq2: 19,
            errorCode: 1,
            ledOn: true,
            updatedAt: 1741399203000,
          ),
        ],
      );
      final container = ProviderContainer(
        overrides: [
          deviceStateRepositoryProvider.overrideWith((ref) async => repository),
          realtimeDetectPollingIntervalProvider.overrideWith(
            (ref) => const Duration(milliseconds: 20),
          ),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(
        realtimeDetectControllerProvider.notifier,
      );

      await notifier.startMonitoring();
      final startedState = container.read(realtimeDetectControllerProvider);
      expect(startedState.deviceState?.temperature, 24.5);
      expect(repository.fetchCount, 1);

      await Future<void>.delayed(const Duration(milliseconds: 70));
      final advancedState = container.read(realtimeDetectControllerProvider);
      expect(repository.fetchCount, greaterThanOrEqualTo(2));
      expect(advancedState.deviceState?.temperature, 25.3);
      expect(advancedState.deviceState?.alertLevel, DeviceAlertLevel.warning);

      await notifier.setAutoRefreshEnabled(false);
      final pausedFetchCount = repository.fetchCount;

      await Future<void>.delayed(const Duration(milliseconds: 70));
      expect(repository.fetchCount, pausedFetchCount);
    },
  );

  test(
    'RealtimeDetectController submits led command and refreshes state',
    () async {
      final repository = _MutableDeviceStateRepository(
        state: const DeviceStateInfo(
          deviceId: 'dev_1',
          deviceName: '石斛培育柜',
          temperature: 24.5,
          humidity: 82.0,
          light: 1500,
          mq2: 18,
          errorCode: 0,
          ledOn: false,
          updatedAt: 1741399200000,
        ),
      );
      final container = ProviderContainer(
        overrides: [
          deviceStateRepositoryProvider.overrideWith((ref) async => repository),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(
        realtimeDetectControllerProvider.notifier,
      );

      await notifier.startMonitoring();
      final message = await notifier.toggleLed(true);

      final state = container.read(realtimeDetectControllerProvider);
      expect(message, contains('开灯指令已提交'));
      expect(repository.lastLedOn, isTrue);
      expect(state.deviceState?.ledOn, isTrue);
    },
  );
}

class _QueueDeviceStateRepository extends DeviceStateRepository {
  _QueueDeviceStateRepository({required List<DeviceStateInfo> states})
    : _states = states,
      super(
        apiClient: ApiClient(
          settings: AppSettings.defaults(buildFlavor: BuildFlavor.development),
          envConfig: const EnvConfig(
            flavor: BuildFlavor.development,
            baseUrl: 'http://127.0.0.1:8082',
            enableLog: true,
          ),
        ),
      );

  final List<DeviceStateInfo> _states;
  int fetchCount = 0;

  @override
  Future<DeviceStateInfo> fetchState() async {
    final index = fetchCount < _states.length ? fetchCount : _states.length - 1;
    fetchCount += 1;
    return _states[index];
  }
}

class _MutableDeviceStateRepository extends DeviceStateRepository {
  _MutableDeviceStateRepository({required DeviceStateInfo state})
    : _state = state,
      super(
        apiClient: ApiClient(
          settings: AppSettings.defaults(buildFlavor: BuildFlavor.development),
          envConfig: const EnvConfig(
            flavor: BuildFlavor.development,
            baseUrl: 'http://127.0.0.1:8082',
            enableLog: true,
          ),
        ),
      );

  DeviceStateInfo _state;
  bool? lastLedOn;

  @override
  Future<DeviceStateInfo> fetchState() async => _state;

  @override
  Future<void> setLed({
    required String deviceId,
    required String deviceName,
    required bool ledOn,
  }) async {
    lastLedOn = ledOn;
    _state = DeviceStateInfo(
      deviceId: _state.deviceId,
      deviceName: _state.deviceName,
      temperature: _state.temperature,
      temperatureUnit: _state.temperatureUnit,
      humidity: _state.humidity,
      humidityUnit: _state.humidityUnit,
      light: _state.light,
      lightUnit: _state.lightUnit,
      mq2: _state.mq2,
      mq2Unit: _state.mq2Unit,
      errorCode: _state.errorCode,
      ledOn: ledOn,
      updatedAt: _state.updatedAt + 3000,
    );
  }
}
