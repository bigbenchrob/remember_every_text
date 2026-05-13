import '../../../domain/models/message_migration_delta.dart';
import '../../../domain/sealed_unions/message_migration_state.dart';

class MessageMigrationStateIntegrator {
  const MessageMigrationStateIntegrator();

  MessageMigrationState integrate(MessageMigrationDelta delta) {
    if (delta.isLedgerAheadOfProjection) {
      return const MessageMigrationState.ledgerAheadOfProjection();
    }

    if (delta.isProjectionAheadOfLedger) {
      return const MessageMigrationState.projectionAheadOfLedger();
    }

    return const MessageMigrationState.projectionCaughtUp();
  }
}
