// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'history_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HistoryItem _$HistoryItemFromJson(Map<String, dynamic> json) => HistoryItem(
  historyId: parseStringValue(json['historyId']),
  detectId: parseStringValue(json['detectId']),
  primaryLabelCode: parseStringValue(json['primaryLabelCode']),
  primaryLabelName: parseStringValue(json['primaryLabelName']),
  category: _detectionCategoryFromJson(json['category']),
  severityLevel: _severityLevelFromJson(json['severityLevel']),
  confidence: parseDoubleValue(json['confidence']),
  capturedAt: parseStringValue(json['capturedAt']),
  coverUrl: parseNullableStringValue(json['coverUrl']),
);

Map<String, dynamic> _$HistoryItemToJson(HistoryItem instance) =>
    <String, dynamic>{
      'historyId': instance.historyId,
      'detectId': instance.detectId,
      'coverUrl': _nullableStringToJson(instance.coverUrl),
      'primaryLabelCode': instance.primaryLabelCode,
      'primaryLabelName': instance.primaryLabelName,
      'category': _detectionCategoryToJson(instance.category),
      'severityLevel': _severityLevelToJson(instance.severityLevel),
      'confidence': instance.confidence,
      'capturedAt': instance.capturedAt,
    };
