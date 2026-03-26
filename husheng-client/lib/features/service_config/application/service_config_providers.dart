import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sickandflutter/core/config/env_config.dart';
import 'package:sickandflutter/core/network/api_client_factory.dart';
import 'package:sickandflutter/features/preview/preview_workspace_seed.dart';
import 'package:sickandflutter/features/service_config/domain/service_endpoint_resolver.dart';
import 'package:sickandflutter/features/service_config/infrastructure/service_health_repository.dart';
import 'package:sickandflutter/features/settings/settings_controller.dart';
import 'package:sickandflutter/shared/models/app_settings.dart';
import 'package:sickandflutter/shared/models/service_health_info.dart';

/// 当前实际使用的设备服务端点。
final resolvedServiceEndpointsProvider = Provider<ResolvedServiceEndpoints>((
  ref,
) {
  final envConfig = ref.watch(envConfigProvider);
  final settings = ref.watch(effectiveAppSettingsProvider);
  return ServiceEndpointResolver.resolve(
    configuredBaseUrl: settings.baseUrl,
    fallbackBaseUrl: envConfig.baseUrl,
  );
});

/// 已应用当前设备服务端点后的运行设置。
///
/// 其他业务模块不再各自重复拼接基础地址，统一复用这里的结果。
final resolvedDeviceServiceSettingsProvider = Provider<AppSettings>((ref) {
  final settings = ref.watch(effectiveAppSettingsProvider);
  final serviceEndpoints = ref.watch(resolvedServiceEndpointsProvider);
  return settings.copyWith(baseUrl: serviceEndpoints.deviceBaseUrl);
});

/// 设置页和预览模式共用的服务健康检查状态。
final serviceHealthProvider = FutureProvider.autoDispose<ServiceHealthInfo>((
  ref,
) async {
  if (ref.watch(previewWorkspaceEnabledProvider)) {
    return ref.watch(previewServiceHealthProvider);
  }

  final settings = ref.watch(resolvedDeviceServiceSettingsProvider);
  final apiClientFactory = ref.watch(apiClientFactoryProvider);
  final repository = ServiceHealthRepository(
    apiClient: apiClientFactory.create(settings: settings),
  );
  return repository.fetchHealth();
});
