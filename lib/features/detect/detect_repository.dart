import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sickandflutter/features/detect/mock_detect_repository.dart';
import 'package:sickandflutter/shared/models/detect_response.dart';

/// 单图识别仓储入口。
final detectRepositoryProvider = Provider<DetectRepository>((ref) {
  return const MockDetectRepository();
});

/// 单图识别服务统一入口。
///
/// 开发和测试环境可以切换到受控替身实现，
/// 正式环境应固定到真实接口实现。
abstract class DetectRepository {
  /// 根据图片路径执行一次识别并返回标准结果。
  Future<DetectResponse> detectImage({
    required String imagePath,
    required String fileName,
  });
}
