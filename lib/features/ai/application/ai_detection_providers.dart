import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sickandflutter/core/network/api_client_factory.dart';
import 'package:sickandflutter/features/ai/domain/ai_detection_summary.dart';
import 'package:sickandflutter/features/ai/infrastructure/ai_detection_repository.dart';
import 'package:sickandflutter/features/preview/preview_workspace_seed.dart';
import 'package:sickandflutter/features/service_config/application/service_config_providers.dart';

/// AI 检测仓储 Provider。
final aiDetectionRepositoryProvider = Provider<AiDetectionRepository>((ref) {
  final settings = ref.watch(resolvedDeviceServiceSettingsProvider);
  final apiClientFactory = ref.watch(apiClientFactoryProvider);

  return AiDetectionRepository(
    apiClient: apiClientFactory.create(settings: settings),
  );
});

/// 值守台使用的 AI 检测总览 Provider。
final aiDetectionOverviewProvider =
    FutureProvider.autoDispose<AiDetectionOverview>((ref) async {
      if (ref.watch(previewWorkspaceEnabledProvider)) {
        return ref.watch(previewAiDetectionOverviewProvider);
      }

      final repository = ref.watch(aiDetectionRepositoryProvider);
      final latestFuture = repository.fetchLatest();
      final historyFuture = repository.fetchHistory(limit: 6);

      return AiDetectionOverview(
        latest: await latestFuture,
        history: await historyFuture,
      );
    });
