import 'package:json_annotation/json_annotation.dart';
import 'package:sickandflutter/shared/models/json_value_parsers.dart';

part 'service_health_info.g.dart';

/// 服务健康检查结果模型。
@JsonSerializable()
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
  factory ServiceHealthInfo.fromJson(Map<String, dynamic> json) =>
      _$ServiceHealthInfoFromJson(json);

  /// 服务状态。
  @JsonKey(fromJson: parseStringValue)
  final String status;

  /// 服务名称。
  @JsonKey(fromJson: parseStringValue)
  final String serviceName;

  /// 服务版本。
  @JsonKey(fromJson: parseStringValue)
  final String serviceVersion;

  /// 模型状态。
  @JsonKey(fromJson: parseStringValue)
  final String modelStatus;

  /// 服务端时间。
  @JsonKey(fromJson: parseStringValue)
  final String serverTime;

  /// 序列化为 JSON。
  Map<String, dynamic> toJson() => _$ServiceHealthInfoToJson(this);
}
