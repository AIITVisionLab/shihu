import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sickandflutter/shared/widgets/workspace_layout.dart';

void main() {
  testWidgets('WorkspaceTwoPane keeps desktop main-side layout on wide width', (
    tester,
  ) async {
    tester.view
      ..physicalSize = const Size(1440, 900)
      ..devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      _buildHarness(
        width: 1200,
        child: WorkspaceTwoPane(
          primary: Container(key: const Key('primary'), height: 120),
          secondary: Container(key: const Key('secondary'), height: 80),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final primaryFinder = find.byKey(const Key('primary'));
    final secondaryFinder = find.byKey(const Key('secondary'));
    final primaryTopRight = tester.getTopRight(primaryFinder);
    final secondaryTopLeft = tester.getTopLeft(secondaryFinder);
    final secondaryWidth = tester.getSize(secondaryFinder).width;

    expect(secondaryTopLeft.dx, greaterThan(primaryTopRight.dx));
    expect(secondaryTopLeft.dy, equals(tester.getTopLeft(primaryFinder).dy));
    expect(secondaryWidth, inInclusiveRange(328.0, 392.0));
  });

  testWidgets(
    'WorkspaceTwoPane falls back to stacked layout on compact width',
    (tester) async {
      tester.view
        ..physicalSize = const Size(900, 900)
        ..devicePixelRatio = 1;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        _buildHarness(
          width: 900,
          child: WorkspaceTwoPane(
            primary: Container(key: const Key('primary'), height: 120),
            secondary: Container(key: const Key('secondary'), height: 80),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final primaryFinder = find.byKey(const Key('primary'));
      final secondaryFinder = find.byKey(const Key('secondary'));

      expect(
        tester.getTopLeft(secondaryFinder).dy,
        greaterThan(tester.getBottomLeft(primaryFinder).dy),
      );
    },
  );

  testWidgets(
    'WorkspaceBalancedColumns keeps two columns balanced on wide width',
    (tester) async {
      tester.view
        ..physicalSize = const Size(1440, 900)
        ..devicePixelRatio = 1;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        _buildHarness(
          width: 1200,
          child: WorkspaceBalancedColumns(
            primary: Container(key: const Key('primary'), height: 120),
            secondary: Container(key: const Key('secondary'), height: 120),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final primaryWidth = tester
          .getSize(find.byKey(const Key('primary')))
          .width;
      final secondaryWidth = tester
          .getSize(find.byKey(const Key('secondary')))
          .width;

      expect((primaryWidth - secondaryWidth).abs(), lessThanOrEqualTo(1));
    },
  );
}

Widget _buildHarness({required double width, required Widget child}) {
  return MaterialApp(
    home: Scaffold(
      body: Center(
        child: SizedBox(width: width, child: child),
      ),
    ),
  );
}
