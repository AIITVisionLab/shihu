import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sickandflutter/core/network/api_client_factory.dart';
import 'package:sickandflutter/features/platform_logs/domain/platform_log_entry.dart';
import 'package:sickandflutter/features/platform_logs/infrastructure/platform_log_repository.dart';
import 'package:sickandflutter/features/preview/preview_workspace_seed.dart';
import 'package:sickandflutter/features/service_config/application/service_config_providers.dart';

/// 平台日志仓储 Provider。
final platformLogRepositoryProvider = Provider<PlatformLogRepository>((ref) {
  final settings = ref.watch(resolvedDeviceServiceSettingsProvider);
  final apiClientFactory = ref.watch(apiClientFactoryProvider);

  return PlatformLogRepository(
    apiClient: apiClientFactory.create(settings: settings),
  );
});

/// 设置页的平台日志查询条件。
final platformLogQueryProvider =
    NotifierProvider<PlatformLogQueryController, PlatformLogQuery>(
      PlatformLogQueryController.new,
    );

/// 管理设置页平台日志查询条件。
class PlatformLogQueryController extends Notifier<PlatformLogQuery> {
  @override
  PlatformLogQuery build() => const PlatformLogQuery();

  /// 更新当前查询条件。
  void updateQuery(PlatformLogQuery query) {
    state = query;
  }

  /// 重置为默认查询条件。
  void reset() {
    state = const PlatformLogQuery();
  }
}

/// 设置页使用的平台日志总览 Provider。
final platformLogOverviewProvider =
    FutureProvider.autoDispose<PlatformLogOverview>((ref) async {
      final query = ref.watch(platformLogQueryProvider);
      if (ref.watch(previewWorkspaceEnabledProvider)) {
        final overview = ref.watch(previewPlatformLogOverviewProvider);
        final recentEntries = overview.recentEntries
            .where((entry) => _matchesQuery(entry, query))
            .take(query.limit)
            .toList(growable: false);
        return PlatformLogOverview(
          summary: overview.summary,
          recentEntries: recentEntries,
        );
      }

      final repository = ref.watch(platformLogRepositoryProvider);
      final summaryFuture = repository.fetchSummary();
      final recentFuture = repository.fetchRecent(
        type: query.normalizedType.isEmpty ? null : query.normalizedType,
        keyword: query.normalizedKeyword.isEmpty
            ? null
            : query.normalizedKeyword,
        limit: query.limit,
      );

      return PlatformLogOverview(
        summary: await summaryFuture,
        recentEntries: await recentFuture,
      );
    });

bool _matchesQuery(PlatformLogEntry entry, PlatformLogQuery query) {
  if (query.normalizedType.isNotEmpty &&
      entry.type.trim().toUpperCase() != query.normalizedType) {
    return false;
  }

  final keyword = query.normalizedKeyword.toLowerCase();
  if (keyword.isEmpty) {
    return true;
  }

  final haystacks = <String>[
    entry.eventId,
    entry.type,
    entry.deviceId,
    entry.summary,
    entry.detailsPreview,
  ].map((value) => value.toLowerCase());
  return haystacks.any((value) => value.contains(keyword));
}
