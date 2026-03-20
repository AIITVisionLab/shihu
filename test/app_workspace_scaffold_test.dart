import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:sickandflutter/app/app_workspace_destination.dart';
import 'package:sickandflutter/app/routes.dart';
import 'package:sickandflutter/app/widgets/app_workspace_scaffold.dart';
import 'package:sickandflutter/app/widgets/workspace/workspace_bottom_navigation.dart';
import 'package:sickandflutter/app/widgets/workspace/workspace_header_card.dart';
import 'package:sickandflutter/app/widgets/workspace/workspace_rail_pane.dart';

void main() {
  testWidgets('AppWorkspaceScaffold renders top navigation on wide layout', (
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

    expect(find.byType(WorkspaceRailPane), findsOneWidget);
    expect(find.byType(WorkspaceBottomNavigation), findsNothing);
    expect(find.byType(WorkspaceHeaderChip), findsNothing);
    expect(find.text('总览'), findsOneWidget);
    expect(find.text('值守'), findsOneWidget);
    expect(find.text('视频'), findsOneWidget);
    expect(find.text('我的'), findsOneWidget);

    final titleLeft = tester.getTopLeft(find.text('平台首页'));
    final headerSize = tester.getSize(find.byType(WorkspaceHeaderCard));
    expect(titleLeft.dx, lessThan(420));
    expect(headerSize.width, greaterThan(900));
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
            title: '值守台',
            subtitle: '统一工作台入口',
            currentUser: '巡检员',
            child: SizedBox.expand(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(WorkspaceBottomNavigation), findsOneWidget);
      expect(find.byType(WorkspaceHeaderChip), findsOneWidget);
      expect(find.text('值守'), findsOneWidget);
      expect(tester.getTopLeft(find.text('值守台')).dy, lessThan(80));
      expect(
        tester.getTopLeft(find.byType(WorkspaceBottomNavigation)).dy,
        greaterThan(780),
      );
    },
  );

  testWidgets('AppWorkspaceScaffold keeps branch state when switching tabs', (
    tester,
  ) async {
    tester.view
      ..physicalSize = const Size(430, 960)
      ..devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final initCounts = <String, int>{
      'home': 0,
      'realtime': 0,
      'video': 0,
      'settings': 0,
    };

    final router = GoRouter(
      initialLocation: AppRoutes.homePath,
      routes: <RouteBase>[
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) => navigationShell,
          branches: <StatefulShellBranch>[
            StatefulShellBranch(
              routes: <RouteBase>[
                GoRoute(
                  path: AppRoutes.homePath,
                  builder: (context, state) => _ShellTestPage(
                    destination: AppWorkspaceDestination.home,
                    title: '总览',
                    counterKey: 'home',
                    initCounts: initCounts,
                  ),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: <RouteBase>[
                GoRoute(
                  path: AppRoutes.realtimeDetectPath,
                  builder: (context, state) => _ShellTestPage(
                    destination: AppWorkspaceDestination.realtime,
                    title: '值守',
                    counterKey: 'realtime',
                    initCounts: initCounts,
                  ),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: <RouteBase>[
                GoRoute(
                  path: AppRoutes.videoPath,
                  builder: (context, state) => _ShellTestPage(
                    destination: AppWorkspaceDestination.video,
                    title: '视频',
                    counterKey: 'video',
                    initCounts: initCounts,
                  ),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: <RouteBase>[
                GoRoute(
                  path: AppRoutes.settingsPath,
                  builder: (context, state) => _ShellTestPage(
                    destination: AppWorkspaceDestination.settings,
                    title: '我的',
                    counterKey: 'settings',
                    initCounts: initCounts,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();

    expect(initCounts['home'], 1);

    await tester.tap(find.byIcon(Icons.videocam_outlined).first);
    await tester.pumpAndSettle();
    expect(initCounts['video'], 1);

    await tester.tap(find.byIcon(Icons.dashboard_outlined).first);
    await tester.pumpAndSettle();
    expect(initCounts['home'], 1);
  });
}

class _ShellTestPage extends StatelessWidget {
  const _ShellTestPage({
    required this.destination,
    required this.title,
    required this.counterKey,
    required this.initCounts,
  });

  final AppWorkspaceDestination destination;
  final String title;
  final String counterKey;
  final Map<String, int> initCounts;

  @override
  Widget build(BuildContext context) {
    return AppWorkspaceScaffold(
      destination: destination,
      title: title,
      subtitle: '测试页面',
      currentUser: '巡检员',
      child: _LifecycleCounterPane(
        counterKey: counterKey,
        initCounts: initCounts,
      ),
    );
  }
}

class _LifecycleCounterPane extends StatefulWidget {
  const _LifecycleCounterPane({
    required this.counterKey,
    required this.initCounts,
  });

  final String counterKey;
  final Map<String, int> initCounts;

  @override
  State<_LifecycleCounterPane> createState() => _LifecycleCounterPaneState();
}

class _LifecycleCounterPaneState extends State<_LifecycleCounterPane> {
  @override
  void initState() {
    super.initState();
    widget.initCounts.update(widget.counterKey, (value) => value + 1);
  }

  @override
  Widget build(BuildContext context) => Text(widget.counterKey);
}
