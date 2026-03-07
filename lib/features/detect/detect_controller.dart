import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sickandflutter/features/detect/detect_repository.dart';
import 'package:sickandflutter/features/result/result_page.dart';
import 'package:sickandflutter/shared/models/app_enums.dart';

/// 单图识别页面状态入口。
final detectControllerProvider =
    NotifierProvider<DetectController, DetectState>(DetectController.new);

/// 管理选图、识别请求和错误反馈。
class DetectController extends Notifier<DetectState> {
  final ImagePicker _imagePicker = ImagePicker();

  @override
  DetectState build() => const DetectState();

  /// 从系统相册选择一张图片。
  Future<void> pickFromGallery() async {
    await _pickImage(ImageSource.gallery);
  }

  /// 调起相机拍摄一张图片。
  Future<void> pickFromCamera() async {
    await _pickImage(ImageSource.camera);
  }

  /// 清除当前已选图片和错误状态。
  void clearSelection() {
    state = const DetectState();
  }

  /// 启动单图识别，并在成功后返回结果页所需参数。
  Future<ResultPagePayload?> startDetect() async {
    if (!state.hasImage) {
      state = state.copyWith(
        status: DetectTaskStatus.failed,
        errorMessage: '请先选择一张石斛图片。',
      );
      return null;
    }

    final imagePath = state.selectedImagePath!;
    final fileName = state.selectedImageName ?? 'selected_image.jpg';
    state = state.copyWith(
      status: DetectTaskStatus.running,
      errorMessage: null,
    );

    try {
      final response = await ref
          .read(detectRepositoryProvider)
          .detectImage(imagePath: imagePath, fileName: fileName);

      state = state.copyWith(status: DetectTaskStatus.success);
      return ResultPagePayload(
        result: response,
        sourceImagePath: imagePath,
        canSave: true,
      );
    } catch (error) {
      state = state.copyWith(
        status: DetectTaskStatus.failed,
        errorMessage: '识别失败：$error',
      );
      return null;
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final file = await _imagePicker.pickImage(
        source: source,
        maxWidth: 2400,
        imageQuality: 92,
      );

      if (file == null) {
        return;
      }

      state = state.copyWith(
        selectedImagePath: file.path,
        selectedImageName: file.name,
        status: DetectTaskStatus.idle,
        errorMessage: null,
      );
    } catch (error) {
      state = state.copyWith(
        status: DetectTaskStatus.failed,
        errorMessage: '读取图片失败：$error',
      );
    }
  }
}

/// 单图识别页的视图状态。
class DetectState {
  /// 创建单图识别页面状态对象。
  const DetectState({
    this.selectedImagePath,
    this.selectedImageName,
    this.status = DetectTaskStatus.idle,
    this.errorMessage,
  });

  /// 当前已选图片路径。
  final String? selectedImagePath;

  /// 当前已选图片文件名。
  final String? selectedImageName;

  /// 当前识别任务状态。
  final DetectTaskStatus status;

  /// 最近一次失败或校验错误信息。
  final String? errorMessage;

  /// 当前是否已经选择可识别图片。
  bool get hasImage => (selectedImagePath ?? '').isNotEmpty;

  /// 返回带增量修改的新状态对象。
  DetectState copyWith({
    String? selectedImagePath,
    String? selectedImageName,
    DetectTaskStatus? status,
    String? errorMessage,
  }) {
    return DetectState(
      selectedImagePath: selectedImagePath ?? this.selectedImagePath,
      selectedImageName: selectedImageName ?? this.selectedImageName,
      status: status ?? this.status,
      errorMessage: errorMessage,
    );
  }
}
