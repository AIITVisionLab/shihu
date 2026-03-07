import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sickandflutter/features/history/history_repository.dart';
import 'package:sickandflutter/shared/models/app_enums.dart';
import 'package:sickandflutter/shared/models/detect_response.dart';
import 'package:sickandflutter/shared/models/history_record.dart';
import 'package:sickandflutter/shared/widgets/adaptive_image.dart';
import 'package:sickandflutter/shared/widgets/common_button.dart';
import 'package:sickandflutter/shared/widgets/common_card.dart';
import 'package:sickandflutter/shared/widgets/empty_view.dart';
import 'package:sickandflutter/shared/widgets/result_info_card.dart';

/// 结果页路由参数。
class ResultPagePayload {
  /// 创建结果页路由参数。
  const ResultPagePayload({
    required this.result,
    required this.sourceImagePath,
    required this.canSave,
  });

  /// 识别结果数据。
  final DetectResponse result;

  /// 结果对应的源图片路径。
  final String? sourceImagePath;

  /// 当前结果页是否允许再次保存。
  final bool canSave;
}

/// 识别结果详情页，负责展示摘要、检测列表和防治建议。
class ResultPage extends ConsumerWidget {
  /// 创建结果详情页。
  const ResultPage({required this.payload, super.key});

  /// 页面渲染和保存操作所需参数。
  final ResultPagePayload payload;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final result = payload.result;
    final severityColor = _severityColor(context, result.summary.severityLevel);
    final previewPath = _previewPath(result);

    return Scaffold(
      appBar: AppBar(title: const Text('识别结果')),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: <Widget>[
                if (previewPath != null) ...<Widget>[
                  CommonCard(
                    title: '结果图区域',
                    child: AspectRatio(
                      aspectRatio: 16 / 9,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(22),
                        child: AdaptiveImage(
                          previewPath,
                          errorBuilder: (context) =>
                              const ColoredBox(color: Color(0xFFE8EFE6)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: <Widget>[
                    SizedBox(
                      width: 330,
                      child: ResultInfoCard(
                        title: '主识别结果',
                        value: result.summary.primaryLabelName,
                        subtitle: result.summary.category.label,
                        leading: Icon(
                          Icons.spa_rounded,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 330,
                      child: ResultInfoCard(
                        title: '置信度',
                        value:
                            '${(result.summary.confidence * 100).toStringAsFixed(2)}%',
                        subtitle: '识别时间：${_formatDate(result.capturedAt)}',
                      ),
                    ),
                    SizedBox(
                      width: 330,
                      child: ResultInfoCard(
                        title: '严重程度',
                        value: result.summary.severityLevel.label,
                        subtitle: '健康状态：${result.summary.healthStatus.label}',
                        valueColor: severityColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                if (result.detections.isEmpty)
                  const CommonCard(
                    child: EmptyView(
                      title: '未检测到明显异常',
                      message: '这次识别没有返回检测框，但仍然会保留摘要结果和建议信息。',
                    ),
                  )
                else
                  CommonCard(
                    title: '检测列表',
                    child: Column(
                      children: result.detections
                          .map(
                            (item) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: CommonCard(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        color: severityColor.withValues(
                                          alpha: 0.12,
                                        ),
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      child: Icon(
                                        Icons.crop_square_rounded,
                                        color: severityColor,
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Text(
                                            item.labelName,
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleMedium
                                                ?.copyWith(
                                                  fontWeight: FontWeight.w700,
                                                ),
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            '类别：${item.category.label}  ·  置信度：${(item.confidence * 100).toStringAsFixed(2)}%',
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            '检测框：x=${item.bbox.x.toStringAsFixed(2)}, y=${item.bbox.y.toStringAsFixed(2)}, w=${item.bbox.width.toStringAsFixed(2)}, h=${item.bbox.height.toStringAsFixed(2)}',
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                          .toList(growable: false),
                    ),
                  ),
                const SizedBox(height: 20),
                if (result.advice != null)
                  CommonCard(
                    title: '防治建议',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          result.advice!.title,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 10),
                        Text(result.advice!.summary),
                        const SizedBox(height: 12),
                        ...result.advice!.preventionSteps.map(
                          (step) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                const Padding(
                                  padding: EdgeInsets.only(top: 5),
                                  child: Icon(
                                    Icons.check_circle_outline,
                                    size: 18,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(child: Text(step)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 20),
                if (payload.canSave)
                  CommonButton(
                    label: '保存到历史记录',
                    icon: const Icon(Icons.bookmark_add_outlined),
                    onPressed: () async {
                      final record = HistoryRecord.fromDetectResponse(
                        response: result,
                        sourceImagePath: payload.sourceImagePath,
                      );
                      await ref
                          .read(historyControllerProvider.notifier)
                          .saveRecord(record);

                      if (!context.mounted) {
                        return;
                      }

                      ScaffoldMessenger.of(context)
                        ..hideCurrentSnackBar()
                        ..showSnackBar(
                          const SnackBar(content: Text('识别结果已保存到历史记录。')),
                        );
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _severityColor(BuildContext context, SeverityLevel severityLevel) {
    switch (severityLevel) {
      case SeverityLevel.none:
        return const Color(0xFF2E7D32);
      case SeverityLevel.low:
        return const Color(0xFF6C8A16);
      case SeverityLevel.medium:
        return const Color(0xFFEF6C00);
      case SeverityLevel.high:
      case SeverityLevel.critical:
        return Theme.of(context).colorScheme.error;
    }
  }

  String? _previewPath(DetectResponse result) {
    final candidates = <String?>[
      payload.sourceImagePath,
      result.imageInfo?.annotatedUrl,
      result.imageInfo?.originalUrl,
    ];

    for (final candidate in candidates) {
      if ((candidate ?? '').isNotEmpty) {
        return candidate;
      }
    }

    return null;
  }

  String _formatDate(String isoString) {
    final dateTime = DateTime.tryParse(isoString);
    if (dateTime == null) {
      return isoString;
    }

    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
