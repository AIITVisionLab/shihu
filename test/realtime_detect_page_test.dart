import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sickandflutter/features/realtime/mock_realtime_detect_repository.dart';
import 'package:sickandflutter/features/realtime/realtime_detect_page.dart';
import 'package:sickandflutter/features/realtime/realtime_detect_repository.dart';

void main() {
  testWidgets('RealtimeDetectPage renders structural sections', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          realtimeDetectRepositoryProvider.overrideWith(
            (ref) => const MockRealtimeDetectRepository(
              responseDelay: Duration.zero,
            ),
          ),
        ],
        child: const MaterialApp(home: RealtimeDetectPage()),
      ),
    );

    expect(find.text('链路状态'), findsOneWidget);
    expect(find.text('预览区域'), findsOneWidget);
    expect(find.text('测试帧链路已接入'), findsWidgets);

    await tester.scrollUntilVisible(
      find.text('开始测试链路'),
      300,
      scrollable: find.byType(Scrollable),
    );
    expect(find.text('开始测试链路'), findsOneWidget);

    await tester.tap(find.text('开始测试链路'));
    await tester.pumpAndSettle();

    expect(find.text('会话运行中'), findsOneWidget);
    expect(find.text('黑斑病'), findsWidgets);

    await tester.scrollUntilVisible(
      find.text('下一步接入项'),
      300,
      scrollable: find.byType(Scrollable),
    );
    expect(find.text('会话控制'), findsOneWidget);
    expect(find.text('下一步接入项'), findsOneWidget);
  });
}
