import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sickandflutter/core/network/api_exception.dart';
import 'package:sickandflutter/features/device/application/device_runtime_providers.dart';
import 'package:sickandflutter/features/device/domain/device_status.dart';

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
  Timer? _pendingLedRefreshTimer;
  bool _isRefreshing = false;
  bool _isSubmittingLed = false;
  bool _hasStartedMonitoring = false;

  @override
  RealtimeDetectState build() {
    ref.onDispose(() {
      _pendingLedRefreshTimer?.cancel();
      _stopPolling();
    });
    if (!_hasStartedMonitoring) {
      Future<void>.microtask(startMonitoring);
    }
    return const RealtimeDetectState(isAutoRefreshEnabled: true);
  }

  /// 进入页面后启动实时监控。
  Future<void> startMonitoring() async {
    if (_hasStartedMonitoring) {
      return;
    }
    _hasStartedMonitoring = true;

    if (state.isAutoRefreshEnabled) {
      _startPolling();
    }

    if (!state.hasDeviceState || state.errorMessage != null) {
      await refreshNow();
    }
  }

  /// 立即刷新一次设备状态。
  Future<void> refreshNow() async {
    if (_isRefreshing) {
      return;
    }

    _isRefreshing = true;
    state = state.copyWith(isRefreshing: true, errorMessage: null);

    try {
      final repository = await ref.read(deviceRuntimeRepositoryProvider.future);
      final deviceState = await repository.fetchStatus();
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
        errorMessage: '获取设备状态失败，请稍后重试。',
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
    if (!deviceState.canControlLed) {
      throw const ApiException(message: '当前还不能调整补光，请先等待状态稳定。');
    }

    _isSubmittingLed = true;
    state = state.copyWith(isSubmittingLed: true, errorMessage: null);

    try {
      final repository = await ref.read(deviceRuntimeRepositoryProvider.future);
      final receipt = await repository.setLed(
        deviceId: deviceState.deviceId,
        deviceName: deviceState.deviceName,
        ledOn: ledOn,
      );
      await refreshNow();
      _schedulePendingLedRefresh();
      return receipt.buildUserMessage(ledOn: ledOn);
    } on ApiException catch (error) {
      state = state.copyWith(errorMessage: error.message);
      rethrow;
    } catch (error) {
      final exception = ApiException(message: '补光调整失败，请稍后重试。');
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

  void _schedulePendingLedRefresh() {
    _pendingLedRefreshTimer?.cancel();
    _pendingLedRefreshTimer = Timer(const Duration(seconds: 2), () {
      if (_isRefreshing) {
        return;
      }
      unawaited(refreshNow());
    });
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
  final DeviceStatus? deviceState;

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
          : deviceState as DeviceStatus?,
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
