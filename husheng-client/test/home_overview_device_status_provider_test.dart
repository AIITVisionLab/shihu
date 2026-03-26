import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sickandflutter/features/device/application/device_runtime_providers.dart';
import 'package:sickandflutter/features/device/domain/device_runtime_repository.dart';
import 'package:sickandflutter/features/device/domain/device_status.dart';
import 'package:sickandflutter/features/home/application/home_overview_device_status_provider.dart';

void main() {
  test(
    'homeOverviewDeviceStatusProvider refreshes device snapshot on interval',
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
            temperature: 25.1,
            humidity: 80.0,
            light: 1510,
            mq2: 19,
            errorCode: 1,
            ledOn: true,
            updatedAt: 1741399208000,
          ),
        ],
      );
      final container = ProviderContainer(
        overrides: [
          deviceRuntimeRepositoryProvider.overrideWith(
            (ref) async => repository,
          ),
          homeOverviewRefreshIntervalProvider.overrideWith(
            (ref) => const Duration(milliseconds: 20),
          ),
        ],
      );
      addTearDown(container.dispose);

      final states = <AsyncValue<DeviceStatus>>[];
      final subscription = container.listen<AsyncValue<DeviceStatus>>(
        homeOverviewDeviceStatusProvider,
        (previous, next) => states.add(next),
        fireImmediately: true,
      );
      addTearDown(subscription.close);

      await Future<void>.delayed(const Duration(milliseconds: 70));

      expect(repository.fetchCount, greaterThanOrEqualTo(2));
      expect(subscription.read().asData?.value.temperature, 25.1);
      expect(
        states.where((state) => state.hasValue).length,
        greaterThanOrEqualTo(2),
      );
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
