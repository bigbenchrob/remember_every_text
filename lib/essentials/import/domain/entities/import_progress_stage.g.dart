// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'import_progress_stage.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ImportProgressStage _$ImportProgressStageFromJson(Map<String, dynamic> json) =>
    _ImportProgressStage(
      name: json['name'] as String,
      displayName: json['displayName'] as String,
      isActive: json['isActive'] as bool? ?? false,
      isComplete: json['isComplete'] as bool? ?? false,
      progress: (json['progress'] as num?)?.toDouble(),
      current: (json['current'] as num?)?.toInt(),
      total: (json['total'] as num?)?.toInt(),
    );

Map<String, dynamic> _$ImportProgressStageToJson(
  _ImportProgressStage instance,
) => <String, dynamic>{
  'name': instance.name,
  'displayName': instance.displayName,
  'isActive': instance.isActive,
  'isComplete': instance.isComplete,
  'progress': instance.progress,
  'current': instance.current,
  'total': instance.total,
};
