import 'package:freezed_annotation/freezed_annotation.dart';

part 'handle_snapshot.freezed.dart';

@freezed
abstract class HandleSnapshot with _$HandleSnapshot {
  const factory HandleSnapshot({
    required int maxRowId,
    required int totalHandleCount,
  }) = _HandleSnapshot;
}
