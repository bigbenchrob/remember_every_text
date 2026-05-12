import 'package:freezed_annotation/freezed_annotation.dart';

part 'sync_state.freezed.dart';

@freezed
sealed class MessageSyncState with _$MessageSyncState {
  const factory MessageSyncState.sourceAndLedgerCursorsMatch() =
      MessageSyncCursorsMatch;

  const factory MessageSyncState.sourceAheadOfLedger() =
      MessageSyncSourceAheadOfLedger;

  const factory MessageSyncState.ledgerAheadOfSource() =
      MessageSyncLedgerAheadOfSource;
}
