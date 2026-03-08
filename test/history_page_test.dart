import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sickandflutter/features/history/history_page.dart';
import 'package:sickandflutter/features/history/history_repository.dart';
import 'package:sickandflutter/shared/models/app_enums.dart';
import 'package:sickandflutter/shared/models/detect_response.dart';
import 'package:sickandflutter/shared/models/detect_summary.dart';
import 'package:sickandflutter/shared/models/history_item.dart';
import 'package:sickandflutter/shared/models/history_record.dart';

void main() {
  testWidgets('HistoryPage shows empty state when records are missing', (
    tester,
  ) async {
    tester.view
      ..physicalSize = const Size(1200, 1600)
      ..devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final controller = _TestHistoryController(
      initialRecords: const <HistoryRecord>[],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [historyControllerProvider.overrideWith(() => controller)],
        child: const MaterialApp(home: HistoryPage()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('还没有历史记录'), findsOneWidget);
    expect(find.text('先完成一次单图识别并保存结果，再回到这里查看详情。'), findsOneWidget);
  });

  testWidgets('HistoryPage deletes a record after confirmation', (
    tester,
  ) async {
    tester.view
      ..physicalSize = const Size(1200, 1600)
      ..devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final record = _buildRecord();
    final controller = _TestHistoryController(
      initialRecords: <HistoryRecord>[record],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [historyControllerProvider.overrideWith(() => controller)],
        child: const MaterialApp(home: HistoryPage()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('黑斑病'), findsOneWidget);
    expect(find.textContaining('类别：病害'), findsOneWidget);

    await tester.tap(find.byTooltip('删除记录'));
    await tester.pumpAndSettle();
    expect(find.text('删除历史记录'), findsOneWidget);

    await tester.tap(find.text('确认'));
    await tester.pumpAndSettle();

    expect(controller.deletedIds, <String>[record.item.historyId]);
    expect(find.text('还没有历史记录'), findsOneWidget);
  });

  testWidgets('HistoryPage clears all records after confirmation', (
    tester,
  ) async {
    tester.view
      ..physicalSize = const Size(1200, 1600)
      ..devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final controller = _TestHistoryController(
      initialRecords: <HistoryRecord>[
        _buildRecord(historyId: 'his_1', detectId: 'det_1'),
        _buildRecord(historyId: 'his_2', detectId: 'det_2', label: '炭疽病'),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [historyControllerProvider.overrideWith(() => controller)],
        child: const MaterialApp(home: HistoryPage()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byTooltip('清空历史'), findsOneWidget);

    await tester.tap(find.byTooltip('清空历史'));
    await tester.pumpAndSettle();
    expect(find.text('清空历史记录'), findsOneWidget);

    await tester.tap(find.text('确认'));
    await tester.pumpAndSettle();

    expect(controller.clearAllCount, 1);
    expect(find.text('还没有历史记录'), findsOneWidget);
  });
}

class _TestHistoryController extends HistoryController {
  _TestHistoryController({required this.initialRecords});

  final List<HistoryRecord> initialRecords;
  final List<String> deletedIds = <String>[];
  int clearAllCount = 0;

  @override
  Future<List<HistoryRecord>> build() async => initialRecords;

  @override
  Future<void> deleteRecord(String historyId) async {
    deletedIds.add(historyId);
    final currentRecords = state.asData?.value ?? initialRecords;
    state = AsyncData(
      currentRecords
          .where((item) => item.item.historyId != historyId)
          .toList(growable: false),
    );
  }

  @override
  Future<void> clearAll() async {
    clearAllCount += 1;
    state = const AsyncData(<HistoryRecord>[]);
  }
}

HistoryRecord _buildRecord({
  String historyId = 'his_1',
  String detectId = 'det_1',
  String label = '黑斑病',
}) {
  return HistoryRecord(
    item: HistoryItem(
      historyId: historyId,
      detectId: detectId,
      primaryLabelCode: 'disease_black_spot',
      primaryLabelName: label,
      category: DetectionCategory.disease,
      severityLevel: SeverityLevel.medium,
      confidence: 0.9521,
      capturedAt: '2026-03-08T10:00:00+08:00',
    ),
    response: DetectResponse(
      detectId: detectId,
      sourceType: SourceType.image,
      capturedAt: '2026-03-08T10:00:00+08:00',
      summary: DetectSummary(
        primaryLabelCode: 'disease_black_spot',
        primaryLabelName: label,
        category: DetectionCategory.disease,
        confidence: 0.9521,
        severityLevel: SeverityLevel.medium,
        healthStatus: HealthStatus.abnormal,
        severityScore: 0.66,
      ),
      detections: const [],
    ),
    savedAt: '2026-03-08T10:05:00+08:00',
  );
}
