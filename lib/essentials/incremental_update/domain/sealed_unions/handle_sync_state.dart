import 'package:freezed_annotation/freezed_annotation.dart';

part 'handle_sync_state.freezed.dart';

@freezed
sealed class HandleSyncState with _$HandleSyncState {
  const factory HandleSyncState.sourceAndLedgerCursorsMatch() =
      HandleSyncCursorsMatch;

  const factory HandleSyncState.sourceAheadOfLedger() =
      HandleSyncSourceAheadOfLedger;

  const factory HandleSyncState.ledgerAheadOfSource() =
      HandleSyncLedgerAheadOfSource;
}
