// lib/features/chats/domain/entities/chat.dart
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../messages/domain/value_objects/message_id.dart';
import '../value_objects/chat_id.dart';
import '../value_objects/chat_participant.dart';

part 'chat.freezed.dart';

/// Aggregate Root: **Chat aggregate**
///
/// - This class *is* the aggregate root (we avoid a `ChatAggregate` type).
/// - Participants are modeled as value objects (`Participant`) and must be unique
///   by `handleId`.
/// - `lastMessageId`/`lastTimestamp` are derived/maintained by application logic
///   (e.g., after importing/appending messages). They should always refer to a
///   message belonging to this chat.
///
/// Contacts are **external reference data**; do not create a Contact aggregate.
/// Join/display names via projections at the query layer.
@freezed
abstract class Chat with _$Chat {
  /// Core state of the Chat aggregate root.
  @Assert(
    'participants.map((p) => p.handleId).toSet().length == participants.length',
    'participants must be unique by handleId',
  )
  const factory Chat({
    /// Stable identifier for the chat (e.g., canonicalized macOS chat.guid).
    required ChatId id,

    /// Unique set of participants (value objects). Enforced via @Assert above.
    @Default(<ChatParticipant>[]) List<ChatParticipant> participants,

    /// Group title (if any). DMs typically leave this null.
    String? title,

    /// Pointer to the newest visible message for list rendering.
    MessageId? lastMessageId,

    /// Timestamp of the newest visible message.
    DateTime? lastTimestamp,

    /// User preference flags (domain-level; device-specific as needed).
    @Default(false) bool muted,
    @Default(false) bool pinned,
  }) = _Chat;

  const Chat._(); // enables custom getters/helpers

  /// Convenience: number of participants.
  int get participantCount => participants.length;
}
