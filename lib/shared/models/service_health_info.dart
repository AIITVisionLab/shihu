import 'package:json_annotation/json_annotation.dart';
import 'package:sickandflutter/shared/models/json_value_parsers.dart';

part 'service_health_info.g.dart';

/// 服务健康检查结果模型。
@JsonSerializable()
class ServiceHealthInfo {
  /// 创建服务健康检查结果对象。
  const ServiceHealthInfo({
    required this.status,
    required this.responseText,
    required this.checkedAt,
  });

  /// 从 JSON 构建服务健康检查结果对象。
  factory ServiceHealthInfo.fromJson(Map<String, dynamic> json) =>
      _$ServiceHealthInfoFromJson(json);

  /// 服务状态。
  @JsonKey(fromJson: parseStringValue)
  final String status;

  /// 健康接口原始返回文本。
  @JsonKey(fromJson: parseStringValue)
  final String responseText;

  /// 客户端完成检查的时间。
  @JsonKey(fromJson: parseStringValue)
  final String checkedAt;

  /// 客户端完成健康检查的本地时间。
  DateTime? get checkedAtTime => DateTime.tryParse(checkedAt)?.toLocal();

  /// 当前健康检查是否在有效刷新窗口内。
  bool isRecentlyChecked({
    DateTime? referenceTime,
    Duration threshold = const Duration(seconds: 30),
  }) {
    final checkedAtTime = this.checkedAtTime;
    if (checkedAtTime == null) {
      return false;
    }
    final now = referenceTime ?? DateTime.now();
    final difference = now.difference(checkedAtTime);
    if (difference.isNegative) {
      return true;
    }
    return difference <= threshold;
  }

  /// 面向值守页的最近巡检说明。
  String freshnessLabel({
    DateTime? referenceTime,
    Duration threshold = const Duration(seconds: 30),
  }) {
    final checkedAtTime = this.checkedAtTime;
    if (checkedAtTime == null) {
      return '尚未完成巡检';
    }

    final now = referenceTime ?? DateTime.now();
    final difference = now.difference(checkedAtTime);
    if (difference.isNegative || difference <= threshold) {
      return '巡检已更新';
    }
    if (difference.inMinutes >= 1) {
      return '巡检已滞后 ${difference.inMinutes} 分钟';
    }
    return '巡检已滞后 ${difference.inSeconds} 秒';
  }

  /// 序列化为 JSON。
  Map<String, dynamic> toJson() => _$ServiceHealthInfoToJson(this);
}
