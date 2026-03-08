// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'image_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ImageInfo _$ImageInfoFromJson(Map<String, dynamic> json) => ImageInfo(
  width: parseIntValue(json['width']),
  height: parseIntValue(json['height']),
  originalUrl: parseNullableStringValue(json['originalUrl']),
  annotatedUrl: parseNullableStringValue(json['annotatedUrl']),
);

Map<String, dynamic> _$ImageInfoToJson(ImageInfo instance) => <String, dynamic>{
  'width': instance.width,
  'height': instance.height,
  'originalUrl': _nullableStringToJson(instance.originalUrl),
  'annotatedUrl': _nullableStringToJson(instance.annotatedUrl),
};
