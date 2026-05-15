import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_snapshot_delta.freezed.dart';

@freezed
abstract class ChatSnapshotDelta with _$ChatSnapshotDelta {
  const factory ChatSnapshotDelta({
    required int rowIdDelta,
    required int chatCountDelta,
  }) = _ChatSnapshotDelta;

  const ChatSnapshotDelta._();

  bool get isLiveSourceRowAhead => rowIdDelta > 0;
  bool get isLedgerSourceRowAhead => rowIdDelta < 0;
  bool get sourceAndLedgerCursorsMatch => rowIdDelta == 0;
}
