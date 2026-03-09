import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sickandflutter/core/config/backend_feature_profile.dart';
import 'package:sickandflutter/core/constants/app_copy.dart';
import 'package:sickandflutter/features/detect/detect_controller.dart';
import 'package:sickandflutter/features/detect/detect_page.dart';
import 'package:sickandflutter/features/detect/detect_repository.dart';
import 'package:sickandflutter/features/result/result_page.dart';
import 'package:sickandflutter/shared/models/app_enums.dart';

void main() {
  testWidgets('DetectPage shows unavailable view for current backend', (
    tester,
  ) async {
    tester.view
      ..physicalSize = const Size(1200, 1600)
      ..devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          detectControllerProvider.overrideWith(
            () => _TestDetectController(initialState: const DetectState()),
          ),
        ],
        child: const MaterialApp(home: DetectPage()),
      ),
    );

    expect(find.text(AppCopy.detectUnavailableTitle), findsOneWidget);
    expect(find.text(AppCopy.detectBackToOverview), findsOneWidget);
    expect(find.text(AppCopy.detectGoRealtime), findsOneWidget);
  });

  testWidgets('DetectPage shows inline recovery actions after detect failure', (
    tester,
  ) async {
    tester.view
      ..physicalSize = const Size(1200, 1600)
      ..devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final controller = _TestDetectController(
      initialState: DetectState(
        selectedImageFile: XFile.fromData(
          Uint8List.fromList(<int>[1, 2, 3]),
          name: 'leaf.jpg',
          mimeType: 'image/jpeg',
        ),
        selectedImageName: 'leaf.jpg',
        status: DetectTaskStatus.failed,
        errorMessage: '识别服务暂不可用，请稍后重试。',
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          detectControllerProvider.overrideWith(() => controller),
          backendFeatureProfileProvider.overrideWith(
            (ref) => const BackendFeatureProfile(
              supportsDetectService: true,
              supportsSavedResultHistory: true,
            ),
          ),
          detectUseMockProvider.overrideWith((ref) => true),
        ],
        child: const MaterialApp(home: DetectPage()),
      ),
    );
    await tester.scrollUntilVisible(
      find.text('本次识别未完成'),
      300,
      scrollable: find.byType(Scrollable),
    );

    expect(find.text('本次识别未完成'), findsOneWidget);
    expect(find.text('识别服务暂不可用，请稍后重试。'), findsOneWidget);
    expect(find.text('重新识别'), findsOneWidget);
    expect(find.text('重新选图'), findsOneWidget);

    await tester.ensureVisible(find.text('重新识别'));
    await tester.tap(find.text('重新识别'));
    await tester.pump();
    await tester.ensureVisible(find.text('重新选图'));
    await tester.tap(find.text('重新选图'));
    await tester.pump();

    expect(controller.startDetectCount, 1);
    expect(controller.pickFromGalleryCount, 1);
  });

  testWidgets(
    'DetectPage guides user to pick image when selection is missing',
    (tester) async {
      tester.view
        ..physicalSize = const Size(1200, 1600)
        ..devicePixelRatio = 1;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final controller = _TestDetectController(
        initialState: const DetectState(
          status: DetectTaskStatus.failed,
          errorMessage: '读取图片失败：权限不足。',
        ),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            detectControllerProvider.overrideWith(() => controller),
            backendFeatureProfileProvider.overrideWith(
              (ref) => const BackendFeatureProfile(
                supportsDetectService: true,
                supportsSavedResultHistory: true,
              ),
            ),
            detectUseMockProvider.overrideWith((ref) => true),
          ],
          child: const MaterialApp(home: DetectPage()),
        ),
      );
      await tester.scrollUntilVisible(
        find.text('本次识别未完成'),
        300,
        scrollable: find.byType(Scrollable),
      );

      expect(find.text('本次识别未完成'), findsOneWidget);
      expect(find.text('去选图片'), findsOneWidget);
      expect(find.text('重新选图'), findsNothing);

      await tester.ensureVisible(find.text('去选图片'));
      await tester.tap(find.text('去选图片'));
      await tester.pump();

      expect(controller.pickFromGalleryCount, 1);
      expect(controller.startDetectCount, 0);
    },
  );
}

class _TestDetectController extends DetectController {
  _TestDetectController({required this.initialState});

  final DetectState initialState;
  int startDetectCount = 0;
  int pickFromGalleryCount = 0;

  @override
  DetectState build() => initialState;

  @override
  Future<void> pickFromGallery() async {
    pickFromGalleryCount += 1;
  }

  @override
  Future<ResultPagePayload?> startDetect() async {
    startDetectCount += 1;
    return null;
  }
}
