import '../value_objects/db_migration_stage.dart';

/// Immutable snapshot describing the current progress of the projection
/// pipeline that migrates data from the ledger into the working database.
class DbMigrationProgress {
  const DbMigrationProgress({
    required this.stage,
    required this.overallProgress,
    required this.message,
    this.stageProgress,
    this.stageCurrent,
    this.stageTotal,
  });

  /// Current stage in the migration pipeline.
  final DbMigrationStage stage;

  /// Overall completion ratio (0.0-1.0).
  final double overallProgress;

  /// Human readable message describing the current work.
  final String message;

  /// Optional sub-progress within the stage (0.0-1.0).
  final double? stageProgress;

  /// Optional current item index for granular reporting.
  final int? stageCurrent;

  /// Optional total item count for granular reporting.
  final int? stageTotal;

  DbMigrationProgress copyWith({
    DbMigrationStage? stage,
    double? overallProgress,
    String? message,
    double? stageProgress,
    int? stageCurrent,
    int? stageTotal,
  }) {
    return DbMigrationProgress(
      stage: stage ?? this.stage,
      overallProgress: overallProgress ?? this.overallProgress,
      message: message ?? this.message,
      stageProgress: stageProgress ?? this.stageProgress,
      stageCurrent: stageCurrent ?? this.stageCurrent,
      stageTotal: stageTotal ?? this.stageTotal,
    );
  }
}
