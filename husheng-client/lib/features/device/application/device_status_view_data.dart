import 'package:sickandflutter/features/device/domain/device_status.dart';

/// 设备状态在界面层使用的展示派生数据。
class DeviceStatusViewData {
  /// 创建设备状态展示对象。
  const DeviceStatusViewData({
    required this.deviceLabel,
    required this.alertLevel,
    required this.alertTitle,
    required this.alertDescription,
    required this.freshnessLabel,
    required this.ledLabel,
    required this.isFresh,
    required this.temperatureLabel,
    required this.humidityLabel,
    required this.lightLabel,
    required this.mq2Label,
  });

  /// 从设备状态实体构建设备展示对象。
  factory DeviceStatusViewData.fromState(
    DeviceStatus state, {
    DateTime? referenceTime,
  }) {
    return DeviceStatusViewData(
      deviceLabel: _resolveDeviceLabel(state),
      alertLevel: state.alertLevel,
      alertTitle: _buildAlertTitle(state.errorCode),
      alertDescription: _buildAlertDescription(state.errorCode),
      freshnessLabel: _buildFreshnessLabel(state, referenceTime: referenceTime),
      ledLabel: _buildLedLabel(state.ledOn),
      isFresh: state.isFresh(referenceTime: referenceTime),
      temperatureLabel: _formatMetric(state.temperature, state.temperatureUnit),
      humidityLabel: _formatMetric(state.humidity, state.humidityUnit),
      lightLabel: _formatMetric(
        state.light,
        state.lightUnit,
        fractionDigits: 0,
      ),
      mq2Label: _formatMetric(state.mq2, state.mq2Unit),
    );
  }

  /// 设备名称展示文案。
  final String deviceLabel;

  /// 当前运行等级。
  final DeviceAlertLevel alertLevel;

  /// 当前状态标题。
  final String alertTitle;

  /// 当前状态说明。
  final String alertDescription;

  /// 当前数据新鲜度说明。
  final String freshnessLabel;

  /// LED 状态文案。
  final String ledLabel;

  /// 当前数据是否仍在新鲜窗口内。
  final bool isFresh;

  /// 温度展示文案。
  final String temperatureLabel;

  /// 湿度展示文案。
  final String humidityLabel;

  /// 光照展示文案。
  final String lightLabel;

  /// MQ2 展示文案。
  final String mq2Label;

  static String _resolveDeviceLabel(DeviceStatus state) {
    final deviceName = state.deviceName.trim();
    if (deviceName.isNotEmpty) {
      return deviceName;
    }
    return '当前设备';
  }

  static String _buildAlertTitle(int? errorCode) {
    switch (errorCode) {
      case 0:
        return '系统运行正常';
      case 1:
        return '设备需要人工复核';
      case 2:
        return '设备处于告警状态';
      default:
        return '状态来源待确认';
    }
  }

  static String _buildAlertDescription(int? errorCode) {
    switch (errorCode) {
      case 0:
        return '当前采集和控制链路处于正常区间，可以继续观察环境波动。';
      case 1:
        return '当前环境出现波动，建议尽快人工复核并继续关注后续变化。';
      case 2:
        return '当前异常较明显，应优先处理设备或环境问题。';
      default:
        return '当前状态还不够明确，建议继续观察并等待下一次同步。';
    }
  }

  static String _buildFreshnessLabel(
    DeviceStatus state, {
    DateTime? referenceTime,
  }) {
    final age = state.ageSince(referenceTime);
    if (age == null) {
      return '未收到设备上报';
    }
    if (age <= const Duration(seconds: 18)) {
      return '数据已同步';
    }
    if (age.inMinutes >= 1) {
      return '数据已滞后 ${age.inMinutes} 分钟';
    }
    return '数据已滞后 ${age.inSeconds} 秒';
  }

  static String _buildLedLabel(bool? ledOn) {
    if (ledOn == null) {
      return '未知';
    }
    return ledOn ? '已开启' : '已关闭';
  }

  static String _formatMetric(
    double? value,
    String unit, {
    int fractionDigits = 1,
    String fallback = '--',
  }) {
    if (value == null) {
      return fallback;
    }

    final normalizedValue = value.truncateToDouble() == value
        ? value.toStringAsFixed(0)
        : value.toStringAsFixed(fractionDigits);
    final normalizedUnit = unit.trim();
    if (normalizedUnit.isEmpty) {
      return normalizedValue;
    }
    return '$normalizedValue $normalizedUnit';
  }
}
