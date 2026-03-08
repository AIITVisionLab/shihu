// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'history_record.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HistoryRecord _$HistoryRecordFromJson(Map<String, dynamic> json) =>
    HistoryRecord(
      item: _historyItemFromJson(json['item']),
      response: _detectResponseFromJson(json['response']),
      savedAt: parseStringValue(json['savedAt']),
      sourceImagePath: parseNullableStringValue(json['sourceImagePath']),
    );

Map<String, dynamic> _$HistoryRecordToJson(HistoryRecord instance) =>
    <String, dynamic>{
      'item': _historyItemToJson(instance.item),
      'response': _detectResponseToJson(instance.response),
      'savedAt': instance.savedAt,
      'sourceImagePath': _nullableStringToJson(instance.sourceImagePath),
    };
