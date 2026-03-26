import 'package:sickandflutter/features/device/domain/device_status.dart';
import 'package:sickandflutter/features/device/domain/led_operation_receipt.dart';

/// 设备运行时仓储统一入口。
abstract class DeviceRuntimeRepository {
  /// 拉取当前设备状态。
  Future<DeviceStatus> fetchStatus();

  /// 设置 LED 开关。
  Future<LedOperationReceipt> setLed({
    required String deviceId,
    required String deviceName,
    required bool ledOn,
  });
}
