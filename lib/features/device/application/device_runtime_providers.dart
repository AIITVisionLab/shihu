import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sickandflutter/core/network/api_client_factory.dart';
import 'package:sickandflutter/features/device/domain/device_runtime_repository.dart';
import 'package:sickandflutter/features/device/domain/device_status.dart';
import 'package:sickandflutter/features/device/infrastructure/device_remote_runtime_repository.dart';
import 'package:sickandflutter/features/preview/preview_workspace_seed.dart';
import 'package:sickandflutter/features/service_config/application/service_config_providers.dart';

/// 设备运行时仓储 Provider。
final deviceRuntimeRepositoryProvider =
    FutureProvider.autoDispose<DeviceRuntimeRepository>((ref) async {
      final usePreviewWorkspace = ref.watch(previewWorkspaceEnabledProvider);
      if (usePreviewWorkspace) {
        return ref.watch(previewDeviceRuntimeRepositoryProvider);
      }

      final settings = ref.watch(resolvedDeviceServiceSettingsProvider);
      final apiClientFactory = ref.watch(apiClientFactoryProvider);
      return DeviceRemoteRuntimeRepository(
        apiClient: apiClientFactory.create(settings: settings),
      );
    });

/// 当前设备状态 Provider。
final deviceStatusProvider = FutureProvider.autoDispose<DeviceStatus>((
  ref,
) async {
  final repository = await ref.watch(deviceRuntimeRepositoryProvider.future);
  return repository.fetchStatus();
});
