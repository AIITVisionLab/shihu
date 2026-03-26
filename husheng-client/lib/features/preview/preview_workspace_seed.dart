import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sickandflutter/features/ai/domain/ai_detection_summary.dart';
import 'package:sickandflutter/features/auth/auth_controller.dart';
import 'package:sickandflutter/features/device/domain/device_runtime_repository.dart';
import 'package:sickandflutter/features/device/domain/device_status.dart';
import 'package:sickandflutter/features/device/domain/led_operation_receipt.dart';
import 'package:sickandflutter/features/platform_logs/domain/platform_log_entry.dart';
import 'package:sickandflutter/features/video/video_stream_info.dart';
import 'package:sickandflutter/shared/models/app_enums.dart';
import 'package:sickandflutter/shared/models/service_health_info.dart';

/// 当前是否处于本地预览工作台模式。
///
/// 预览入口和开发态 Mock 登录都会落到这套本地样例数据，
/// 这样即使后端暂时不可用，也能先检查所有主界面的编排效果。
final previewWorkspaceEnabledProvider = Provider<bool>((ref) {
  final session = ref.watch(authControllerProvider).session;
  return session?.loginMode == AuthLoginMode.mock;
});

/// 本地预览工作台使用的设备仓储。
final previewDeviceRuntimeRepositoryProvider =
    Provider<DeviceRuntimeRepository>(
      (ref) => PreviewDeviceRuntimeRepository(),
    );

/// 本地预览工作台使用的视频流列表。
final previewVideoStreamsProvider = Provider<List<VideoStreamInfo>>((ref) {
  return const <VideoStreamInfo>[
    VideoStreamInfo(
      streamId: 'preview-main',
      deviceId: 'preview-main',
      displayName: '温室主画面',
      gatewayPageUrl: 'about:blank',
      playerUrl: 'about:blank',
      preferredMode: 'webrtc',
      fallbackMode: 'mse',
      publicHost: 'preview.local',
      webrtcPort: 8555,
      available: true,
      aiResultForwarded: true,
    ),
    VideoStreamInfo(
      streamId: 'preview-side',
      deviceId: 'preview-side',
      displayName: '侧区巡检画面',
      gatewayPageUrl: 'about:blank',
      playerUrl: 'about:blank',
      preferredMode: 'webrtc',
      fallbackMode: 'mse',
      publicHost: 'preview.local',
      webrtcPort: 8555,
      available: true,
      aiResultForwarded: false,
    ),
    VideoStreamInfo(
      streamId: 'preview-night',
      deviceId: 'preview-night',
      displayName: '夜间补光画面',
      gatewayPageUrl: 'about:blank',
      playerUrl: '',
      preferredMode: 'webrtc',
      fallbackMode: 'mse',
      publicHost: 'preview.local',
      webrtcPort: 8555,
      available: false,
      aiResultForwarded: false,
    ),
  ];
});

/// 本地预览工作台使用的健康检查结果。
final previewServiceHealthProvider = Provider<ServiceHealthInfo>((ref) {
  return ServiceHealthInfo(
    status: 'up',
    responseText: '界面预览使用本地样例数据，不依赖在线服务。',
    checkedAt: DateTime.now().toIso8601String(),
  );
});

/// 本地预览工作台使用的 AI 检测总览。
final previewAiDetectionOverviewProvider = Provider<AiDetectionOverview>((ref) {
  final now = DateTime.now();
  return AiDetectionOverview(
    latest: AiDetectionSummary(
      type: 'AI_DETECTIONS',
      deviceId: 'preview-main',
      stream: 'preview-main',
      timestampMs: now
          .subtract(const Duration(minutes: 2))
          .millisecondsSinceEpoch,
      frameId: 2048,
      imageWidth: 1920,
      imageHeight: 1080,
      detectionCount: 2,
      empty: false,
      summary: '检测到 2 处疑似病虫害目标，请优先查看主画面并复核叶面细节。',
      overallRiskLevel: '高',
      items: const <AiDetectionItem>[
        AiDetectionItem(
          classId: 1,
          originalClassName: 'aphid',
          displayName: '蚜虫',
          category: '虫害',
          confidence: 0.96,
          riskLevel: '高',
          advice: '建议优先检查嫩叶背面，可结合黄板和定点喷施处理。',
          bbox: <double>[0.1, 0.2, 0.4, 0.5],
          quad: <double>[],
        ),
        AiDetectionItem(
          classId: 2,
          originalClassName: 'leaf_spot',
          displayName: '叶斑病',
          category: '病害',
          confidence: 0.83,
          riskLevel: '中',
          advice: '建议检查叶片病斑边缘，优先处理受害区域。',
          bbox: <double>[0.55, 0.22, 0.82, 0.58],
          quad: <double>[],
        ),
      ],
    ),
    history: <AiDetectionSummary>[
      AiDetectionSummary(
        type: 'AI_DETECTIONS',
        deviceId: 'preview-main',
        stream: 'preview-main',
        timestampMs: now
            .subtract(const Duration(minutes: 2))
            .millisecondsSinceEpoch,
        frameId: 2048,
        imageWidth: 1920,
        imageHeight: 1080,
        detectionCount: 2,
        empty: false,
        summary: '检测到 2 处疑似病虫害目标，请优先查看主画面并复核叶面细节。',
        overallRiskLevel: '高',
        items: const <AiDetectionItem>[],
      ),
      AiDetectionSummary(
        type: 'AI_DETECTIONS',
        deviceId: 'preview-side',
        stream: 'preview-side',
        timestampMs: now
            .subtract(const Duration(minutes: 11))
            .millisecondsSinceEpoch,
        frameId: 1984,
        imageWidth: 1920,
        imageHeight: 1080,
        detectionCount: 1,
        empty: false,
        summary: '侧区画面检测到 1 处低风险目标，建议结合现场继续观察。',
        overallRiskLevel: '低',
        items: const <AiDetectionItem>[],
      ),
      AiDetectionSummary(
        type: 'AI_DETECTIONS',
        deviceId: 'preview-night',
        stream: 'preview-night',
        timestampMs: now
            .subtract(const Duration(minutes: 27))
            .millisecondsSinceEpoch,
        frameId: 1886,
        imageWidth: 1920,
        imageHeight: 1080,
        detectionCount: 0,
        empty: true,
        summary: '当前未检测到病虫害目标。',
        overallRiskLevel: '健康',
        items: const <AiDetectionItem>[],
      ),
    ],
  );
});

