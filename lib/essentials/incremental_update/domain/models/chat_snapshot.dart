import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_snapshot.freezed.dart';

@freezed
abstract class ChatSnapshot with _$ChatSnapshot {
  const factory ChatSnapshot({
    required int maxRowId,
    required int totalChatCount,
  }) = _ChatSnapshot;
}
