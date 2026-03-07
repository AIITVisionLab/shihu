import 'package:sickandflutter/shared/models/advice_info.dart';
import 'package:sickandflutter/shared/models/app_enums.dart';
import 'package:sickandflutter/shared/models/detect_summary.dart';
import 'package:sickandflutter/shared/models/detection_item.dart';
import 'package:sickandflutter/shared/models/image_info.dart';
import 'package:sickandflutter/shared/models/model_info.dart';
import 'package:sickandflutter/shared/models/model_utils.dart';

/// 单图识别和实时识别共用的标准结果模型。
class DetectResponse {
  /// 创建识别结果对象。
  const DetectResponse({
    required this.detectId,
    required this.sourceType,
    required this.capturedAt,
    required this.summary,
    required this.detections,
    this.imageInfo,
    this.advice,
    this.modelInfo,
  });

  /// 从 JSON 构建识别结果对象。
  factory DetectResponse.fromJson(Map<String, dynamic> json) {
    final detectionsValue = json['detections'];
    final detections = detectionsValue is List
        ? detectionsValue
              .map(asStringMap)
              .whereType<Map<String, dynamic>>()
              .map(DetectionItem.fromJson)
              .toList(growable: false)
        : const <DetectionItem>[];

    final summaryMap =
        asStringMap(json['summary']) ?? const <String, dynamic>{};
    final imageInfoMap = asStringMap(json['imageInfo']);
    final adviceMap = asStringMap(json['advice']);
    final modelInfoMap = asStringMap(json['modelInfo']);

    return DetectResponse(
      detectId: asString(json['detectId']),
      sourceType: sourceTypeFromValue(asString(json['sourceType'])),
      capturedAt: asString(json['capturedAt']),
      summary: DetectSummary.fromJson(summaryMap),
      imageInfo: imageInfoMap == null ? null : ImageInfo.fromJson(imageInfoMap),
      detections: detections,
      advice: adviceMap == null ? null : AdviceInfo.fromJson(adviceMap),
      modelInfo: modelInfoMap == null ? null : ModelInfo.fromJson(modelInfoMap),
    );
  }

  /// 识别任务 ID。
  final String detectId;

  /// 结果来源类型。
  final SourceType sourceType;

  /// 采集时间。
  final String capturedAt;

  /// 识别摘要。
  final DetectSummary summary;

  /// 图像信息。
  final ImageInfo? imageInfo;

  /// 检测框列表。
  final List<DetectionItem> detections;

  /// 防治建议。
  final AdviceInfo? advice;

  /// 模型推理信息。
  final ModelInfo? modelInfo;

  /// 序列化为 JSON。
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'detectId': detectId,
      'sourceType': sourceType.value,
      'capturedAt': capturedAt,
      'summary': summary.toJson(),
      'imageInfo': imageInfo?.toJson(),
      'detections': detections
          .map((item) => item.toJson())
          .toList(growable: false),
      'advice': advice?.toJson(),
      'modelInfo': modelInfo?.toJson(),
    };
  }
}
