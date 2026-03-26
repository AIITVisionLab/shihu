import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sickandflutter/features/auth/auth_controller.dart';
import 'package:sickandflutter/features/auth/auth_session.dart';
import 'package:sickandflutter/features/auth/auth_user.dart';
import 'package:sickandflutter/features/device/application/device_runtime_providers.dart';
import 'package:sickandflutter/features/preview/preview_workspace_seed.dart';
import 'package:sickandflutter/features/service_config/application/service_config_providers.dart';
import 'package:sickandflutter/features/video/video_stream_repository.dart';
import 'package:sickandflutter/shared/models/app_enums.dart';

void main() {
  test(
    'preview workspace serves local device state and supports led toggle',
    () async {
      final container = ProviderContainer(
        overrides: [
          authControllerProvider.overrideWith(() => _PreviewAuthController()),
        ],
      );
      addTearDown(container.dispose);

      expect(container.read(previewWorkspaceEnabledProvider), isTrue);

      final repository = await container.read(
        deviceRuntimeRepositoryProvider.future,
      );
      final initialStatus = await repository.fetchStatus();

      expect(initialStatus.deviceId, 'preview_cabinet_a07');
      expect(initialStatus.deviceName, '兰棚 A-07 培育柜');
      expect(initialStatus.ledOn, isTrue);

      await repository.setLed(
        deviceId: initialStatus.deviceId,
        deviceName: initialStatus.deviceName,
        ledOn: false,
      );
      final updatedStatus = await repository.fetchStatus();

      expect(updatedStatus.ledOn, isFalse);
      expect(updatedStatus.light, lessThan(initialStatus.light!));
    },
  );

  test(
    'preview workspace serves local video streams and service health',
    () async {
      final container = ProviderContainer(
        overrides: [
          authControllerProvider.overrideWith(() => _PreviewAuthController()),
        ],
      );
      addTearDown(container.dispose);

      final streams = await container.read(videoStreamListProvider.future);
      final health = await container.read(serviceHealthProvider.future);

      expect(streams, hasLength(3));
      expect(streams.first.displayName, '温室主画面');
      expect(streams.first.available, isTrue);
      expect(health.status, 'up');
      expect(health.responseText, contains('本地样例数据'));
    },
  );
}

class _PreviewAuthController extends AuthController {
  @override
  AuthState build() {
    return const AuthState(
      isBootstrapping: false,
      session: AuthSession(
        accessToken: 'preview_access',
        loginMode: AuthLoginMode.mock,
        user: AuthUser(
          userId: 'preview_user',
          account: 'preview',
          displayName: '界面预览',
        ),
      ),
    );
  }
}
