import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sickandflutter/app/app_workspace_destination.dart';
import 'package:sickandflutter/app/widgets/app_workspace_scaffold.dart';

void main() {
  testWidgets('AppWorkspaceScaffold renders rail navigation on wide layout', (
    tester,
  ) async {
    tester.view
      ..physicalSize = const Size(1440, 1200)
      ..devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      const MaterialApp(
        home: AppWorkspaceScaffold(
          destination: AppWorkspaceDestination.home,
          title: '平台首页',
          subtitle: '统一工作台入口',
          currentUser: '巡检员',
          child: SizedBox.expand(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.text('平台总览'), findsOneWidget);
    expect(find.text('视频中心'), findsOneWidget);
    expect(find.text('监控主控台'), findsOneWidget);
    expect(find.text('系统总览'), findsOneWidget);
    expect(find.text('运维设置'), findsOneWidget);
  });

  testWidgets(
    'AppWorkspaceScaffold renders bottom navigation on compact layout',
    (tester) async {
      tester.view
        ..physicalSize = const Size(430, 960)
        ..devicePixelRatio = 1;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const MaterialApp(
          home: AppWorkspaceScaffold(
            destination: AppWorkspaceDestination.realtime,
            title: '实时监控主控台',
            subtitle: '统一工作台入口',
            currentUser: '巡检员',
            child: SizedBox.expand(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.text('平台总览'), findsOneWidget);
      expect(find.text('视频中心'), findsOneWidget);
      expect(find.text('监控主控台'), findsOneWidget);
      expect(find.text('系统总览'), findsOneWidget);
      expect(find.text('运维设置'), findsOneWidget);
    },
  );
}
