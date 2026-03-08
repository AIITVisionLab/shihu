import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sickandflutter/app/routes.dart';
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
    ref.listen<DetectState>(detectControllerProvider, (previous, next) {
      final previousError = previous?.errorMessage;
      final nextError = next.errorMessage;
      if (nextError != null &&
          nextError.isNotEmpty &&
          nextError != previousError) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(nextError)));
      }
    });

    final state = ref.watch(detectControllerProvider);
    final controller = ref.read(detectControllerProvider.notifier);
    final isRunning = state.status == DetectTaskStatus.running;

    return Scaffold(
      appBar: AppBar(title: const Text('单图识别')),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 960),
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: <Widget>[
                CommonCard(
                  title: '识别说明',
                  subtitle:
                      '当前默认调用真实识别接口；开发或测试环境如需演示稳定结果，可通过 dart-define 切回 mock。',
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: const <Widget>[
                      Chip(label: Text('支持本地选图')),
                      Chip(label: Text('支持相机入口')),
                      Chip(label: Text('识别结果可保存为历史记录')),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                CommonCard(
                  title: '图片预览',
                  subtitle: '桌面端拖拽入口已预留，这一轮先保证各平台都能通过文件选择进入识别。',
                  child: Column(
                    children: <Widget>[
                      _PreviewBox(imagePath: state.selectedImagePath),
                      const SizedBox(height: 16),
                      if (state.selectedImageName != null)
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            '当前文件：${state.selectedImageName}',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                CommonCard(
                  title: '操作区',
                  child: Column(
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: CommonButton(
                              label: '从相册选择',
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
                              label: '使用相机',
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
                              label: '清空选择',
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
                              label: isRunning ? '识别中...' : '开始识别',
                              isLoading: isRunning,
                              icon: const Icon(Icons.play_arrow_rounded),
                              onPressed: state.hasImage && !isRunning
                                  ? () async {
                                      final payload = await controller
                                          .startDetect();
                                      if (payload == null || !context.mounted) {
                                        return;
                                      }

                                      await context.pushNamed(
                                        AppRoutes.result,
                                        extra: payload,
                                      );
                                    }
                                  : null,
                            ),
                          ),
                        ],
                      ),
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
                        '请选择石斛图片后开始识别',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                )
              : AdaptiveImage(
                  imagePath!,
                  errorBuilder: (context) => Center(
                    child: Text(
                      '当前平台无法预览该图片，但识别链路已接通。',
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
