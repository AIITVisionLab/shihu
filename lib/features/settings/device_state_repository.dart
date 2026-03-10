import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sickandflutter/core/config/env_config.dart';
import 'package:sickandflutter/core/network/api_client.dart';
import 'package:sickandflutter/core/network/api_client_factory.dart';
import 'package:sickandflutter/core/network/api_exception.dart';
import 'package:sickandflutter/features/settings/settings_controller.dart';
import 'package:sickandflutter/shared/models/device_state_info.dart';
import 'package:sickandflutter/shared/models/model_utils.dart';

/// LED 操作回执。
class LedOperationReceipt {
  /// 创建 LED 操作回执。
  const LedOperationReceipt({
    required this.status,
    required this.requestId,
    required this.message,
  });

  /// 后端返回的状态值。
  final String status;

  /// 后端分配的请求 ID。
  final String? requestId;

  /// 后端返回的说明信息。
  final String message;

  /// 是否属于后端接受或登记成功的状态。
  bool get isAcceptedLike {
    return status == 'accepted' ||
        status == 'success' ||
        status == 'ok' ||
        status == 'pending';
  }

  /// 是否已进入后端待处理队列。
  bool get isPending => status == 'pending';

  /// 构建面向用户的操作反馈文案。
  String buildUserMessage({required bool ledOn}) {
    final normalizedMessage = message.trim();
    final fallbackMessage = isPending
        ? 'LED 指令已登记到待处理队列，等待后端继续下发。'
        : ledOn
        ? '开灯指令已提交，等待设备状态回写。'
        : '关灯指令已提交，等待设备状态回写。';
    final baseMessage = normalizedMessage.isEmpty
        ? fallbackMessage
        : normalizedMessage;
    final normalizedRequestId = requestId?.trim();
    if (normalizedRequestId == null || normalizedRequestId.isEmpty) {
      return baseMessage;
    }

    return '$baseMessage（请求号：$normalizedRequestId）';
  }
}

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
  Future<LedOperationReceipt> setLed({
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
    final message = asString(response['message']);
    final requestId = asString(response['requestId']).trim();
    final receipt = LedOperationReceipt(
      status: status,
      requestId: requestId.isEmpty ? null : requestId,
      message: message,
    );
    if (receipt.isAcceptedLike) {
      return receipt;
    }

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
