import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sickandflutter/app/routes.dart';
import 'package:sickandflutter/core/config/backend_feature_profile.dart';
import 'package:sickandflutter/core/constants/app_copy.dart';
import 'package:sickandflutter/features/history/history_repository.dart';
import 'package:sickandflutter/features/result/result_page.dart';
import 'package:sickandflutter/shared/models/app_enums.dart';
import 'package:sickandflutter/shared/models/history_record.dart';
import 'package:sickandflutter/shared/widgets/adaptive_image.dart';
import 'package:sickandflutter/shared/widgets/common_card.dart';
import 'package:sickandflutter/shared/widgets/empty_view.dart';
import 'package:sickandflutter/shared/widgets/loading_view.dart';

/// 历史记录页，负责浏览、删除和打开历史结果。
class HistoryPage extends ConsumerWidget {
  /// 创建历史记录页。
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(historyControllerProvider);
    final featureProfile = ref.watch(backendFeatureProfileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('历史记录'),
        actions: <Widget>[
          IconButton(
            tooltip: '清空历史',
            onPressed: historyAsync.asData?.value.isNotEmpty == true
                ? () async {
                    final confirmed = await _confirmAction(
                      context,
                      title: '清空历史记录',
                      message: '该操作会删除全部本地历史记录，且不可恢复。',
                    );

                    if (!confirmed) {
                      return;
                    }

                    await ref
                        .read(historyControllerProvider.notifier)
                        .clearAll();
                  }
                : null,
            icon: const Icon(Icons.delete_sweep_outlined),
          ),
        ],
      ),
      body: SafeArea(
        child: historyAsync.when(
          loading: () => const LoadingView(message: '正在加载历史记录...'),
          error: (error, stackTrace) => EmptyView(
            title: '历史记录加载失败',
            message: '$error',
            actionLabel: '重新加载',
            onAction: () => ref.invalidate(historyControllerProvider),
          ),
          data: (records) {
            if (records.isEmpty) {
              return EmptyView(
                title: '还没有历史记录',
                message: featureProfile.supportsSavedResultHistory
                    ? '先完成一次单图识别并保存结果，再回到这里查看详情。'
                    : AppCopy.historyEmptyWithoutDetect,
              );
            }

            return Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 980),
                child: ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: records.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 14),
                  itemBuilder: (context, index) {
                    final record = records[index];

                    return InkWell(
                      borderRadius: BorderRadius.circular(24),
                      onTap: () {
                        context.pushNamed(
                          AppRoutes.result,
                          extra: ResultPagePayload(
                            result: record.response,
                            sourceImagePath: record.sourceImagePath,
                            canSave: false,
                          ),
                        );
                      },
                      child: CommonCard(
                        child: Row(
                          children: <Widget>[
                            _HistoryThumbnail(record: record),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    record.item.primaryLabelName,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(fontWeight: FontWeight.w700),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '类别：${record.item.category.label}  ·  严重程度：${record.item.severityLevel.label}',
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    '置信度：${(record.item.confidence * 100).toStringAsFixed(2)}%  ·  时间：${_formatDate(record.item.capturedAt)}',
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            IconButton(
                              tooltip: '删除记录',
                              onPressed: () async {
                                final confirmed = await _confirmAction(
                                  context,
                                  title: '删除历史记录',
                                  message: '删除后无法恢复，是否继续？',
                                );

                                if (!confirmed) {
                                  return;
                                }

                                await ref
                                    .read(historyControllerProvider.notifier)
                                    .deleteRecord(record.item.historyId);
                              },
                              icon: const Icon(Icons.delete_outline),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  static Future<bool> _confirmAction(
    BuildContext context, {
    required String title,
    required String message,
  }) async {
    return (await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: const Text('取消'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: const Text('确认'),
              ),
            ],
          ),
        )) ??
        false;
  }

  String _formatDate(String isoString) {
    final dateTime = DateTime.tryParse(isoString);
    if (dateTime == null) {
      return isoString;
    }

    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}

class _HistoryThumbnail extends StatelessWidget {
  const _HistoryThumbnail({required this.record});

  final HistoryRecord record;

  @override
  Widget build(BuildContext context) {
    final previewPath = record.sourceImagePath ?? record.item.coverUrl;

    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: SizedBox(
        width: 108,
        height: 108,
        child: previewPath == null
            ? const DecoratedBox(
                decoration: BoxDecoration(color: Color(0xFFE8EFE6)),
                child: Icon(Icons.image_outlined),
              )
            : AdaptiveImage(
                previewPath,
                errorBuilder: (context) => const DecoratedBox(
                  decoration: BoxDecoration(color: Color(0xFFE8EFE6)),
                  child: Icon(Icons.image_not_supported_outlined),
                ),
              ),
      ),
    );
  }
}
