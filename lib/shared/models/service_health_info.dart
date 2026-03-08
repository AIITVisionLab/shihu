import 'package:sickandflutter/shared/models/model_utils.dart';

/// 服务健康检查结果模型。
class ServiceHealthInfo {
  /// 创建服务健康检查结果对象。
  const ServiceHealthInfo({
    required this.status,
    required this.serviceName,
    required this.serviceVersion,
    required this.modelStatus,
    required this.serverTime,
  });

  /// 从 JSON 构建服务健康检查结果对象。
  factory ServiceHealthInfo.fromJson(Map<String, dynamic> json) {
    return ServiceHealthInfo(
      status: asString(json['status']),
      serviceName: asString(json['serviceName']),
      serviceVersion: asString(json['serviceVersion']),
      modelStatus: asString(json['modelStatus']),
      serverTime: asString(json['serverTime']),
    );
  }

  /// 服务状态。
  final String status;

  /// 服务名称。
  final String serviceName;

  /// 服务版本。
  final String serviceVersion;

  /// 模型状态。
  final String modelStatus;

  /// 服务端时间。
  final String serverTime;
}
