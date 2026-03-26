import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sickandflutter/features/auth/auth_controller.dart';
import 'package:sickandflutter/features/auth/auth_session.dart';
import 'package:sickandflutter/features/auth/auth_user.dart';
import 'package:sickandflutter/features/device/application/device_runtime_providers.dart';
import 'package:sickandflutter/features/device/domain/device_runtime_repository.dart';
import 'package:sickandflutter/features/device/domain/device_status.dart';
import 'package:sickandflutter/features/realtime/realtime_detect_page.dart';
import 'package:sickandflutter/shared/models/app_enums.dart';

void main() {
  runApp(
    ProviderScope(
      overrides: [
        authControllerProvider.overrideWith(
          () => _PreviewAuthController(
            initialState: const AuthState(
              session: AuthSession(
                accessToken: 'preview_session',
                loginMode: AuthLoginMode.mock,
                user: AuthUser(
                  userId: 'preview_user',
                  account: 'preview',
                  displayName: '界面预览',
                  roles: <String>['admin'],
                ),
              ),
            ),
          ),
        ),
        deviceRuntimeRepositoryProvider.overrideWith(
          (ref) async => _PreviewDeviceRuntimeRepository(),
        ),
      ],
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: RealtimeDetectPage(),
      ),
    ),
  );
}

class _PreviewAuthController extends AuthController {
  _PreviewAuthController({required this.initialState});

  final AuthState initialState;

  @override
  AuthState build() => initialState;
}

class _PreviewDeviceRuntimeRepository implements DeviceRuntimeRepository {
  static const DeviceStatus _state = DeviceStatus(
    deviceId: 'preview_cabinet_a07',
    deviceName: '石斛培育柜 A07',
    temperature: 24.8,
    humidity: 82.3,
    light: 1540,
    mq2: 17,
    errorCode: 0,
    ledOn: true,
    updatedAt: 1742115000000,
  );

  @override
  Future<DeviceStatus> fetchStatus() async => _state;

  @override
  Future<Never> setLed({
    required String deviceId,
    required String deviceName,
    required bool ledOn,
  }) {
    throw UnimplementedError();
  }
}
