import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:sickandflutter/app/routes.dart';
import 'package:sickandflutter/features/home/home_page.dart';
import 'package:sickandflutter/features/settings/settings_controller.dart';

void main() {
  testWidgets('HomePage renders entry cards and version info', (tester) async {
    tester.view
      ..physicalSize = const Size(1400, 1600)
      ..devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final router = _buildRouter();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          packageInfoProvider.overrideWith(
            (ref) async => PackageInfo(
              appName: '石斛病虫害识别',
              packageName: 'com.example.sickandflutter',
              version: '1.2.3',
              buildNumber: '45',
            ),
          ),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('开始识别'), findsOneWidget);
    expect(find.text('实时监测'), findsOneWidget);
    expect(find.text('历史记录'), findsOneWidget);
    expect(find.text('设置'), findsOneWidget);
    expect(find.text('版本 1.2.3'), findsOneWidget);
  });

  testWidgets('HomePage entry cards navigate to named routes', (tester) async {
    tester.view
      ..physicalSize = const Size(1400, 1600)
      ..devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final router = _buildRouter();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          packageInfoProvider.overrideWith(
            (ref) async => PackageInfo(
              appName: '石斛病虫害识别',
              packageName: 'com.example.sickandflutter',
              version: '1.2.3',
              buildNumber: '45',
            ),
          ),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('开始识别'));
    await tester.pumpAndSettle();
    expect(find.text('detect-page'), findsOneWidget);

    router.goNamed(AppRoutes.home);
    await tester.pumpAndSettle();

    await tester.tap(find.text('实时监测'));
    await tester.pumpAndSettle();
    expect(find.text('realtime-page'), findsOneWidget);

    router.goNamed(AppRoutes.home);
    await tester.pumpAndSettle();

    await tester.tap(find.text('历史记录'));
    await tester.pumpAndSettle();
    expect(find.text('history-page'), findsOneWidget);

    router.goNamed(AppRoutes.home);
    await tester.pumpAndSettle();

    await tester.tap(find.text('设置'));
    await tester.pumpAndSettle();
    expect(find.text('settings-page'), findsOneWidget);
  });
}

GoRouter _buildRouter() {
  return GoRouter(
    initialLocation: AppRoutes.homePath,
    routes: <RouteBase>[
      GoRoute(
        path: AppRoutes.homePath,
        name: AppRoutes.home,
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: AppRoutes.detectPath,
        name: AppRoutes.detect,
        builder: (context, state) => const Scaffold(body: Text('detect-page')),
      ),
      GoRoute(
        path: AppRoutes.realtimeDetectPath,
        name: AppRoutes.realtimeDetect,
        builder: (context, state) =>
            const Scaffold(body: Text('realtime-page')),
      ),
      GoRoute(
        path: AppRoutes.historyPath,
        name: AppRoutes.history,
        builder: (context, state) => const Scaffold(body: Text('history-page')),
      ),
      GoRoute(
        path: AppRoutes.settingsPath,
        name: AppRoutes.settings,
        builder: (context, state) =>
            const Scaffold(body: Text('settings-page')),
      ),
    ],
  );
}
