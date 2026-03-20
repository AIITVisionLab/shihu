import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sickandflutter/app/widgets/workspace/workspace_bottom_navigation.dart';
import 'package:sickandflutter/features/ai/application/ai_detection_providers.dart';
import 'package:sickandflutter/features/ai/domain/ai_detection_summary.dart';
import 'package:sickandflutter/features/auth/auth_controller.dart';
import 'package:sickandflutter/features/auth/auth_session.dart';
import 'package:sickandflutter/features/auth/auth_user.dart';
import 'package:sickandflutter/features/device/application/device_runtime_providers.dart';
import 'package:sickandflutter/features/device/domain/device_runtime_repository.dart';
import 'package:sickandflutter/features/device/domain/device_status.dart';
import 'package:sickandflutter/features/realtime/realtime_detect_page.dart';
import 'package:sickandflutter/shared/models/app_enums.dart';

void main() {
  testWidgets('RealtimeDetectPage renders monitoring sections', (tester) async {
    tester.view
      ..physicalSize = const Size(1400, 1600)
      ..devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final repository = _TestDeviceRuntimeRepository(
      state: const DeviceStatus(
        deviceId: 'dev_1',
        deviceName: '石斛培育柜',
        temperature: 24.5,
        humidity: 82.0,
        light: 1500,
        mq2: 18,
        errorCode: 0,
        ledOn: true,
        updatedAt: 1741399200000,
      ),
    );

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
          deviceRuntimeRepositoryProvider.overrideWith(
            (ref) async => repository,
          ),
          aiDetectionOverviewProvider.overrideWith(
            (ref) async => const AiDetectionOverview(
              latest: null,
              history: <AiDetectionSummary>[],
            ),
          ),
        ],
        child: const MaterialApp(home: RealtimeDetectPage()),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    expect(find.text('值守台'), findsOneWidget);
    expect(find.text('总览'), findsOneWidget);
    expect(find.text('我的'), findsOneWidget);
    expect(find.text('值守节奏'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('当前结论'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('当前结论'), findsOneWidget);
    expect(find.text('系统运行正常'), findsWidgets);
    expect(find.text('石斛培育柜'), findsWidgets);

    await tester.scrollUntilVisible(
      find.text('温度'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('温度'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('设备与补光'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('设备与补光'), findsOneWidget);
    expect(find.text('AI 巡检'), findsOneWidget);
    expect(find.text('设备 ID'), findsNothing);
    expect(find.text('错误码'), findsNothing);
    expect(find.text('处理建议'), findsNothing);
    expect(find.text('正常'), findsNothing);
  });

  testWidgets('RealtimeDetectPage renders mobile layout without overflow', (
    tester,
  ) async {
    tester.view
      ..physicalSize = const Size(390, 844)
      ..devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final repository = _TestDeviceRuntimeRepository(
      state: const DeviceStatus(
        deviceId: 'dev_1',
        deviceName: '石斛培育柜',
        temperature: 24.5,
        humidity: 82.0,
        light: 1500,
        mq2: 18,
        errorCode: 0,
        ledOn: true,
        updatedAt: 1741399200000,
      ),
    );

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
          deviceRuntimeRepositoryProvider.overrideWith(
            (ref) async => repository,
          ),
          aiDetectionOverviewProvider.overrideWith(
            (ref) async => const AiDetectionOverview(
              latest: null,
              history: <AiDetectionSummary>[],
            ),
          ),
        ],
        child: const MaterialApp(home: RealtimeDetectPage()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(WorkspaceBottomNavigation), findsOneWidget);
    expect(find.text('值守台'), findsWidgets);
    expect(find.text('查看实时状态，必要时处理补光。'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('RealtimeDetectPage normalizes backend AI risk labels', (
    tester,
  ) async {
    tester.view
      ..physicalSize = const Size(1400, 2000)
      ..devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final repository = _TestDeviceRuntimeRepository(
      state: const DeviceStatus(
        deviceId: 'dev_1',
        deviceName: '石斛培育柜',
        temperature: 24.5,
        humidity: 82.0,
        light: 1500,
        mq2: 18,
        errorCode: 0,
        ledOn: true,
        updatedAt: 1741399200000,
      ),
    );

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
          deviceRuntimeRepositoryProvider.overrideWith(
            (ref) async => repository,
          ),
          aiDetectionOverviewProvider.overrideWith(
            (ref) async => const AiDetectionOverview(
              latest: AiDetectionSummary(
                type: 'AI_DETECTIONS',
                deviceId: 'dev_1',
                stream: 'k230',
                timestampMs: 1741399200000,
                frameId: 18,
                imageWidth: 1280,
                imageHeight: 720,
                detectionCount: 1,
                empty: false,
                summary: 'Detected one target.',
                overallRiskLevel: 'HIGH',
                items: <AiDetectionItem>[
                  AiDetectionItem(
                    classId: 1,
                    originalClassName: 'aphid',
                    displayName: '蚜虫',
                    category: 'pest',
                    confidence: 0.92,
                    riskLevel: 'MEDIUM',
                    advice: '建议复查叶片背面。',
                    bbox: <double>[0, 0, 100, 100],
                    quad: <double>[0, 0, 100, 0, 100, 100, 0, 100],
                  ),
                ],
              ),
              history: <AiDetectionSummary>[
                AiDetectionSummary(
                  type: 'AI_DETECTIONS',
                  deviceId: 'dev_1',
                  stream: 'k230',
                  timestampMs: 1741395600000,
                  frameId: 12,
                  imageWidth: 1280,
                  imageHeight: 720,
                  detectionCount: 1,
                  empty: false,
                  summary: 'Previous record.',
                  overallRiskLevel: 'LOW',
                  items: <AiDetectionItem>[],
                ),
              ],
            ),
          ),
        ],
        child: const MaterialApp(home: RealtimeDetectPage()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('AI 巡检'),
      300,
      scrollable: find.byType(Scrollable).first,
    );

    expect(find.text('高'), findsOneWidget);
    expect(find.text('中'), findsOneWidget);
    expect(find.text('低'), findsOneWidget);
    expect(find.text('HIGH'), findsNothing);
    expect(find.text('MEDIUM'), findsNothing);
    expect(find.text('LOW'), findsNothing);
    expect(find.text('画面 k230'), findsOneWidget);
  });
}

class _TestAuthController extends AuthController {
  _TestAuthController({required this.initialState});

  final AuthState initialState;

  @override
  AuthState build() => initialState;
}

class _TestDeviceRuntimeRepository implements DeviceRuntimeRepository {
  _TestDeviceRuntimeRepository({required this.state});

  final DeviceStatus state;

  @override
  Future<DeviceStatus> fetchStatus() async => state;

  @override
  Future<Never> setLed({
    required String deviceId,
    required String deviceName,
    required bool ledOn,
  }) {
    throw UnimplementedError();
  }
}
