import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 当前工作区后端能力画像 Provider。
final backendFeatureProfileProvider = Provider<BackendFeatureProfile>((ref) {
  return const BackendFeatureProfile.currentWebBackend();
});

/// 描述当前已并入工作区的后端能力边界。
class BackendFeatureProfile {
  /// 创建后端能力画像。
  const BackendFeatureProfile({
    required this.supportsDetectService,
    required this.supportsSavedResultHistory,
  });

  /// 当前 `origin/web` 后端对应的能力画像。
  const BackendFeatureProfile.currentWebBackend()
    : supportsDetectService = false,
      supportsSavedResultHistory = false;

  /// 是否已接入独立单图识别服务。
  final bool supportsDetectService;

  /// 是否已形成可持续新增的识别结果历史能力。
  final bool supportsSavedResultHistory;

  /// 返回带增量修改的新能力画像。
  BackendFeatureProfile copyWith({
    bool? supportsDetectService,
    bool? supportsSavedResultHistory,
  }) {
    return BackendFeatureProfile(
      supportsDetectService:
          supportsDetectService ?? this.supportsDetectService,
      supportsSavedResultHistory:
          supportsSavedResultHistory ?? this.supportsSavedResultHistory,
    );
  }
}
