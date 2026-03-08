import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sickandflutter/features/realtime/realtime_detect_page.dart';

void main() {
  testWidgets('RealtimeDetectPage renders structural sections', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: RealtimeDetectPage()));

    expect(find.text('链路状态'), findsOneWidget);
    expect(find.text('预览区域'), findsOneWidget);
    expect(find.text('摄像头预览将在下一轮接入'), findsOneWidget);

    await tester.drag(find.byType(ListView), const Offset(0, -800));
    await tester.pumpAndSettle();

    expect(find.text('会话控制'), findsOneWidget);
    expect(find.text('下一步接入项'), findsOneWidget);
  });
}
