import 'package:flutter_test/flutter_test.dart';
import 'package:sickandflutter/shared/models/advice_info.dart';
import 'package:sickandflutter/shared/models/app_enums.dart';
import 'package:sickandflutter/shared/models/detect_response.dart';
import 'package:sickandflutter/shared/models/detect_summary.dart';
import 'package:sickandflutter/shared/models/detection_item.dart';
import 'package:sickandflutter/shared/models/history_record.dart';

void main() {
  test('HistoryRecord can serialize and deserialize', () {
    const response = DetectResponse(
      detectId: 'det_001',
      sourceType: SourceType.image,
      capturedAt: '2026-03-07T15:30:00+08:00',
      summary: DetectSummary(
        primaryLabelCode: 'disease_black_spot',
        primaryLabelName: '黑斑病',
        category: DetectionCategory.disease,
        confidence: 0.95,
        severityLevel: SeverityLevel.medium,
        severityScore: 0.65,
        healthStatus: HealthStatus.abnormal,
      ),
      detections: <DetectionItem>[],
      advice: AdviceInfo(
        title: '建议处理病叶',
        summary: '建议先隔离叶片并加强通风。',
        preventionSteps: <String>['移除病叶', '增加通风'],
      ),
    );

    final record = HistoryRecord.fromDetectResponse(
      response: response,
      sourceImagePath: '/tmp/leaf.jpg',
    );
    final restored = HistoryRecord.fromJson(record.toJson());

    expect(restored.item.detectId, 'det_001');
    expect(restored.item.primaryLabelName, '黑斑病');
    expect(restored.sourceImagePath, '/tmp/leaf.jpg');
  });
}