/// 本地预览工作台使用的平台日志总览。
final previewPlatformLogOverviewProvider = Provider<PlatformLogOverview>((ref) {
  final now = DateTime.now();
  return PlatformLogOverview(
    summary: const PlatformLogSummary(
      count: 18,
      file: '/tmp/preview-platform-events.log',
      supportedTypes: <String>[
        'ONENET_UPLINK',
        'ONENET_COMMAND',
        'ONENET_SET_REPLY',
        'AI_DETECTION',
      ],
    ),
    recentEntries: <PlatformLogEntry>[
      PlatformLogEntry(
        eventId: 'preview-log-1',
        timestampMs: now
            .subtract(const Duration(minutes: 1))
            .millisecondsSinceEpoch,
        type: 'AI_DETECTION',
        deviceId: 'preview-main',
        summary: '主画面收到 2 条病虫害识别结果。',
        details: <String, Object>{'count': 2, 'risk': '高'},
      ),
      PlatformLogEntry(
        eventId: 'preview-log-2',
        timestampMs: now
            .subtract(const Duration(minutes: 3))
            .millisecondsSinceEpoch,
        type: 'ONENET_COMMAND',
        deviceId: 'preview_cabinet_a07',
        summary: '补光开启指令已下发。',
        details: <String, Object>{'led': true},
      ),
      PlatformLogEntry(
        eventId: 'preview-log-3',
        timestampMs: now
            .subtract(const Duration(minutes: 4))
            .millisecondsSinceEpoch,
        type: 'ONENET_SET_REPLY',
        deviceId: 'preview_cabinet_a07',
        summary: '设备已回写补光状态成功。',
        details: <String, Object>{'status': 'success'},
      ),
      PlatformLogEntry(
        eventId: 'preview-log-4',
        timestampMs: now
            .subtract(const Duration(minutes: 7))
            .millisecondsSinceEpoch,
        type: 'ONENET_UPLINK',
        deviceId: 'preview_cabinet_a07',
        summary: '最新一轮环境指标已写入缓存。',
        details: <String, Object>{'temperature': 23.8, 'humidity': 81.6},
      ),
    ],
  );
});

/// 用于离线界面预览的设备运行时仓储。
class PreviewDeviceRuntimeRepository implements DeviceRuntimeRepository {
  bool _ledOn = true;

  @override
  Future<DeviceStatus> fetchStatus() async {
    await Future<void>.delayed(const Duration(milliseconds: 90));
    final updatedAt = DateTime.now()
        .subtract(const Duration(seconds: 6))
        .millisecondsSinceEpoch;

    return DeviceStatus(
      deviceId: 'preview_cabinet_a07',
      deviceName: '兰棚 A-07 培育柜',
      temperature: _ledOn ? 23.8 : 23.2,
      humidity: _ledOn ? 81.6 : 82.4,
      light: _ledOn ? 1680 : 920,
      mq2: 16.4,
      errorCode: 0,
      ledOn: _ledOn,
      updatedAt: updatedAt,
    );
  }

  @override
  Future<LedOperationReceipt> setLed({
    required String deviceId,
    required String deviceName,
    required bool ledOn,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 160));
    _ledOn = ledOn;

    return LedOperationReceipt(
      status: 'accepted',
      requestId: ledOn ? 'preview_led_on' : 'preview_led_off',
      message: ledOn ? '预览补光已开启。' : '预览补光已关闭。',
    );
  }
}
