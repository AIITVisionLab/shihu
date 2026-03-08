import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sickandflutter/core/network/api_exception.dart';
import 'package:sickandflutter/features/realtime/realtime_detect_repository.dart';
import 'package:sickandflutter/shared/models/app_enums.dart';
import 'package:sickandflutter/shared/models/detect_response.dart';
import 'package:sickandflutter/shared/models/detect_summary.dart';

/// 实时识别轮询间隔配置。
final realtimeDetectPollingIntervalProvider = Provider<Duration>((ref) {
  return const Duration(seconds: 3);
});

/// 实时识别页面状态入口。
final realtimeDetectControllerProvider =
    NotifierProvider<RealtimeDetectController, RealtimeDetectState>(
      RealtimeDetectController.new,
    );

/// 管理实时识别会话、测试帧轮询和错误反馈。
class RealtimeDetectController extends Notifier<RealtimeDetectState> {
  Timer? _pollingTimer;
  bool _isRequestInFlight = false;

  @override
  RealtimeDetectState build() {
    ref.onDispose(_stopPolling);

    final repository = ref.read(realtimeDetectRepositoryProvider);
    return RealtimeDetectState(supportsTestFeed: repository.supportsTestFeed);
  }

  /// 启动新的实时识别测试会话。
  Future<void> startSession() async {
    if (_isRequestInFlight) {
      return;
    }

    final repository = ref.read(realtimeDetectRepositoryProvider);
    if (!repository.supportsTestFeed) {
      state = state.copyWith(
        status: RealtimeSessionStatus.error,
        errorMessage: '当前环境未开放测试帧链路，需接入摄像头取帧后再启用。',
      );
      return;
    }

    _stopPolling();

    final sessionId = _buildSessionId();
    state = state.copyWith(
      status: RealtimeSessionStatus.initializing,
      sessionId: sessionId,
      frameIndex: 0,
      latestResult: null,
      lastInferenceMs: null,
      lastFrameAt: null,
      errorMessage: null,
    );

    final didStart = await _requestFrame(
      sessionId: sessionId,
      nextFrameIndex: 1,
      successStatus: RealtimeSessionStatus.running,
    );

    if (didStart) {
      _startPolling(sessionId);
    }
  }

  /// 暂停当前会话轮询。
  void pauseSession() {
    _stopPolling();

    if (state.status == RealtimeSessionStatus.running ||
        state.status == RealtimeSessionStatus.initializing) {
      state = state.copyWith(status: RealtimeSessionStatus.paused);
    }
  }

  /// 继续当前会话。
  Future<void> resumeSession() async {
    if (_isRequestInFlight) {
      return;
    }

    final sessionId = state.sessionId;
    if (sessionId == null) {
      await startSession();
      return;
    }

    state = state.copyWith(
      status: RealtimeSessionStatus.initializing,
      errorMessage: null,
    );

    final didResume = await _requestFrame(
      sessionId: sessionId,
      nextFrameIndex: state.frameIndex + 1,
      successStatus: RealtimeSessionStatus.running,
    );

    if (didResume) {
      _startPolling(sessionId);
    }
  }

  Future<bool> _requestFrame({
    required String sessionId,
    required int nextFrameIndex,
    required RealtimeSessionStatus successStatus,
  }) async {
    _isRequestInFlight = true;

    try {
      final response = await ref
          .read(realtimeDetectRepositoryProvider)
          .detectFrame(
            request: RealtimeFrameRequest(
              sessionId: sessionId,
              frameIndex: nextFrameIndex,
              capturedAt: DateTime.now(),
            ),
          );

      if (state.sessionId != sessionId) {
        return false;
      }

      final effectiveStatus = state.status == RealtimeSessionStatus.paused
          ? RealtimeSessionStatus.paused
          : successStatus;

      state = state.copyWith(
        status: effectiveStatus,
        frameIndex: nextFrameIndex,
        latestResult: response,
        lastInferenceMs: response.modelInfo?.inferenceMs,
        lastFrameAt: DateTime.now(),
        errorMessage: null,
      );
      return true;
    } on ApiException catch (error) {
      if (state.sessionId != sessionId) {
        return false;
      }

      _stopPolling();
      state = state.copyWith(
        status: RealtimeSessionStatus.error,
        errorMessage: error.message,
      );
      return false;
    } catch (error) {
      if (state.sessionId != sessionId) {
        return false;
      }

      _stopPolling();
      state = state.copyWith(
        status: RealtimeSessionStatus.error,
        errorMessage: '实时识别失败：$error',
      );
      return false;
    } finally {
      _isRequestInFlight = false;
    }
  }

