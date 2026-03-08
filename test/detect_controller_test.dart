import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sickandflutter/core/network/api_exception.dart';
import 'package:sickandflutter/features/detect/detect_controller.dart';
import 'package:sickandflutter/features/detect/detect_repository.dart';
import 'package:sickandflutter/shared/models/app_enums.dart';
import 'package:sickandflutter/shared/models/detect_response.dart';
import 'package:sickandflutter/shared/models/detect_summary.dart';
import 'package:sickandflutter/shared/models/detection_item.dart';

void main() {
  test(
    'DetectController rejects detect request when no image is selected',
    () async {
      final container = ProviderContainer(
        overrides: [
          detectControllerProvider.overrideWith(
            () => _TestDetectController(initialState: const DetectState()),
          ),
          detectRepositoryProvider.overrideWith(
            (ref) => _FakeDetectRepository.success(_buildResponse()),
          ),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(detectControllerProvider.notifier);
      final payload = await notifier.startDetect();
      final state = container.read(detectControllerProvider);

      expect(payload, isNull);
      expect(state.status, DetectTaskStatus.failed);
      expect(state.errorMessage, '请先选择一张石斛图片。');
    },
  );

  test(
    'DetectController returns payload and marks success after detect succeeds',
    () async {
      final response = _buildResponse();
      final container = ProviderContainer(
        overrides: [
          detectControllerProvider.overrideWith(
            () => _TestDetectController(
              initialState: DetectState(
                selectedImageFile: XFile.fromData(
                  Uint8List.fromList(<int>[1, 2, 3]),
                  name: 'leaf.jpg',
                  mimeType: 'image/jpeg',
                ),
                selectedImagePath: '/tmp/leaf.jpg',
                selectedImageName: 'leaf.jpg',
              ),
            ),
          ),
          detectRepositoryProvider.overrideWith(
            (ref) => _FakeDetectRepository.success(response),
          ),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(detectControllerProvider.notifier);
      final payload = await notifier.startDetect();
      final state = container.read(detectControllerProvider);

      expect(state.status, DetectTaskStatus.success);
      expect(state.errorMessage, isNull);
      expect(payload, isNotNull);
      expect(payload!.result.detectId, response.detectId);
      expect(payload.sourceImagePath, '/tmp/leaf.jpg');
      expect(payload.canSave, isTrue);
    },
  );

  test(
    'DetectController keeps failed state when repository throws ApiException',
    () async {
      final container = ProviderContainer(
        overrides: [
          detectControllerProvider.overrideWith(
            () => _TestDetectController(
              initialState: DetectState(
                selectedImageFile: XFile.fromData(
                  Uint8List.fromList(<int>[1, 2, 3]),
                  name: 'leaf.jpg',
                  mimeType: 'image/jpeg',
                ),
                selectedImagePath: '/tmp/leaf.jpg',
                selectedImageName: 'leaf.jpg',
              ),
            ),
          ),
          detectRepositoryProvider.overrideWith(
            (ref) => _FakeDetectRepository.failure(
              const ApiException(message: '识别服务暂不可用，请稍后重试。'),
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(detectControllerProvider.notifier);
      final payload = await notifier.startDetect();
      final state = container.read(detectControllerProvider);

      expect(payload, isNull);
      expect(state.status, DetectTaskStatus.failed);
      expect(state.errorMessage, '识别服务暂不可用，请稍后重试。');
    },
  );
}

class _TestDetectController extends DetectController {
  _TestDetectController({required this.initialState});

  final DetectState initialState;

  @override
  DetectState build() => initialState;
}

class _FakeDetectRepository implements DetectRepository {
  const _FakeDetectRepository.success(this.response) : error = null;
  const _FakeDetectRepository.failure(this.error) : response = null;

  final DetectResponse? response;
  final ApiException? error;

  @override
  Future<DetectResponse> detectImage({required XFile imageFile}) async {
    if (error case final apiError?) {
      throw apiError;
    }

    return response!;
  }
}

DetectResponse _buildResponse() {
  return const DetectResponse(
    detectId: 'det_20260308_0001',
    sourceType: SourceType.image,
    capturedAt: '2026-03-08T10:00:00+08:00',
    summary: DetectSummary(
      primaryLabelCode: 'disease_black_spot',
      primaryLabelName: '黑斑病',
      category: DetectionCategory.disease,
      confidence: 0.9721,
      severityLevel: SeverityLevel.medium,
      severityScore: 0.66,
      healthStatus: HealthStatus.abnormal,
    ),
    detections: <DetectionItem>[],
  );
}
