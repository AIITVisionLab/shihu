import 'package:flutter/material.dart';
import 'package:sickandflutter/core/constants/app_copy.dart';
import 'package:sickandflutter/shared/widgets/common_button.dart';
import 'package:sickandflutter/shared/widgets/common_card.dart';

/// 视频服务失败态卡片。
class VideoServiceErrorCard extends StatelessWidget {
  /// 创建视频服务失败态卡片。
  const VideoServiceErrorCard({
    required this.serviceBaseUrl,
    required this.error,
    required this.onRetry,
    this.onCopyServiceUrl,
    super.key,
  });

  /// 当前视频服务地址。
  final String serviceBaseUrl;

  /// 失败原因。
  final Object error;

  /// 重试回调。
  final VoidCallback onRetry;

  /// 复制服务地址回调。
  final VoidCallback? onCopyServiceUrl;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return CommonCard(
      title: AppCopy.videoServiceErrorTitle,
      subtitle: AppCopy.videoServiceErrorSubtitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: colorScheme.errorContainer.withValues(alpha: 0.56),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Text(
              AppCopy.videoServiceErrorMessage(error),
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '当前地址：$serviceBaseUrl',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 10),
          Text(
            '该服务应返回 `/api/video/streams` 和 `/api/video/streams/{streamId}` 的 JSON 数据；当服务恢复后，客户端无需改版即可直接展示流清单。',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 18),
          CommonButton(
            label: AppCopy.retry,
            icon: const Icon(Icons.refresh_rounded),
            onPressed: onRetry,
          ),
          if (onCopyServiceUrl != null) ...<Widget>[
            const SizedBox(height: 12),
            CommonButton(
              label: AppCopy.videoCopyServiceUrl,
              tone: CommonButtonTone.secondary,
              icon: const Icon(Icons.content_copy_rounded),
              onPressed: onCopyServiceUrl,
            ),
          ],
        ],
      ),
    );
  }
}
