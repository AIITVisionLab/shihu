// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'advice_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AdviceInfo _$AdviceInfoFromJson(Map<String, dynamic> json) => AdviceInfo(
  title: parseStringValue(json['title']),
  summary: parseStringValue(json['summary']),
  preventionSteps: parseStringListValue(json['preventionSteps']),
);

Map<String, dynamic> _$AdviceInfoToJson(AdviceInfo instance) =>
    <String, dynamic>{
      'title': instance.title,
      'summary': instance.summary,
      'preventionSteps': stringListToJson(instance.preventionSteps),
    };
