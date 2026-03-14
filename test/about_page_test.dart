import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sickandflutter/app/widgets/workspace/workspace_bottom_navigation.dart';
import 'package:sickandflutter/features/about/about_page.dart';
import 'package:sickandflutter/features/auth/auth_controller.dart';
import 'package:sickandflutter/features/auth/auth_session.dart';
import 'package:sickandflutter/features/auth/auth_user.dart';
import 'package:sickandflutter/shared/models/app_enums.dart';

void main() {
  testWidgets('AboutPage renders help tracks and information guidance', (
    tester,
  ) async {
    tester.view
      ..physicalSize = const Size(1400, 1600)
      ..devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authControllerProvider.overrideWith(
            () => _TestAuthController(
              initialState: const AuthState(
                session: AuthSession(
                  accessToken: 'session_demo',
                  loginMode: AuthLoginMode.real,
                  user: AuthUser(
                    userId: 'user_1',
                    account: 'tester',
                    displayName: '联调用户',
                    roles: <String>['admin'],
                  ),
                ),
              ),
            ),
          ),
        ],
        child: const MaterialApp(home: AboutPage()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('使用帮助'), findsWidgets);
    expect(find.text('返回我的'), findsOneWidget);
    expect(find.text('进入值守'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('软件怎么用'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('软件怎么用'), findsOneWidget);
    expect(find.text('视频'), findsWidgets);

    await tester.scrollUntilVisible(
      find.text('你会看到的信息'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('你会看到的信息'), findsOneWidget);
    expect(find.text('设备状态'), findsOneWidget);
    expect(find.text('实时画面'), findsOneWidget);
  });

  testWidgets('AboutPage shows login entry for anonymous users', (
    tester,
  ) async {
    tester.view
      ..physicalSize = const Size(1400, 1600)
      ..devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authControllerProvider.overrideWith(
            () => _TestAuthController(
              initialState: const AuthState(isBootstrapping: false),
            ),
          ),
        ],
        child: const MaterialApp(home: AboutPage()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('立即登录'), findsOneWidget);
    expect(find.text('返回总览'), findsNothing);
  });

  testWidgets('AboutPage renders mobile layout without overflow', (
    tester,
  ) async {
    tester.view
      ..physicalSize = const Size(390, 844)
      ..devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authControllerProvider.overrideWith(
            () => _TestAuthController(
              initialState: const AuthState(
                session: AuthSession(
                  accessToken: 'session_demo',
                  loginMode: AuthLoginMode.real,
                  user: AuthUser(
                    userId: 'user_1',
                    account: 'tester',
                    displayName: '联调用户',
                    roles: <String>['admin'],
                  ),
                ),
              ),
            ),
          ),
        ],
        child: const MaterialApp(home: AboutPage()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(WorkspaceBottomNavigation), findsOneWidget);
    expect(find.text('使用帮助'), findsWidgets);
    expect(find.text('进入值守'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

class _TestAuthController extends AuthController {
  _TestAuthController({required this.initialState});

  final AuthState initialState;

  @override
  AuthState build() => initialState;
}
