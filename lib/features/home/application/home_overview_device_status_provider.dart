import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sickandflutter/features/device/application/device_runtime_providers.dart';
import 'package:sickandflutter/features/device/domain/device_status.dart';

/// 首页设备快照自动刷新间隔。
final homeOverviewRefreshIntervalProvider = Provider<Duration>((ref) {
  return const Duration(seconds: 8);
});

/// 首页设备快照 Provider。
///
/// 该 Provider 负责在首页可见期间自动轮询设备状态，
/// 页面层只消费异步结果，不再自己持有定时器。
final homeOverviewDeviceStatusProvider =
    StreamProvider.autoDispose<DeviceStatus>((ref) async* {
      final interval = ref.watch(homeOverviewRefreshIntervalProvider);
      final repository = await ref.watch(
        deviceRuntimeRepositoryProvider.future,
      );

      yield await repository.fetchStatus();

      while (true) {
        await Future<void>.delayed(interval);
        try {
          yield await repository.fetchStatus();
        } catch (_) {
          // 首页自动刷新失败时保留上一帧快照，等待下一轮自动重试。
        }
      }
    });
