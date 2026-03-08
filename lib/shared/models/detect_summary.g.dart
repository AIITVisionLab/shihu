// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'detect_summary.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DetectSummary _$DetectSummaryFromJson(Map<String, dynamic> json) =>
    DetectSummary(
      primaryLabelCode: parseStringValue(json['primaryLabelCode']),
      primaryLabelName: parseStringValue(json['primaryLabelName']),
      category: _detectionCategoryFromJson(json['category']),
      confidence: parseDoubleValue(json['confidence']),
      severityLevel: _severityLevelFromJson(json['severityLevel']),
      healthStatus: _healthStatusFromJson(json['healthStatus']),
      severityScore: _nullableDoubleFromJson(json['severityScore']),
    );

Map<String, dynamic> _$DetectSummaryToJson(DetectSummary instance) =>
    <String, dynamic>{
      'primaryLabelCode': instance.primaryLabelCode,
      'primaryLabelName': instance.primaryLabelName,
      'category': _detectionCategoryToJson(instance.category),
      'confidence': instance.confidence,
      'severityLevel': _severityLevelToJson(instance.severityLevel),
      'severityScore': _nullableDoubleToJson(instance.severityScore),
      'healthStatus': _healthStatusToJson(instance.healthStatus),
    };
