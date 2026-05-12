import 'package:freezed_annotation/freezed_annotation.dart';

part 'snapshot_delta.freezed.dart';

@freezed
abstract class MessageSnapshotDelta with _$MessageSnapshotDelta {
  const factory MessageSnapshotDelta({
    required int rowIdDelta,
    required int messageCountDelta,
  }) = _MessageSnapshotDelta;

  const MessageSnapshotDelta._();
  bool get isLiveSourceRowAhead => rowIdDelta > 0;
  bool get isLedgerSourceRowAhead => rowIdDelta < 0;
  bool get sourceAndLedgerCursorsMatch => rowIdDelta == 0;
}
