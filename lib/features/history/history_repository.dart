import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sickandflutter/core/constants/app_constants.dart';
import 'package:sickandflutter/core/storage/local_storage.dart';
import 'package:sickandflutter/shared/models/history_record.dart';
import 'package:sickandflutter/shared/models/model_utils.dart';

/// 历史记录仓储入口。
final historyRepositoryProvider = FutureProvider<HistoryRepository>((
  ref,
) async {
  final storage = await ref.watch(localStorageProvider.future);
  return HistoryRepository(storage);
});

/// 历史记录页面状态入口。
final historyControllerProvider =
    AsyncNotifierProvider<HistoryController, List<HistoryRecord>>(
      HistoryController.new,
    );

/// 管理历史记录的本地持久化读写。
class HistoryRepository {
  /// 基于本地存储创建历史记录仓储。
  const HistoryRepository(this._storage);

  final LocalStorage _storage;

  /// 加载全部历史记录，默认按持久化顺序返回。
  Future<List<HistoryRecord>> loadRecords() async {
    final rawValue = _storage.readString(AppConstants.historyStorageKey);
    if (rawValue == null || rawValue.isEmpty) {
      return const <HistoryRecord>[];
    }

    final decoded = _decodeRecordList(rawValue);
    if (decoded == null) {
      return const <HistoryRecord>[];
    }
    final records = <HistoryRecord>[];
    for (final item in decoded) {
      final itemJson = asStringMap(item);
      if (itemJson == null) {
        continue;
      }

      try {
        final record = HistoryRecord.fromJson(itemJson);
        if (record.item.historyId.isEmpty || record.item.detectId.isEmpty) {
          continue;
        }
        records.add(record);
      } on FormatException {
        continue;
      } on TypeError {
        continue;
      }
    }

    return List<HistoryRecord>.unmodifiable(records);
  }

  /// 保存一条历史记录，并按最新优先重新排序。
  Future<List<HistoryRecord>> saveRecord(HistoryRecord record) async {
    final records = await loadRecords();
    final deduped = records
        .where((item) => item.item.detectId != record.item.detectId)
        .toList(growable: true);
    deduped.insert(0, record);
    await _persist(deduped);
    return deduped;
  }

  /// 删除指定历史记录。
  Future<List<HistoryRecord>> deleteRecord(String historyId) async {
    final records = await loadRecords();
    final updated = records
        .where((item) => item.item.historyId != historyId)
        .toList(growable: false);
    await _persist(updated);
    return updated;
  }

  /// 清空全部历史记录。
  Future<void> clear() async {
    await _storage.remove(AppConstants.historyStorageKey);
  }

  Future<void> _persist(List<HistoryRecord> records) async {
    final jsonString = jsonEncode(
      records.map((item) => item.toJson()).toList(growable: false),
    );
    await _storage.writeString(AppConstants.historyStorageKey, jsonString);
  }

  List<dynamic>? _decodeRecordList(String rawValue) {
    try {
      final decoded = jsonDecode(rawValue);
      if (decoded is List) {
        return decoded;
      }
      return null;
    } on FormatException {
      return null;
    }
  }
}

/// 协调历史记录加载、保存、删除和清空的异步状态。
class HistoryController extends AsyncNotifier<List<HistoryRecord>> {
  @override
  Future<List<HistoryRecord>> build() async {
    final repository = await ref.watch(historyRepositoryProvider.future);
    return repository.loadRecords();
  }

  /// 保存一条历史记录，并刷新页面状态。
  Future<void> saveRecord(HistoryRecord record) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repository = await ref.read(historyRepositoryProvider.future);
      return repository.saveRecord(record);
    });
  }

  /// 删除一条历史记录，并刷新页面状态。
  Future<void> deleteRecord(String historyId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repository = await ref.read(historyRepositoryProvider.future);
      return repository.deleteRecord(historyId);
    });
  }

  /// 清空全部历史记录，并刷新页面状态。
  Future<void> clearAll() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repository = await ref.read(historyRepositoryProvider.future);
      await repository.clear();
      return const <HistoryRecord>[];
    });
  }
}
