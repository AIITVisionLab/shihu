import 'package:sickandflutter/core/network/api_client.dart';
import 'package:sickandflutter/core/network/api_exception.dart';
import 'package:sickandflutter/features/device/domain/device_runtime_repository.dart';
import 'package:sickandflutter/features/device/domain/device_status.dart';
import 'package:sickandflutter/features/device/domain/led_operation_receipt.dart';
import 'package:sickandflutter/shared/models/model_utils.dart';

/// 设备运行时远端仓储实现。
class DeviceRemoteRuntimeRepository implements DeviceRuntimeRepository {
  /// 创建设备运行时远端仓储。
  const DeviceRemoteRuntimeRepository({required ApiClient apiClient})
    : _apiClient = apiClient;

  final ApiClient _apiClient;

  @override
  Future<DeviceStatus> fetchStatus() async {
    final payload = await _apiClient.getJson('/api/status');
    return DeviceStatus.fromJson(payload);
  }

  @override
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
