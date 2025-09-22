// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'import_subtask_timing.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ImportSubtaskTiming _$ImportSubtaskTimingFromJson(Map<String, dynamic> json) =>
    _ImportSubtaskTiming(
      stageName: json['stageName'] as String,
      subtaskName: json['subtaskName'] as String,
      startedAt: DateTime.parse(json['startedAt'] as String),
      endedAt: json['endedAt'] == null
          ? null
          : DateTime.parse(json['endedAt'] as String),
      itemCount: (json['itemCount'] as num?)?.toInt(),
    );

Map<String, dynamic> _$ImportSubtaskTimingToJson(
  _ImportSubtaskTiming instance,
) => <String, dynamic>{
  'stageName': instance.stageName,
  'subtaskName': instance.subtaskName,
  'startedAt': instance.startedAt.toIso8601String(),
  'endedAt': instance.endedAt?.toIso8601String(),
  'itemCount': instance.itemCount,
};
