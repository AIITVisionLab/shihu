import 'package:sickandflutter/shared/models/model_utils.dart';

/// 防治建议信息模型。
class AdviceInfo {
  /// 创建防治建议对象。
  const AdviceInfo({
    required this.title,
    required this.summary,
    required this.preventionSteps,
  });

  /// 从 JSON 构建防治建议对象。
  factory AdviceInfo.fromJson(Map<String, dynamic> json) {
    return AdviceInfo(
      title: asString(json['title']),
      summary: asString(json['summary']),
      preventionSteps: asStringList(json['preventionSteps']),
    );
  }

  /// 建议标题。
  final String title;

  /// 建议摘要。
  final String summary;

  /// 具体防治步骤。
  final List<String> preventionSteps;

  /// 序列化为 JSON。
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'title': title,
      'summary': summary,
      'preventionSteps': preventionSteps,
    };
  }
}
