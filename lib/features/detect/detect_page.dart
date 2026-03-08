import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sickandflutter/app/routes.dart';
import 'package:sickandflutter/core/constants/app_copy.dart';
import 'package:sickandflutter/features/detect/detect_controller.dart';
import 'package:sickandflutter/shared/models/app_enums.dart';
import 'package:sickandflutter/shared/widgets/adaptive_image.dart';
import 'package:sickandflutter/shared/widgets/common_button.dart';
import 'package:sickandflutter/shared/widgets/common_card.dart';

/// 单图识别页，负责选图、预览和触发识别主流程。
class DetectPage extends ConsumerWidget {
  /// 创建单图识别页。
  const DetectPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(detectControllerProvider);
    final controller = ref.read(detectControllerProvider.notifier);
    final isRunning = state.status == DetectTaskStatus.running;

    Future<void> handleStartDetect() async {
      final payload = await controller.startDetect();
      if (payload == null || !context.mounted) {
        return;
      }

      await context.pushNamed(AppRoutes.result, extra: payload);
    }

    return Scaffold(
      appBar: AppBar(title: const Text(AppCopy.detectPageTitle)),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 960),
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: <Widget>[
                CommonCard(
                  title: AppCopy.detectGuideTitle,
                  subtitle: AppCopy.detectGuideSubtitle,
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: const <Widget>[
                      Chip(label: Text(AppCopy.detectGalleryChip)),
                      Chip(label: Text(AppCopy.detectCameraChip)),
                      Chip(label: Text(AppCopy.detectHistoryChip)),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                CommonCard(
                  title: AppCopy.detectPreviewTitle,
                  subtitle: AppCopy.detectPreviewSubtitle,
                  child: Column(
                    children: <Widget>[
                      _PreviewBox(imagePath: state.selectedImagePath),
                      const SizedBox(height: 16),
                      if (state.selectedImageName != null)
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            AppCopy.detectCurrentFile(state.selectedImageName!),
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                CommonCard(
                  title: AppCopy.detectActionsTitle,
                  child: Column(
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: CommonButton(
                              label: AppCopy.detectPickFromGallery,
                              tone: CommonButtonTone.secondary,
                              icon: const Icon(Icons.photo_library_outlined),
                              onPressed: isRunning
                                  ? null
                                  : controller.pickFromGallery,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: CommonButton(
                              label: AppCopy.detectPickFromCamera,
                              tone: CommonButtonTone.secondary,
                              icon: const Icon(Icons.camera_alt_outlined),
                              onPressed: isRunning
                                  ? null
                                  : controller.pickFromCamera,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: CommonButton(
                              label: AppCopy.detectClearSelection,
                              tone: CommonButtonTone.secondary,
                              icon: const Icon(Icons.refresh_rounded),
                              onPressed: isRunning
                                  ? null
                                  : controller.clearSelection,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: CommonButton(
                              label: isRunning
                                  ? AppCopy.detectRunning
                                  : AppCopy.detectStart,
                              isLoading: isRunning,
                              icon: const Icon(Icons.play_arrow_rounded),
                              onPressed: state.hasImage && !isRunning
                                  ? handleStartDetect
                                  : null,
                            ),
                          ),
                        ],
                      ),
                      if (state.errorMessage case final message?
                          when message.isNotEmpty) ...<Widget>[
                        const SizedBox(height: 16),
                        _DetectErrorPanel(
                          message: message,
                          hasImage: state.hasImage,
                          isRunning: isRunning,
                          onRetry: handleStartDetect,
                          onRepick: controller.pickFromGallery,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DetectErrorPanel extends StatelessWidget {
  const _DetectErrorPanel({
    required this.message,
    required this.hasImage,
    required this.isRunning,
    required this.onRetry,
    required this.onRepick,
  });

  final String message;
  final bool hasImage;
  final bool isRunning;
  final VoidCallback onRetry;
  final VoidCallback onRepick;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.error),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(
                  Icons.error_outline_rounded,
                  color: colorScheme.onErrorContainer,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    AppCopy.detectFailedTitle,
                    style: textTheme.titleMedium?.copyWith(
                      color: colorScheme.onErrorContainer,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onErrorContainer,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: <Widget>[
                CommonButton(
                  label: hasImage ? AppCopy.detectRetry : AppCopy.detectRepick,
                  tone: CommonButtonTone.secondary,
                  icon: Icon(
                    hasImage
                        ? Icons.replay_rounded
                        : Icons.photo_library_outlined,
                  ),
                  onPressed: isRunning ? null : (hasImage ? onRetry : onRepick),
                ),
                if (hasImage)
                  CommonButton(
                    label: AppCopy.detectRechoose,
                    tone: CommonButtonTone.secondary,
                    icon: const Icon(Icons.collections_outlined),
                    onPressed: isRunning ? null : onRepick,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PreviewBox extends StatelessWidget {
  const _PreviewBox({required this.imagePath});

  final String? imagePath;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xFFE8EFE6),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: imagePath == null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Icon(
                        Icons.add_photo_alternate_outlined,
                        size: 48,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(height: 14),
                      Text(
                        AppCopy.detectEmptyPreview,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                )
              : AdaptiveImage(
                  imagePath!,
                  errorBuilder: (context) => Center(
                    child: Text(
                      AppCopy.detectPreviewUnavailable,
                      style: Theme.of(context).textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
