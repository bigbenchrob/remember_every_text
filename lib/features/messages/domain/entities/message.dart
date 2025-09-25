// lib/features/messages/domain/entities/message.dart
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../chats/domain/value_objects/chat_id.dart';
import '../value_objects/message_id.dart';

part 'message.freezed.dart';

/// Aggregate Root: **Message aggregate**
///
/// - This class *is* the aggregate root (we avoid a `MessageAggregate` type).
/// - Each Message belongs to **exactly one Chat** (`chatId`).
/// - Message content (`text`) is **immutable post-ingest**.
///   Edits should be modeled as new events/revisions in the ETL layer.
/// - Reactions/attachments are subordinate value objects/entities and
///   should not be modeled as aggregates.
///
/// Chat membership invariants are enforced in the Chat aggregate; here we only
/// require that `senderHandleId` is non-empty.
@freezed
abstract class Message with _$Message {
  // enables custom helpers

  /// Core state of the Message aggregate root.
  @Assert('senderHandleId.isNotEmpty', 'senderHandleId cannot be empty')
  const factory Message({
    /// Stable identifier for the message (macOS `message.guid` or ROWID string).
    required MessageId id,

    /// Foreign key reference to the owning Chat aggregate.
    required ChatId chatId,

    /// The handleId of the sender (must correspond to a Chat participant).
    required String senderHandleId,

    /// Time the message was sent.
    required DateTime sentAt,

    /// Decoded message text (from attributedBody). Immutable post-ingest.
    required String text,

    /// Whether this message originated from the local user.
    required bool isFromMe,
  }) = _Message;
  const Message._();

  /// Render a short preview (used for chat list UI).
  String get preview =>
      text.length <= 140 ? text : '${text.substring(0, 140)}…';
}
