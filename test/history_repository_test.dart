import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sickandflutter/core/constants/app_constants.dart';
import 'package:sickandflutter/core/storage/local_storage.dart';
import 'package:sickandflutter/features/history/history_repository.dart';

void main() {
  test('HistoryRepository returns empty list for malformed JSON', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      AppConstants.historyStorageKey: '{not-json',
    });

    final preferences = await SharedPreferences.getInstance();
    final repository = HistoryRepository(LocalStorage(preferences));

    final records = await repository.loadRecords();

    expect(records, isEmpty);
  });

  test(
    'HistoryRepository skips malformed items and keeps valid records',
    () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        AppConstants.historyStorageKey:
            '[{"item":{"historyId":"his_1","detectId":"det_1","primaryLabelCode":"disease_black_spot","primaryLabelName":"黑斑病","category":"disease","severityLevel":"medium","confidence":0.95,"capturedAt":"2026-03-07T15:30:00+08:00"},"response":{"detectId":"det_1","sourceType":"image","capturedAt":"2026-03-07T15:30:00+08:00","summary":{"primaryLabelCode":"disease_black_spot","primaryLabelName":"黑斑病","category":"disease","confidence":0.95,"severityLevel":"medium","severityScore":0.65,"healthStatus":"abnormal"},"detections":[]},"savedAt":"2026-03-07T15:35:00+08:00"},"broken"]',
      });

      final preferences = await SharedPreferences.getInstance();
      final repository = HistoryRepository(LocalStorage(preferences));

      final records = await repository.loadRecords();

      expect(records, hasLength(1));
      expect(records.first.item.detectId, 'det_1');
    },
  );
}