  void _startPolling(String sessionId) {
    _stopPolling();

    final interval = ref.read(realtimeDetectPollingIntervalProvider);
    _pollingTimer = Timer.periodic(interval, (_) {
      if (state.sessionId != sessionId ||
          state.status != RealtimeSessionStatus.running ||
          _isRequestInFlight) {
        return;
      }

      unawaited(
        _requestFrame(
          sessionId: sessionId,
          nextFrameIndex: state.frameIndex + 1,
          successStatus: RealtimeSessionStatus.running,
        ),
      );
    });
  }

  void _stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  String _buildSessionId() {
    final timestamp = DateTime.now().microsecondsSinceEpoch;
    return 'rt_$timestamp';
  }
}

const Object _realtimeStateUnset = Object();

/// 实时识别页的视图状态。
class RealtimeDetectState {
  /// 创建实时识别页面状态对象。
  const RealtimeDetectState({
    this.status = RealtimeSessionStatus.idle,
    this.supportsTestFeed = true,
    this.sessionId,
    this.frameIndex = 0,
    this.latestResult,
    this.lastInferenceMs,
    this.lastFrameAt,
    this.errorMessage,
  });

  /// 当前会话状态。
  final RealtimeSessionStatus status;

  /// 当前仓储是否支持无摄像头测试帧链路。
  final bool supportsTestFeed;

  /// 当前会话 ID。
  final String? sessionId;

  /// 当前已经完成处理的帧序号。
  final int frameIndex;

  /// 最近一帧识别结果。
  final DetectResponse? latestResult;

  /// 最近一帧推理耗时。
  final int? lastInferenceMs;

  /// 最近一帧刷新时间。
  final DateTime? lastFrameAt;

  /// 最近一次错误信息。
  final String? errorMessage;

  /// 最近一帧摘要结果。
  DetectSummary? get summary => latestResult?.summary;

  /// 最近一帧检测框数量。
  int get detectionCount => latestResult?.detections.length ?? 0;

  /// 当前是否已有识别结果。
  bool get hasResult => latestResult != null;

  /// 返回带增量修改的新状态对象。
  RealtimeDetectState copyWith({
    RealtimeSessionStatus? status,
    bool? supportsTestFeed,
    Object? sessionId = _realtimeStateUnset,
    int? frameIndex,
    Object? latestResult = _realtimeStateUnset,
    Object? lastInferenceMs = _realtimeStateUnset,
    Object? lastFrameAt = _realtimeStateUnset,
    Object? errorMessage = _realtimeStateUnset,
  }) {
    return RealtimeDetectState(
      status: status ?? this.status,
      supportsTestFeed: supportsTestFeed ?? this.supportsTestFeed,
      sessionId: identical(sessionId, _realtimeStateUnset)
          ? this.sessionId
          : sessionId as String?,
      frameIndex: frameIndex ?? this.frameIndex,
      latestResult: identical(latestResult, _realtimeStateUnset)
          ? this.latestResult
          : latestResult as DetectResponse?,
      lastInferenceMs: identical(lastInferenceMs, _realtimeStateUnset)
          ? this.lastInferenceMs
          : lastInferenceMs as int?,
      lastFrameAt: identical(lastFrameAt, _realtimeStateUnset)
          ? this.lastFrameAt
          : lastFrameAt as DateTime?,
      errorMessage: identical(errorMessage, _realtimeStateUnset)
          ? this.errorMessage
          : errorMessage as String?,
    );
  }
}
