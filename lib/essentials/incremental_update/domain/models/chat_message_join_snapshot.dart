import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_message_join_snapshot.freezed.dart';

@freezed
abstract class ChatMessageJoinSnapshot with _$ChatMessageJoinSnapshot {
  const factory ChatMessageJoinSnapshot({
    required int maxRowId,
    required int totalJoinCount,
    required int maxMessageRowId,
    required int maxChatRowId,
    required bool sourceScopedObservationAvailable,
  }) = _ChatMessageJoinSnapshot;
}
