import 'package:sickandflutter/shared/models/app_enums.dart';
import 'package:sickandflutter/shared/models/bounding_box.dart';
import 'package:sickandflutter/shared/models/model_utils.dart';

/// 单个检测结果项模型。
class DetectionItem {
  /// 创建单个检测结果项。
  const DetectionItem({
    required this.detectionId,
    required this.labelCode,
    required this.labelName,
    required this.category,
    required this.confidence,
    required this.severityLevel,
    required this.bbox,
  });

  /// 从 JSON 构建检测结果项。
  factory DetectionItem.fromJson(Map<String, dynamic> json) {
    return DetectionItem(
      detectionId: asString(json['detectionId']),
      labelCode: asString(json['labelCode']),
      labelName: asString(json['labelName']),
      category: detectionCategoryFromValue(asString(json['category'])),
      confidence: asDouble(json['confidence']),
      severityLevel: severityLevelFromValue(asString(json['severityLevel'])),
      bbox: BoundingBox.fromJson(
        asStringMap(json['bbox']) ?? const <String, dynamic>{},
      ),
    );
  }

  /// 检测框 ID。
  final String detectionId;

  /// 标签编码。
  final String labelCode;

  /// 标签名称。
  final String labelName;

  /// 识别类别。
  final DetectionCategory category;

  /// 置信度。
  final double confidence;

  /// 严重程度。
  final SeverityLevel severityLevel;

  /// 检测框坐标。
  final BoundingBox bbox;

  /// 序列化为 JSON。
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'detectionId': detectionId,
      'labelCode': labelCode,
      'labelName': labelName,
      'category': category.value,
      'confidence': confidence,
      'severityLevel': severityLevel.value,
      'bbox': bbox.toJson(),
    };
  }
}
