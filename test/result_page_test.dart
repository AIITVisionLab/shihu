import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sickandflutter/features/result/result_page.dart';
import 'package:sickandflutter/shared/models/app_enums.dart';
import 'package:sickandflutter/shared/models/detect_response.dart';
import 'package:sickandflutter/shared/models/detect_summary.dart';
import 'package:sickandflutter/shared/models/detection_item.dart';
import 'package:sickandflutter/shared/models/image_info.dart' as app_model;

void main() {
  testWidgets('ResultPage shows preview card when annotated url exists', (
    tester,
  ) async {
    const response = DetectResponse(
      detectId: 'det_annotated',
      sourceType: SourceType.history,
      capturedAt: '2026-03-07T15:30:00+08:00',
      summary: DetectSummary(
        primaryLabelCode: 'healthy_normal',
        primaryLabelName: '健康植株',
        category: DetectionCategory.healthy,
        confidence: 0.98,
        severityLevel: SeverityLevel.none,
        severityScore: 0.08,
        healthStatus: HealthStatus.healthy,
      ),
      detections: <DetectionItem>[],
      imageInfo: app_model.ImageInfo(
        width: 1280,
        height: 720,
        annotatedUrl: 'https://example.com/annotated.jpg',
      ),
    );

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: ResultPage(
            payload: ResultPagePayload(
              result: response,
              sourceImagePath: null,
              canSave: false,
            ),
          ),
        ),
      ),
    );

    await tester.pump();

    expect(find.text('结果图区域'), findsOneWidget);
  });
}
