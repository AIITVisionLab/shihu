import 'package:sickandflutter/shared/models/model_utils.dart';

/// 模型推理信息模型。
class ModelInfo {
  /// 创建模型信息对象。
  const ModelInfo({
    required this.modelName,
    required this.modelVersion,
    required this.inferenceMs,
  });

  /// 从 JSON 构建模型信息对象。
  factory ModelInfo.fromJson(Map<String, dynamic> json) {
    return ModelInfo(
      modelName: asString(json['modelName']),
      modelVersion: asString(json['modelVersion']),
      inferenceMs: asInt(json['inferenceMs']),
    );
  }

  /// 模型名称。
  final String modelName;

  /// 模型版本。
  final String modelVersion;

  /// 推理耗时，单位毫秒。
  final int inferenceMs;

  /// 序列化为 JSON。
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'modelName': modelName,
      'modelVersion': modelVersion,
      'inferenceMs': inferenceMs,
    };
  }
}
