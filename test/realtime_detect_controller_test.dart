import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sickandflutter/features/realtime/mock_realtime_detect_repository.dart';
import 'package:sickandflutter/features/realtime/realtime_detect_controller.dart';
import 'package:sickandflutter/features/realtime/realtime_detect_repository.dart';
import 'package:sickandflutter/shared/models/app_enums.dart';

void main() {
  test(
    'RealtimeDetectController starts, pauses and resumes test session',
    () async {
      final container = ProviderContainer(
        overrides: [
          realtimeDetectRepositoryProvider.overrideWith(
            (ref) => const MockRealtimeDetectRepository(
              responseDelay: Duration.zero,
            ),
          ),
          realtimeDetectPollingIntervalProvider.overrideWith(
            (ref) => const Duration(seconds: 30),
          ),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(
        realtimeDetectControllerProvider.notifier,
      );

      expect(
        container.read(realtimeDetectControllerProvider).status,
        RealtimeSessionStatus.idle,
      );

      await notifier.startSession();
      final startedState = container.read(realtimeDetectControllerProvider);
      expect(startedState.status, RealtimeSessionStatus.running);
      expect(startedState.frameIndex, 1);
      expect(startedState.latestResult?.sourceType, SourceType.realtime);

      notifier.pauseSession();
      expect(
        container.read(realtimeDetectControllerProvider).status,
        RealtimeSessionStatus.paused,
      );

      await notifier.resumeSession();
      final resumedState = container.read(realtimeDetectControllerProvider);
      expect(resumedState.status, RealtimeSessionStatus.running);
      expect(resumedState.frameIndex, 2);
    },
  );

  test(
    'RealtimeDetectController advances frame index while session is running',
    () async {
      final container = ProviderContainer(
        overrides: [
          realtimeDetectRepositoryProvider.overrideWith(
            (ref) => const MockRealtimeDetectRepository(
              responseDelay: Duration.zero,
            ),
          ),
          realtimeDetectPollingIntervalProvider.overrideWith(
            (ref) => const Duration(milliseconds: 20),
          ),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(
        realtimeDetectControllerProvider.notifier,
      );

      await notifier.startSession();
      final initialFrameIndex = container
          .read(realtimeDetectControllerProvider)
          .frameIndex;

      await Future<void>.delayed(const Duration(milliseconds: 60));
      final advancedFrameIndex = container
          .read(realtimeDetectControllerProvider)
          .frameIndex;

      expect(advancedFrameIndex, greaterThan(initialFrameIndex));

      notifier.pauseSession();
      final pausedFrameIndex = container
          .read(realtimeDetectControllerProvider)
          .frameIndex;

      await Future<void>.delayed(const Duration(milliseconds: 60));
      expect(
        container.read(realtimeDetectControllerProvider).frameIndex,
        pausedFrameIndex,
      );
    },
  );
}
