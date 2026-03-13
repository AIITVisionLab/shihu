import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sickandflutter/core/network/api_exception.dart';
import 'package:sickandflutter/features/device/application/device_runtime_providers.dart';
import 'package:sickandflutter/features/device/domain/device_runtime_repository.dart';
import 'package:sickandflutter/features/device/domain/device_status.dart';
import 'package:sickandflutter/features/device/domain/led_operation_receipt.dart';
import 'package:sickandflutter/features/realtime/realtime_detect_controller.dart';

void main() {
  test(
    'RealtimeDetectController polls device state while auto refresh is on',
    () async {
      final repository = _QueueDeviceRuntimeRepository(
        states: <DeviceStatus>[
          const DeviceStatus(
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
          const DeviceStatus(
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
          deviceRuntimeRepositoryProvider.overrideWith(
            (ref) async => repository,
          ),
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
      final repository = _MutableDeviceRuntimeRepository(
        state: const DeviceStatus(
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
          deviceRuntimeRepositoryProvider.overrideWith(
            (ref) async => repository,
          ),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(
        realtimeDetectControllerProvider.notifier,
      );

      await notifier.startMonitoring();
      final message = await notifier.toggleLed(true);

      final state = container.read(realtimeDetectControllerProvider);
      expect(message, contains('已通过OneNET API下发LED指令'));
      expect(message, contains('请求号：req_led_001'));
      expect(repository.lastLedOn, isTrue);
      expect(state.deviceState?.ledOn, isTrue);
    },
  );

  test(
    'RealtimeDetectController blocks led command when deviceId is missing',
    () async {
      final repository = _MutableDeviceRuntimeRepository(
        state: const DeviceStatus(
          deviceId: '',
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
          deviceRuntimeRepositoryProvider.overrideWith(
            (ref) async => repository,
          ),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(
        realtimeDetectControllerProvider.notifier,
      );

      await notifier.startMonitoring();

      await expectLater(
        notifier.toggleLed(true),
        throwsA(
          isA<ApiException>().having(
            (error) => error.message,
            'message',
            '当前还不能调整补光，请先等待状态稳定。',
          ),
        ),
      );
      expect(repository.lastLedOn, isNull);
    },
  );
}

class _QueueDeviceRuntimeRepository implements DeviceRuntimeRepository {
  _QueueDeviceRuntimeRepository({required List<DeviceStatus> states})
    : _states = states;

  final List<DeviceStatus> _states;
  int fetchCount = 0;

  @override
  Future<DeviceStatus> fetchStatus() async {
    final index = fetchCount < _states.length ? fetchCount : _states.length - 1;
    fetchCount += 1;
    return _states[index];
  }

  @override
  Future<Never> setLed({
    required String deviceId,
    required String deviceName,
    required bool ledOn,
  }) {
    throw UnimplementedError();
  }
}

class _MutableDeviceRuntimeRepository implements DeviceRuntimeRepository {
  _MutableDeviceRuntimeRepository({required DeviceStatus state})
    : _state = state;

  DeviceStatus _state;
  bool? lastLedOn;

  @override
  Future<DeviceStatus> fetchStatus() async => _state;

  @override
  Future<LedOperationReceipt> setLed({
    required String deviceId,
    required String deviceName,
    required bool ledOn,
  }) async {
    lastLedOn = ledOn;
    _state = DeviceStatus(
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
    return const LedOperationReceipt(
      status: 'accepted',
      requestId: 'req_led_001',
      message: '已通过OneNET API下发LED指令',
    );
  }
}
