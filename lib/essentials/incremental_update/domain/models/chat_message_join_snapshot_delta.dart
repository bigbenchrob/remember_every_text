import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_message_join_snapshot_delta.freezed.dart';

@freezed
abstract class ChatMessageJoinSnapshotDelta
    with _$ChatMessageJoinSnapshotDelta {
  const factory ChatMessageJoinSnapshotDelta({
    required int rowIdDelta,
    required int joinCountDelta,
    required int messageRowIdDelta,
    required int chatRowIdDelta,
    required bool ledgerSourceScopedObservationAvailable,
  }) = _ChatMessageJoinSnapshotDelta;

  const ChatMessageJoinSnapshotDelta._();

  bool get isSourceTopologyAhead => rowIdDelta > 0;
  bool get isLedgerTopologyAhead => rowIdDelta < 0;
  bool get sourceAndLedgerTopologyCursorsMatch => rowIdDelta == 0;
}
