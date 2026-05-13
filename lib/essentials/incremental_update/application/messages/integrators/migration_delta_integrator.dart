import '../../../domain/models/message_migration_delta.dart';
import '../../../domain/models/message_projection_snapshot.dart';

class MessageMigrationDeltaIntegrator {
  const MessageMigrationDeltaIntegrator();

  MessageMigrationDelta integrate({
    required MessageProjectionSnapshot ledger,
    required MessageProjectionSnapshot projection,
  }) {
    return MessageMigrationDelta(
      messageIdDelta: ledger.maxMessageId - projection.maxMessageId,
      messageCountDelta:
          ledger.totalMessageCount - projection.totalMessageCount,
    );
  }
}
