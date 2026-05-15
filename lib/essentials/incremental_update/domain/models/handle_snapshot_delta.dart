import 'package:freezed_annotation/freezed_annotation.dart';

part 'handle_snapshot_delta.freezed.dart';

@freezed
abstract class HandleSnapshotDelta with _$HandleSnapshotDelta {
  const factory HandleSnapshotDelta({
    required int rowIdDelta,
    required int handleCountDelta,
  }) = _HandleSnapshotDelta;

  const HandleSnapshotDelta._();

  bool get isLiveSourceRowAhead => rowIdDelta > 0;
  bool get isLedgerSourceRowAhead => rowIdDelta < 0;
  bool get sourceAndLedgerCursorsMatch => rowIdDelta == 0;
}
