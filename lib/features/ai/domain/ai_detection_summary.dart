import 'package:sickandflutter/shared/models/model_utils.dart';

/// AI 检测汇总结果。
class AiDetectionSummary {
  /// 创建 AI 检测汇总结果。
  const AiDetectionSummary({
    required this.type,
    required this.deviceId,
    required this.stream,
    required this.timestampMs,
    required this.frameId,
    required this.imageWidth,
    required this.imageHeight,
    required this.detectionCount,
    required this.empty,
    required this.summary,
    required this.overallRiskLevel,
    required this.items,
  });

  /// 从后端 JSON 构建 AI 检测汇总结果。
  factory AiDetectionSummary.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'];
    final items = rawItems is List
        ? rawItems
              .map((item) => asStringMap(item))
              .whereType<Map<String, dynamic>>()
              .map(AiDetectionItem.fromJson)
              .toList(growable: false)
        : const <AiDetectionItem>[];

    return AiDetectionSummary(
      type: asString(json['type']),
      deviceId: asString(json['deviceId']),
      stream: asString(json['stream']),
      timestampMs: _asNullableInt(json['timestampMs']),
      frameId: _asNullableInt(json['frameId']),
      imageWidth: _asNullableInt(json['imageWidth']),
      imageHeight: _asNullableInt(json['imageHeight']),
      detectionCount: _asNullableInt(json['detectionCount']) ?? items.length,
      empty: asBool(json['empty'], fallback: items.isEmpty),
      summary: asString(json['summary']),
      overallRiskLevel: asString(json['overallRiskLevel']),
      items: items,
    );
  }

  /// 结果类型。
  final String type;

  /// 设备标识。
  final String deviceId;

  /// 视频流标识。
  final String stream;

  /// 结果时间戳（毫秒）。
  final int? timestampMs;

  /// 帧编号。
  final int? frameId;

  /// 原始图像宽度。
  final int? imageWidth;

  /// 原始图像高度。
  final int? imageHeight;

  /// 检测到的目标数量。
  final int detectionCount;

  /// 是否为空结果。
  final bool empty;

  /// 汇总说明。
  final String summary;

  /// 总体风险等级。
  final String overallRiskLevel;

  /// 识别项列表。
  final List<AiDetectionItem> items;

  /// 当前结果是否包含可展示的检测项。
  bool get hasDetections => !empty && items.isNotEmpty;

  /// 检测时间。
  DateTime? get detectedAt {
    final value = timestampMs;
    if (value == null || value <= 0) {
      return null;
    }
    return DateTime.fromMillisecondsSinceEpoch(value).toLocal();
  }

  static int? _asNullableInt(Object? value) {
    if (value == null) {
      return null;
    }
    return asInt(value);
  }
}

/// AI 单项检测结果。
class AiDetectionItem {
  /// 创建 AI 单项检测结果。
  const AiDetectionItem({
    required this.classId,
    required this.originalClassName,
    required this.displayName,
    required this.category,
    required this.confidence,
    required this.riskLevel,
    required this.advice,
    required this.bbox,
    required this.quad,
  });

  /// 从后端 JSON 构建 AI 单项检测结果。
  factory AiDetectionItem.fromJson(Map<String, dynamic> json) {
    return AiDetectionItem(
      classId: _asNullableInt(json['classId']),
      originalClassName: asString(json['originalClassName']),
      displayName: asString(json['displayName']),
      category: asString(json['category']),
      confidence: _asNullableDouble(json['confidence']),
      riskLevel: asString(json['riskLevel']),
      advice: asString(json['advice']),
      bbox: _asDoubleList(json['bbox']),
      quad: _asDoubleList(json['quad']),
    );
  }

  /// 分类编号。
  final int? classId;

  /// 边缘端原始类别名。
  final String originalClassName;

  /// 面向用户的类别名称。
  final String displayName;

  /// 类别归属。
  final String category;

  /// 置信度。
  final double? confidence;

  /// 风险等级。
  final String riskLevel;

  /// 建议动作。
  final String advice;

  /// 边界框。
  final List<double> bbox;

  /// 四边形轮廓。
  final List<double> quad;

  static int? _asNullableInt(Object? value) {
    if (value == null) {
      return null;
    }
    return asInt(value);
  }

  static double? _asNullableDouble(Object? value) {
    if (value == null) {
      return null;
    }
    return asDouble(value);
  }

  static List<double> _asDoubleList(Object? value) {
    if (value is! List) {
      return const <double>[];
    }

    return value.map((item) => asDouble(item)).toList(growable: false);
  }
}

/// AI 检测面板所需的组合结果。
class AiDetectionOverview {
  /// 创建 AI 检测面板组合结果。
  const AiDetectionOverview({required this.latest, required this.history});

  /// 当前最新结果。
  final AiDetectionSummary? latest;

  /// 最近历史结果。
  final List<AiDetectionSummary> history;

  /// 当前是否已收到任何 AI 检测结果。
  bool get hasAnyData => latest != null || history.isNotEmpty;
}
