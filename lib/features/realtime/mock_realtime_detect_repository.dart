import 'package:sickandflutter/features/realtime/realtime_detect_repository.dart';
import 'package:sickandflutter/shared/models/advice_info.dart';
import 'package:sickandflutter/shared/models/app_enums.dart';
import 'package:sickandflutter/shared/models/bounding_box.dart';
import 'package:sickandflutter/shared/models/detect_response.dart';
import 'package:sickandflutter/shared/models/detect_summary.dart';
import 'package:sickandflutter/shared/models/detection_item.dart';
import 'package:sickandflutter/shared/models/image_info.dart';
import 'package:sickandflutter/shared/models/model_info.dart';

/// 开发阶段使用的受控实时识别替身实现。
class MockRealtimeDetectRepository implements RealtimeDetectRepository {
  /// 创建替身实时识别仓储。
  const MockRealtimeDetectRepository({
    this.responseDelay = const Duration(milliseconds: 420),
  });

  /// 单帧返回前的模拟耗时。
  final Duration responseDelay;

  @override
  bool get supportsTestFeed => true;

  @override
  Future<DetectResponse> detectFrame({
    required RealtimeFrameRequest request,
  }) async {
    await Future<void>.delayed(responseDelay);

    final now = request.capturedAt;
    final cycle = request.frameIndex % 4;

    switch (cycle) {
      case 1:
        return _buildDiseaseResponse(request, now);
      case 2:
        return _buildHealthyResponse(request, now);
      case 3:
        return _buildInsectResponse(request, now);
      default:
        return _buildLeafBlightResponse(request, now);
    }
  }

  DetectResponse _buildDiseaseResponse(
    RealtimeFrameRequest request,
    DateTime capturedAt,
  ) {
    const summary = DetectSummary(
      primaryLabelCode: 'disease_black_spot',
      primaryLabelName: '黑斑病',
      category: DetectionCategory.disease,
      confidence: 0.9632,
      severityLevel: SeverityLevel.medium,
      severityScore: 0.62,
      healthStatus: HealthStatus.abnormal,
    );

    return DetectResponse(
      detectId: '${request.sessionId}_${request.frameIndex}',
      sourceType: SourceType.realtime,
      capturedAt: capturedAt.toIso8601String(),
      summary: summary,
      imageInfo: const ImageInfo(
        width: 1920,
        height: 1080,
        originalUrl: null,
        annotatedUrl: null,
      ),
      detections: const <DetectionItem>[
        DetectionItem(
          detectionId: 'rt_box_black_spot_main',
          labelCode: 'disease_black_spot',
          labelName: '黑斑病',
          category: DetectionCategory.disease,
          confidence: 0.9632,
          severityLevel: SeverityLevel.medium,
          bbox: BoundingBox(x: 0.14, y: 0.20, width: 0.30, height: 0.24),
        ),
      ],
      advice: const AdviceInfo(
        title: '建议优先处理叶面病斑区域',
        summary: '当前测试帧识别到中度黑斑病，请尽快隔离异常叶片并降低叶面湿度。',
        preventionSteps: <String>[
          '清除明显病斑叶片，减少传播源',
          '加强通风，避免长时间叶面潮湿',
          '结合农技规范进行针对性防治',
        ],
      ),
      modelInfo: ModelInfo(
        modelName: 'shihu-realtime-sim',
        modelVersion: '0.3.0',
        inferenceMs: 118,
      ),
    );
  }

  DetectResponse _buildHealthyResponse(
    RealtimeFrameRequest request,
    DateTime capturedAt,
  ) {
    return DetectResponse(
      detectId: '${request.sessionId}_${request.frameIndex}',
      sourceType: SourceType.realtime,
      capturedAt: capturedAt.toIso8601String(),
      summary: const DetectSummary(
        primaryLabelCode: 'healthy_normal',
        primaryLabelName: '健康植株',
        category: DetectionCategory.healthy,
        confidence: 0.9875,
        severityLevel: SeverityLevel.none,
        severityScore: 0.06,
        healthStatus: HealthStatus.healthy,
      ),
      imageInfo: const ImageInfo(
        width: 1920,
        height: 1080,
        originalUrl: null,
        annotatedUrl: null,
      ),
      detections: const <DetectionItem>[],
      advice: const AdviceInfo(
        title: '当前植株状态稳定',
        summary: '当前测试帧未发现明显病虫害风险，可维持常规巡检。',
        preventionSteps: <String>['保持散射光照与稳定通风', '继续观察新叶与根系状态', '维持常规巡检与记录节奏'],
      ),
      modelInfo: ModelInfo(
        modelName: 'shihu-realtime-sim',
        modelVersion: '0.3.0',
        inferenceMs: 94,
      ),
    );
  }

