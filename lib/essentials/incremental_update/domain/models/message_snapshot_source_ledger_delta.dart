import 'package:freezed_annotation/freezed_annotation.dart';

part 'message_snapshot_source_ledger_delta.freezed.dart';

@freezed
abstract class MessageSnapshotSourceLedgerDelta
    with _$MessageSnapshotSourceLedgerDelta {
  const factory MessageSnapshotSourceLedgerDelta({
    required int rowIdDelta,
    required int messageCountDelta,
  }) = _MessageSnapshotSourceLedgerDelta;

  const MessageSnapshotSourceLedgerDelta._();
  bool get isLiveSourceRowAhead => rowIdDelta > 0;
  bool get isLedgerSourceRowAhead => rowIdDelta < 0;
  bool get rowIdsMatch => rowIdDelta == 0;
}
