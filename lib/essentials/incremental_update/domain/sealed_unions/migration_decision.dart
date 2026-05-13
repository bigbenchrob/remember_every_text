import 'package:freezed_annotation/freezed_annotation.dart';

part 'migration_decision.freezed.dart';

@freezed
sealed class MigrationDecision with _$MigrationDecision {
  const factory MigrationDecision.doNothing() = MigrationDecisionDoNothing;

  const factory MigrationDecision.considerShadowMigration() =
      MigrationDecisionConsiderShadowMigration;

  const factory MigrationDecision.blockAndReportProjectionAhead() =
      MigrationDecisionBlockAndReportProjectionAhead;
}