  DetectResponse _buildInsectResponse(
    RealtimeFrameRequest request,
    DateTime capturedAt,
  ) {
    const summary = DetectSummary(
      primaryLabelCode: 'insect_scale_insect',
      primaryLabelName: '介壳虫',
      category: DetectionCategory.insect,
      confidence: 0.9324,
      severityLevel: SeverityLevel.low,
      severityScore: 0.34,
      healthStatus: HealthStatus.risk,
    );

    return DetectResponse(
      detectId: '${request.sessionId}_${request.frameIndex}',
      sourceType: SourceType.realtime,
      capturedAt: capturedAt.toIso8601String(),
      summary: summary,
      imageInfo: const ImageInfo(
        width: 1920,
        height: 1080,
        originalUrl: null,
        annotatedUrl: null,
      ),
      detections: const <DetectionItem>[
        DetectionItem(
          detectionId: 'rt_box_scale_insect_1',
          labelCode: 'insect_scale_insect',
          labelName: '介壳虫',
          category: DetectionCategory.insect,
          confidence: 0.9324,
          severityLevel: SeverityLevel.low,
          bbox: BoundingBox(x: 0.56, y: 0.28, width: 0.10, height: 0.12),
        ),
        DetectionItem(
          detectionId: 'rt_box_scale_insect_2',
          labelCode: 'insect_scale_insect',
          labelName: '介壳虫',
          category: DetectionCategory.insect,
          confidence: 0.9018,
          severityLevel: SeverityLevel.low,
          bbox: BoundingBox(x: 0.62, y: 0.46, width: 0.08, height: 0.10),
        ),
      ],
      advice: const AdviceInfo(
        title: '检测到轻度虫害风险',
        summary: '当前测试帧出现介壳虫特征，建议加强巡检并尽快处理。',
        preventionSteps: <String>['优先隔离明显虫害叶片', '清洁叶面与背面高风险区域', '按规范使用对应防治方案'],
      ),
      modelInfo: ModelInfo(
        modelName: 'shihu-realtime-sim',
        modelVersion: '0.3.0',
        inferenceMs: 132,
      ),
    );
  }

  DetectResponse _buildLeafBlightResponse(
    RealtimeFrameRequest request,
    DateTime capturedAt,
  ) {
    const summary = DetectSummary(
      primaryLabelCode: 'disease_leaf_blight',
      primaryLabelName: '叶枯病',
      category: DetectionCategory.disease,
      confidence: 0.9451,
      severityLevel: SeverityLevel.high,
      severityScore: 0.79,
      healthStatus: HealthStatus.abnormal,
    );

    return DetectResponse(
      detectId: '${request.sessionId}_${request.frameIndex}',
      sourceType: SourceType.realtime,
      capturedAt: capturedAt.toIso8601String(),
      summary: summary,
      imageInfo: const ImageInfo(
        width: 1920,
        height: 1080,
        originalUrl: null,
        annotatedUrl: null,
      ),
      detections: const <DetectionItem>[
        DetectionItem(
          detectionId: 'rt_box_leaf_blight_1',
          labelCode: 'disease_leaf_blight',
          labelName: '叶枯病',
          category: DetectionCategory.disease,
          confidence: 0.9451,
          severityLevel: SeverityLevel.high,
          bbox: BoundingBox(x: 0.18, y: 0.18, width: 0.34, height: 0.40),
        ),
      ],
      advice: const AdviceInfo(
        title: '高风险病害测试帧',
        summary: '当前测试帧出现较大范围病斑，后续接入真实链路后需优先展示高风险提醒。',
        preventionSteps: <String>['扩大异常区域巡检范围', '优先处理已明显病变叶片', '联动农技建议给出升级提醒'],
      ),
      modelInfo: ModelInfo(
        modelName: 'shihu-realtime-sim',
        modelVersion: '0.3.0',
        inferenceMs: 148,
      ),
    );
  }
}
