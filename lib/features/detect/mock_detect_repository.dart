import 'package:sickandflutter/features/detect/detect_repository.dart';
import 'package:sickandflutter/shared/models/advice_info.dart';
import 'package:sickandflutter/shared/models/app_enums.dart';
import 'package:sickandflutter/shared/models/bounding_box.dart';
import 'package:sickandflutter/shared/models/detect_response.dart';
import 'package:sickandflutter/shared/models/detect_summary.dart';
import 'package:sickandflutter/shared/models/detection_item.dart';
import 'package:sickandflutter/shared/models/image_info.dart';
import 'package:sickandflutter/shared/models/model_info.dart';

/// 开发阶段使用的受控单图识别替身实现。
class MockDetectRepository implements DetectRepository {
  /// 创建替身单图识别仓储。
  const MockDetectRepository();

  @override
  Future<DetectResponse> detectImage({
    required String imagePath,
    required String fileName,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 900));

    final normalizedName = fileName.toLowerCase();
    final isHealthy =
        normalizedName.contains('healthy') || normalizedName.contains('正常');
    final isInsect =
        normalizedName.contains('insect') || normalizedName.contains('虫');

    final now = DateTime.now();
    final summary = isHealthy
        ? const DetectSummary(
            primaryLabelCode: 'healthy_normal',
            primaryLabelName: '健康植株',
            category: DetectionCategory.healthy,
            confidence: 0.9812,
            severityLevel: SeverityLevel.none,
            severityScore: 0.08,
            healthStatus: HealthStatus.healthy,
          )
        : isInsect
        ? const DetectSummary(
            primaryLabelCode: 'insect_scale_insect',
            primaryLabelName: '介壳虫',
            category: DetectionCategory.insect,
            confidence: 0.9264,
            severityLevel: SeverityLevel.low,
            severityScore: 0.32,
            healthStatus: HealthStatus.risk,
          )
        : const DetectSummary(
            primaryLabelCode: 'disease_black_spot',
            primaryLabelName: '黑斑病',
            category: DetectionCategory.disease,
            confidence: 0.9721,
            severityLevel: SeverityLevel.medium,
            severityScore: 0.66,
            healthStatus: HealthStatus.abnormal,
          );

    final detections = isHealthy
        ? const <DetectionItem>[]
        : <DetectionItem>[
            DetectionItem(
              detectionId: 'box_01',
              labelCode: summary.primaryLabelCode,
              labelName: summary.primaryLabelName,
              category: summary.category,
              confidence: summary.confidence,
              severityLevel: summary.severityLevel,
              bbox: BoundingBox(
                x: isInsect ? 0.46 : 0.14,
                y: isInsect ? 0.26 : 0.18,
                width: isInsect ? 0.12 : 0.28,
                height: isInsect ? 0.14 : 0.22,
              ),
            ),
          ];

    return DetectResponse(
      detectId: 'det_${now.millisecondsSinceEpoch}',
      sourceType: SourceType.image,
      capturedAt: now.toIso8601String(),
      summary: summary,
      imageInfo: const ImageInfo(
        width: 1920,
        height: 1080,
        originalUrl: null,
        annotatedUrl: null,
      ),
      detections: detections,
      advice: AdviceInfo(
        title: isHealthy ? '当前植株状态良好' : '建议及时处理叶片异常区域',
        summary: isHealthy ? '建议继续保持通风、光照和水分管理。' : '建议隔离异常叶片，并根据农技规范进行防治。',
        preventionSteps: isHealthy
            ? const <String>['保持稳定通风和散射光照', '继续观察新叶和根系状态', '维持常规巡检频率']
            : const <String>['清除明显异常叶片，减少传播源', '加强通风，降低叶面湿度', '按照农技规范使用对应药剂'],
      ),
      modelInfo: const ModelInfo(
        modelName: 'shihu-detect-v1',
        modelVersion: '1.0.0',
        inferenceMs: 126,
      ),
    );
  }
}
