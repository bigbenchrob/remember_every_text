import 'package:freezed_annotation/freezed_annotation.dart';

part 'live_chat_db_message_snapshot.freezed.dart';

@freezed
abstract class LiveChatDbMessageSnapshot with _$LiveChatDbMessageSnapshot {
  const factory LiveChatDbMessageSnapshot({
    required int maxRowId,
    required int totalMessageCount,
  }) = _LiveChatDbMessageSnapshot;

  const LiveChatDbMessageSnapshot._();
}
