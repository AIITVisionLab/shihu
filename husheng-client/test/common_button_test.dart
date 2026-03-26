import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sickandflutter/shared/widgets/common_button.dart';

void main() {
  testWidgets('CommonButton renders label', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: CommonButton(label: '开始识别')),
      ),
    );

    expect(find.text('开始识别'), findsOneWidget);
    expect(find.byType(FilledButton), findsOneWidget);
  });
}
