import 'package:freezed_annotation/freezed_annotation.dart';

part 'message_migration_state.freezed.dart';

@freezed
sealed class MessageMigrationState with _$MessageMigrationState {
  const factory MessageMigrationState.projectionCaughtUp() =
      MessageMigrationProjectionCaughtUp;

  const factory MessageMigrationState.ledgerAheadOfProjection() =
      MessageMigrationLedgerAheadOfProjection;

  const factory MessageMigrationState.projectionAheadOfLedger() =
      MessageMigrationProjectionAheadOfLedger;
}
