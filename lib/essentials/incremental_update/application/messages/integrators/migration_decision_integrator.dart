import '../../../domain/sealed_unions/message_migration_state.dart';
import '../../../domain/sealed_unions/migration_decision.dart';

class MigrationDecisionIntegrator {
  const MigrationDecisionIntegrator();

  MigrationDecision integrate(MessageMigrationState state) {
    return switch (state) {
      MessageMigrationProjectionCaughtUp() =>
        const MigrationDecision.doNothing(),
      MessageMigrationLedgerAheadOfProjection() =>
        const MigrationDecision.considerShadowMigration(),
      MessageMigrationProjectionAheadOfLedger() =>
        const MigrationDecision.blockAndReportProjectionAhead(),
    };
  }
}
