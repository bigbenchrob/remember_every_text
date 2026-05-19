import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_message_join_sync_state.freezed.dart';

@freezed
sealed class ChatMessageJoinSyncState with _$ChatMessageJoinSyncState {
  const factory ChatMessageJoinSyncState.sourceAndLedgerTopologyMatch() =
      ChatMessageJoinSourceAndLedgerTopologyMatch;

  const factory ChatMessageJoinSyncState.sourceTopologyAheadOfLedger() =
      ChatMessageJoinSourceTopologyAheadOfLedger;

  const factory ChatMessageJoinSyncState.ledgerTopologyAheadOfSource() =
      ChatMessageJoinLedgerTopologyAheadOfSource;

  const factory ChatMessageJoinSyncState.topologyNotYetImported() =
      ChatMessageJoinTopologyNotYetImported;
}
