import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sickandflutter/core/config/env_config.dart';
import 'package:sickandflutter/core/network/api_client_factory.dart';
import 'package:sickandflutter/features/device/domain/device_runtime_repository.dart';
import 'package:sickandflutter/features/device/domain/device_status.dart';
import 'package:sickandflutter/features/device/infrastructure/device_remote_runtime_repository.dart';
import 'package:sickandflutter/features/settings/settings_controller.dart';

/// 设备运行时仓储 Provider。
final deviceRuntimeRepositoryProvider =
    FutureProvider.autoDispose<DeviceRuntimeRepository>((ref) async {
      ref.watch(envConfigProvider);
      final settings = ref.watch(effectiveAppSettingsProvider);
      final serviceEndpoints = ref.watch(resolvedServiceEndpointsProvider);
      final apiClientFactory = ref.watch(apiClientFactoryProvider);
      return DeviceRemoteRuntimeRepository(
        apiClient: apiClientFactory.createSessionClient(
          settings: settings.copyWith(baseUrl: serviceEndpoints.deviceBaseUrl),
        ),
      );
    });

/// 当前设备状态 Provider。
final deviceStatusProvider = FutureProvider.autoDispose<DeviceStatus>((
  ref,
) async {
  final repository = await ref.watch(deviceRuntimeRepositoryProvider.future);
  return repository.fetchStatus();
});
