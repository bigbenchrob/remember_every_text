import 'package:freezed_annotation/freezed_annotation.dart';

part 'import_progress_stage.freezed.dart';
part 'import_progress_stage.g.dart';

/// Represents the state and progress of an import stage
@freezed
abstract class ImportProgressStage with _$ImportProgressStage {
  const factory ImportProgressStage({
    required String name,
    required String displayName,
    @Default(false) bool isActive,
    @Default(false) bool isComplete,
    double? progress,
    int? current,
    int? total,
  }) = _ImportProgressStage;

  factory ImportProgressStage.fromJson(Map<String, dynamic> json) =>
      _$ImportProgressStageFromJson(json);
}
