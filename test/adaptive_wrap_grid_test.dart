import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sickandflutter/shared/widgets/adaptive_wrap_grid.dart';

void main() {
  testWidgets('AdaptiveWrapGrid narrow width falls back to single column', (
    tester,
  ) async {
    const firstKey = Key('first-card');
    const secondKey = Key('second-card');

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 220,
              child: AdaptiveWrapGrid(
                minItemWidth: 260,
                children: <Widget>[
                  SizedBox(key: firstKey, height: 40),
                  SizedBox(key: secondKey, height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    expect(tester.getSize(find.byKey(firstKey)).width, 220);
    expect(tester.getTopLeft(find.byKey(secondKey)).dy, greaterThan(0));
  });

  testWidgets('AdaptiveWrapGrid wide width can render multiple columns', (
    tester,
  ) async {
    const firstKey = Key('wide-first-card');
    const secondKey = Key('wide-second-card');

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 520,
              child: AdaptiveWrapGrid(
                minItemWidth: 200,
                spacing: 20,
                children: <Widget>[
                  SizedBox(key: firstKey, height: 40),
                  SizedBox(key: secondKey, height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    final firstTopLeft = tester.getTopLeft(find.byKey(firstKey));
    final secondTopLeft = tester.getTopLeft(find.byKey(secondKey));

    expect(tester.getSize(find.byKey(firstKey)).width, 250);
    expect(secondTopLeft.dy, firstTopLeft.dy);
    expect(secondTopLeft.dx, greaterThan(firstTopLeft.dx));
  });
}
