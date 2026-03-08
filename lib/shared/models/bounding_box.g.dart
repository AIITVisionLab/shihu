// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bounding_box.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BoundingBox _$BoundingBoxFromJson(Map<String, dynamic> json) => BoundingBox(
  x: parseDoubleValue(json['x']),
  y: parseDoubleValue(json['y']),
  width: parseDoubleValue(json['width']),
  height: parseDoubleValue(json['height']),
);

Map<String, dynamic> _$BoundingBoxToJson(BoundingBox instance) =>
    <String, dynamic>{
      'x': instance.x,
      'y': instance.y,
      'width': instance.width,
      'height': instance.height,
    };
