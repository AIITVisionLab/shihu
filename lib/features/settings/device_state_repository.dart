import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sickandflutter/core/config/env_config.dart';
import 'package:sickandflutter/core/network/api_client.dart';
import 'package:sickandflutter/core/network/api_client_factory.dart';
import 'package:sickandflutter/core/network/api_exception.dart';
import 'package:sickandflutter/features/settings/settings_controller.dart';
import 'package:sickandflutter/shared/models/device_state_info.dart';
import 'package:sickandflutter/shared/models/model_utils.dart';

/// 设备状态与控制接口仓储。
class DeviceStateRepository {
  /// 创建设备状态仓储。
  const DeviceStateRepository({required ApiClient apiClient})
    : _apiClient = apiClient;

  final ApiClient _apiClient;

  /// 拉取设备状态。
  Future<DeviceStateInfo> fetchState() async {
    final payload = await _apiClient.getJson('/api/status');
    return DeviceStateInfo.fromJson(payload);
  }

  /// 设置 LED 开关。
  Future<void> setLed({
    required String deviceId,
    required String deviceName,
    required bool ledOn,
  }) async {
    final response = await _apiClient.postJson(
      '/api/ops/led',
      data: <String, dynamic>{
        'deviceId': deviceId,
        'deviceName': deviceName,
        'led': ledOn,
      },
    );

    final status = asString(response['status']).trim().toLowerCase();
    if (status == 'accepted' || status == 'success' || status == 'ok') {
      return;
    }

    final message = asString(response['message']);
    throw ApiException(message: message.isEmpty ? 'LED 控制失败。' : message);
  }
}

/// 设备状态仓储 Provider。
final deviceStateRepositoryProvider =
    FutureProvider.autoDispose<DeviceStateRepository>((ref) async {
      ref.watch(envConfigProvider);
      final settings = await ref.watch(settingsControllerProvider.future);
      final apiClientFactory = ref.watch(apiClientFactoryProvider);
      return DeviceStateRepository(
        apiClient: apiClientFactory.create(settings: settings),
      );
    });

/// 设备状态 Provider。
final deviceStateProvider = FutureProvider.autoDispose<DeviceStateInfo>((
  ref,
) async {
  final repository = await ref.watch(deviceStateRepositoryProvider.future);
  return repository.fetchState();
});
