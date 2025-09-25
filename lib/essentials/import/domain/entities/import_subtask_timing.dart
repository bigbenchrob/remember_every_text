import 'package:freezed_annotation/freezed_annotation.dart';

part 'import_subtask_timing.freezed.dart';
part 'import_subtask_timing.g.dart';

/// Timing information for import subtasks for performance monitoring
@freezed
abstract class ImportSubtaskTiming with _$ImportSubtaskTiming {
  const factory ImportSubtaskTiming({
    required String stageName,
    required String subtaskName,
    required DateTime startedAt,
    DateTime? endedAt,
    int? itemCount,
  }) = _ImportSubtaskTiming;

  factory ImportSubtaskTiming.fromJson(Map<String, dynamic> json) =>
      _$ImportSubtaskTimingFromJson(json);
}

/// Extension methods for ImportSubtaskTiming
extension ImportSubtaskTimingX on ImportSubtaskTiming {
  /// Create a new timing with end time and optional final item count
  ImportSubtaskTiming end({int? finalItemCount}) {
    return copyWith(
      endedAt: DateTime.now(),
      itemCount: finalItemCount ?? itemCount,
    );
  }

  /// Calculate duration if both start and end times are available
  Duration? get duration => endedAt?.difference(startedAt);
}
