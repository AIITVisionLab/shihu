import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sickandflutter/core/network/api_exception.dart';
import 'package:sickandflutter/features/settings/device_state_repository.dart';
import 'package:sickandflutter/shared/models/device_state_info.dart';

/// 实时监控轮询间隔配置。
final realtimeDetectPollingIntervalProvider = Provider<Duration>((ref) {
  return const Duration(seconds: 3);
});

/// 实时监控页面状态入口。
final realtimeDetectControllerProvider =
    NotifierProvider<RealtimeDetectController, RealtimeDetectState>(
      RealtimeDetectController.new,
    );

/// 管理设备状态轮询、手动刷新和 LED 控制。
class RealtimeDetectController extends Notifier<RealtimeDetectState> {
  Timer? _pollingTimer;
  bool _isRefreshing = false;
  bool _isSubmittingLed = false;

  @override
  RealtimeDetectState build() {
    ref.onDispose(_stopPolling);
    return const RealtimeDetectState(isAutoRefreshEnabled: true);
  }

  /// 进入页面后启动实时监控。
  Future<void> startMonitoring() async {
    if (state.isAutoRefreshEnabled) {
      _startPolling();
    }

    if (!state.hasDeviceState || state.errorMessage != null) {
      await refreshNow();
    }
  }

  /// 离开页面后停止轮询。
  void stopMonitoring() {
    _stopPolling();
  }

  /// 立即刷新一次设备状态。
  Future<void> refreshNow() async {
    if (_isRefreshing) {
      return;
    }

    _isRefreshing = true;
    state = state.copyWith(isRefreshing: true, errorMessage: null);

    try {
      final repository = await ref.read(deviceStateRepositoryProvider.future);
      final deviceState = await repository.fetchState();
      state = state.copyWith(
        deviceState: deviceState,
        isRefreshing: false,
        errorMessage: null,
        lastRefreshAt: DateTime.now(),
      );
    } on ApiException catch (error) {
      state = state.copyWith(
        isRefreshing: false,
        errorMessage: error.message,
        lastRefreshAt: DateTime.now(),
      );
    } catch (error) {
      state = state.copyWith(
        isRefreshing: false,
        errorMessage: '拉取设备状态失败：$error',
        lastRefreshAt: DateTime.now(),
      );
    } finally {
      _isRefreshing = false;
    }
  }

  /// 切换自动轮询开关。
  Future<void> setAutoRefreshEnabled(bool enabled) async {
    state = state.copyWith(isAutoRefreshEnabled: enabled);

    if (!enabled) {
      _stopPolling();
      return;
    }

    _startPolling();
    await refreshNow();
  }

  /// 提交 LED 控制命令，并在成功后刷新最新状态。
  Future<String> toggleLed(bool ledOn) async {
    if (_isSubmittingLed) {
      return '控制指令正在提交，请稍候。';
    }

    final deviceState = state.deviceState;
    if (deviceState == null) {
      throw const ApiException(message: '当前还没有可控制的设备状态。');
    }

    _isSubmittingLed = true;
    state = state.copyWith(isSubmittingLed: true, errorMessage: null);

    try {
      final repository = await ref.read(deviceStateRepositoryProvider.future);
      await repository.setLed(
        deviceId: deviceState.deviceId,
        deviceName: deviceState.deviceName,
        ledOn: ledOn,
      );
      await refreshNow();
      return ledOn ? '开灯指令已提交，等待设备状态回写。' : '关灯指令已提交，等待设备状态回写。';
    } on ApiException catch (error) {
      state = state.copyWith(errorMessage: error.message);
      rethrow;
    } catch (error) {
      final exception = ApiException(message: 'LED 控制失败：$error');
      state = state.copyWith(errorMessage: exception.message);
      throw exception;
    } finally {
      _isSubmittingLed = false;
      state = state.copyWith(isSubmittingLed: false);
    }
  }

  void _startPolling() {
    _stopPolling();

    final interval = ref.read(realtimeDetectPollingIntervalProvider);
    _pollingTimer = Timer.periodic(interval, (_) {
      if (!state.isAutoRefreshEnabled || _isRefreshing) {
        return;
      }
      unawaited(refreshNow());
    });
  }

  void _stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }
}

const Object _realtimeStateUnset = Object();

/// 实时监控页的视图状态。
class RealtimeDetectState {
  /// 创建实时监控页面状态对象。
  const RealtimeDetectState({
    this.deviceState,
    this.isRefreshing = false,
    this.isAutoRefreshEnabled = true,
    this.isSubmittingLed = false,
    this.lastRefreshAt,
    this.errorMessage,
  });

  /// 当前设备状态。
  final DeviceStateInfo? deviceState;

  /// 是否正在刷新。
  final bool isRefreshing;

  /// 是否启用自动轮询。
  final bool isAutoRefreshEnabled;

  /// 是否正在提交 LED 控制命令。
  final bool isSubmittingLed;

  /// 最近一次刷新完成时间。
  final DateTime? lastRefreshAt;

  /// 最近一次失败信息。
  final String? errorMessage;

  /// 当前是否已有可展示的设备状态。
  bool get hasDeviceState => deviceState != null;

  /// 返回带增量修改的新状态对象。
  RealtimeDetectState copyWith({
    Object? deviceState = _realtimeStateUnset,
    bool? isRefreshing,
    bool? isAutoRefreshEnabled,
    bool? isSubmittingLed,
    Object? lastRefreshAt = _realtimeStateUnset,
    Object? errorMessage = _realtimeStateUnset,
  }) {
    return RealtimeDetectState(
      deviceState: identical(deviceState, _realtimeStateUnset)
          ? this.deviceState
          : deviceState as DeviceStateInfo?,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      isAutoRefreshEnabled: isAutoRefreshEnabled ?? this.isAutoRefreshEnabled,
      isSubmittingLed: isSubmittingLed ?? this.isSubmittingLed,
      lastRefreshAt: identical(lastRefreshAt, _realtimeStateUnset)
          ? this.lastRefreshAt
          : lastRefreshAt as DateTime?,
      errorMessage: identical(errorMessage, _realtimeStateUnset)
          ? this.errorMessage
          : errorMessage as String?,
    );
  }
}
