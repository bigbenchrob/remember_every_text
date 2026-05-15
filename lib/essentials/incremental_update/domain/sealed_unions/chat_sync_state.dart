import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_sync_state.freezed.dart';

@freezed
sealed class ChatSyncState with _$ChatSyncState {
  const factory ChatSyncState.sourceAndLedgerCursorsMatch() =
      ChatSyncCursorsMatch;

  const factory ChatSyncState.sourceAheadOfLedger() =
      ChatSyncSourceAheadOfLedger;

  const factory ChatSyncState.ledgerAheadOfSource() =
      ChatSyncLedgerAheadOfSource;
}
