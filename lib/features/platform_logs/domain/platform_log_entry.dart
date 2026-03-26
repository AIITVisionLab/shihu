import 'dart:convert';

import 'package:sickandflutter/shared/models/model_utils.dart';

/// 平台日志查询条件。
class PlatformLogQuery {
  /// 创建平台日志查询条件。
  const PlatformLogQuery({
    this.keyword = '',
    this.type = '',
    this.limit = defaultLimit,
  });

  /// 设置页平台日志默认查询条数。
  static const int defaultLimit = 6;

  /// 关键字条件。
  final String keyword;

  /// 事件类型条件。
  final String type;

  /// 最多查询条数。
  final int limit;

  /// 归一化后的关键字。
  String get normalizedKeyword => keyword.trim();

  /// 归一化后的类型值。
  String get normalizedType => type.trim().toUpperCase();

  /// 当前是否启用了任一筛选条件。
  bool get hasFilter =>
      normalizedKeyword.isNotEmpty || normalizedType.isNotEmpty;

  /// 复制并返回新的查询条件。
  PlatformLogQuery copyWith({String? keyword, String? type, int? limit}) {
    return PlatformLogQuery(
      keyword: keyword ?? this.keyword,
      type: type ?? this.type,
      limit: limit ?? this.limit,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is PlatformLogQuery &&
        other.keyword == keyword &&
        other.type == type &&
        other.limit == limit;
  }

  @override
  int get hashCode => Object.hash(keyword, type, limit);
}

/// 平台日志摘要信息。
class PlatformLogSummary {
  /// 创建平台日志摘要信息。
  const PlatformLogSummary({
    required this.count,
    required this.file,
    required this.supportedTypes,
  });

  /// 从后端 JSON 构建平台日志摘要信息。
  factory PlatformLogSummary.fromJson(Map<String, dynamic> json) {
    return PlatformLogSummary(
      count: _asNullableInt(json['count']) ?? 0,
      file: asString(json['file']),
      supportedTypes: asStringList(json['supportedTypes']),
    );
  }

  /// 累计日志条数。
  final int count;

  /// 日志文件路径。
  final String file;

  /// 当前支持的日志类型。
  final List<String> supportedTypes;
}

/// 平台日志单条记录。
class PlatformLogEntry {
  /// 创建平台日志单条记录。
  const PlatformLogEntry({
    required this.eventId,
    required this.timestampMs,
    required this.type,
    required this.deviceId,
    required this.summary,
    required this.details,
  });

  /// 从后端 JSON 构建平台日志单条记录。
  factory PlatformLogEntry.fromJson(Map<String, dynamic> json) {
    return PlatformLogEntry(
      eventId: asString(json['eventId']),
      timestampMs: _asNullableInt(json['timestampMs']),
      type: asString(json['type']),
      deviceId: asString(json['deviceId']),
      summary: asString(json['summary']),
      details: json['details'],
    );
  }

  /// 事件编号。
  final String eventId;

  /// 事件时间戳（毫秒）。
  final int? timestampMs;

  /// 事件类型。
  final String type;

  /// 设备标识。
  final String deviceId;

  /// 摘要说明。
  final String summary;

  /// 原始详情。
  final Object? details;

  /// 原始详情对象。
  Map<String, dynamic>? get detailsMap => asStringMap(details);

  /// 事件时间。
  DateTime? get occurredAt {
    final value = timestampMs;
    if (value == null || value <= 0) {
      return null;
    }
    return DateTime.fromMillisecondsSinceEpoch(value).toLocal();
  }

  /// 详情预览文案。
  String get detailsPreview {
    final rawDetails = details;
    if (rawDetails == null) {
      return '';
    }
    if (rawDetails is String) {
      return rawDetails;
    }
    try {
      return jsonEncode(rawDetails);
    } catch (_) {
      return rawDetails.toString();
    }
  }
}

/// 设置页所需的平台日志组合结果。
class PlatformLogOverview {
  /// 创建平台日志组合结果。
  const PlatformLogOverview({
    required this.summary,
    required this.recentEntries,
  });

  /// 日志摘要。
  final PlatformLogSummary summary;

  /// 最近日志。
  final List<PlatformLogEntry> recentEntries;
}

int? _asNullableInt(Object? value) {
  if (value == null) {
    return null;
  }
  return asInt(value);
}
