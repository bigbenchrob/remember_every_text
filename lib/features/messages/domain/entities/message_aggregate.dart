import 'package:freezed_annotation/freezed_annotation.dart';

part 'message_aggregate.freezed.dart';
part 'message_aggregate.g.dart';

/// Message Aggregate Root
///
/// Represents a discrete communication unit with content, metadata, and attachments.
/// Independent of chat context for flexibility in forwarding, search, etc.
@freezed
abstract class Message with _$Message {
  const factory Message({
    required MessageId id,
    required MessageContent content,
    required MessageSender sender,
    required MessageTimestamp timestamp,
    required MessageDirection direction,
    required MessageStatus status,
    @Default([]) List<MessageAttachment> attachments,
    MessageReply? replyTo,
    MessageEditing? editing,
    ImportMetadata? importMetadata,
  }) = _Message;

  const Message._();

  factory Message.fromJson(Map<String, dynamic> json) =>
      _$MessageFromJson(json);

  // Domain behavior methods

  /// Add attachment to message
  Message addAttachment(MessageAttachment attachment) {
    return copyWith(attachments: [...attachments, attachment]);
  }

  /// Remove attachment from message
  Message removeAttachment(AttachmentId attachmentId) {
    final newAttachments = attachments
        .where((a) => a.id != attachmentId)
        .toList();
    return copyWith(attachments: newAttachments);
  }

  /// Edit message content (if supported)
  Message editContent(MessageContent newContent, DateTime editedAt) {
    if (!canEdit) {
      throw MessageInvariantViolation('Message cannot be edited');
    }

    final newEditing =
        editing?.addEdit(newContent, editedAt) ??
        MessageEditing.initial(content, newContent, editedAt);

    return copyWith(content: newContent, editing: newEditing);
  }

  /// Check if message can be edited
  bool get canEdit {
    // Business rules for editing (time limits, message type, etc.)
    if (direction == MessageDirection.incoming) {
      return false;
    }
    if (timestamp.value.difference(DateTime.now()).inHours > 24) {
      return false;
    }
    return true;
  }

  /// Check if message has content
  bool get hasContent => content.hasText || attachments.isNotEmpty;

  /// Get display text for message
  String get displayText => content.displayText;

  /// Check if message is from current user
  bool get isFromMe => direction == MessageDirection.outgoing;
}

/// Message unique identifier
@freezed
abstract class MessageId with _$MessageId {
  const factory MessageId(String value) = _MessageId;
  factory MessageId.fromJson(Map<String, dynamic> json) =>
      _$MessageIdFromJson(json);

  factory MessageId.generate() => MessageId(_generateUuid());
  factory MessageId.fromSource(String sourceSystem, String sourceId) {
    return MessageId('$sourceSystem:$sourceId');
  }
}

/// Message content with various types
@freezed
abstract class MessageContent with _$MessageContent {
  const factory MessageContent({
    String? plainText,
    String? richText,
    MessageContentType? contentType,
  }) = _MessageContent;

  const MessageContent._();

  factory MessageContent.fromJson(Map<String, dynamic> json) =>
      _$MessageContentFromJson(json);

  factory MessageContent.plain(String text) {
    if (text.trim().isEmpty) {
      throw MessageValidationError('Message text cannot be empty');
    }

    return MessageContent(
      plainText: text.trim(),
      contentType: MessageContentType.plainText,
    );
  }

  factory MessageContent.rich(String richText, String plainText) {
    return MessageContent(
      richText: richText,
      plainText: plainText,
      contentType: MessageContentType.richText,
    );
  }

  factory MessageContent.empty() {
    return const MessageContent(contentType: MessageContentType.attachmentOnly);
  }

  /// Check if content has text
  bool get hasText => plainText != null && plainText!.isNotEmpty;

  /// Get display text
  String get displayText => plainText ?? richText ?? '[No content]';

  /// Get content length
  int get length => displayText.length;
}

/// Message content types
enum MessageContentType { plainText, richText, attachmentOnly, system }

/// Message sender information
@freezed
abstract class MessageSender with _$MessageSender {
  const factory MessageSender({
    ContactId? contactId,
    required HandleId handleId,
    String? displayName,
  }) = _MessageSender;

  factory MessageSender.fromJson(Map<String, dynamic> json) =>
      _$MessageSenderFromJson(json);

  factory MessageSender.known(
    ContactId contactId,
    HandleId handleId,
    String displayName,
  ) {
    return MessageSender(
      contactId: contactId,
      handleId: handleId,
      displayName: displayName,
    );
  }

  factory MessageSender.unknown(HandleId handleId) {
    return MessageSender(handleId: handleId);
  }
}

/// Message timestamp with validation
@freezed
abstract class MessageTimestamp with _$MessageTimestamp {
  const factory MessageTimestamp({
    required DateTime value,
    TimestampPrecision? precision,
  }) = _MessageTimestamp;

  const MessageTimestamp._();

  factory MessageTimestamp.fromJson(Map<String, dynamic> json) =>
      _$MessageTimestampFromJson(json);

  factory MessageTimestamp.now() => MessageTimestamp(
    value: DateTime.now(),
    precision: TimestampPrecision.millisecond,
  );

  factory MessageTimestamp.fromUnixSeconds(int unixSeconds) {
    final dateTime = DateTime.fromMillisecondsSinceEpoch(unixSeconds * 1000);
    return MessageTimestamp(
      value: dateTime,
      precision: TimestampPrecision.second,
    );
  }

  factory MessageTimestamp.fromAppleTime(int appleNanoseconds) {
    // Convert Apple nanoseconds to Unix timestamp
    final unixSeconds = ((appleNanoseconds / 1000000000) + 978307200).round();
    return MessageTimestamp.fromUnixSeconds(unixSeconds);
  }

  /// Convert to Unix seconds
  int get unixSeconds => (value.millisecondsSinceEpoch / 1000).round();
}

/// Timestamp precision levels
enum TimestampPrecision { second, millisecond, nanosecond }

/// Message direction
enum MessageDirection { incoming, outgoing }

/// Message status
@freezed
abstract class MessageStatus with _$MessageStatus {
  const factory MessageStatus({
    @Default(DeliveryStatus.unknown) DeliveryStatus delivery,
    @Default(ReadStatus.unknown) ReadStatus read,
    DateTime? deliveredAt,
    DateTime? readAt,
  }) = _MessageStatus;

  factory MessageStatus.fromJson(Map<String, dynamic> json) =>
      _$MessageStatusFromJson(json);
}

/// Delivery status options
enum DeliveryStatus { unknown, pending, sent, delivered, failed }

/// Read status options
enum ReadStatus { unknown, unread, read }

/// Message attachment
@freezed
abstract class MessageAttachment with _$MessageAttachment {
  const factory MessageAttachment({
    required AttachmentId id,
    required String filename,
    required AttachmentType type,
    required int sizeBytes,
    String? mimeType,
    String? localPath,
    String? cloudUrl,
    AttachmentMetadata? metadata,
  }) = _MessageAttachment;

  factory MessageAttachment.fromJson(Map<String, dynamic> json) =>
      _$MessageAttachmentFromJson(json);
}

/// Attachment unique identifier
@freezed
abstract class AttachmentId with _$AttachmentId {
  const factory AttachmentId(String value) = _AttachmentId;
  factory AttachmentId.fromJson(Map<String, dynamic> json) =>
      _$AttachmentIdFromJson(json);

  factory AttachmentId.generate() => AttachmentId(_generateUuid());
}

/// Attachment types
enum AttachmentType { image, video, audio, document, contact, location, other }

/// Attachment metadata
@freezed
abstract class AttachmentMetadata with _$AttachmentMetadata {
  const factory AttachmentMetadata({
    int? width,
    int? height,
    int? durationMs,
    String? title,
    String? description,
  }) = _AttachmentMetadata;

  factory AttachmentMetadata.fromJson(Map<String, dynamic> json) =>
      _$AttachmentMetadataFromJson(json);
}

/// Message reply information
@freezed
abstract class MessageReply with _$MessageReply {
  const factory MessageReply({
    required MessageId originalMessageId,
    String? originalText,
    ContactId? originalSenderId,
  }) = _MessageReply;

  factory MessageReply.fromJson(Map<String, dynamic> json) =>
      _$MessageReplyFromJson(json);
}

/// Message editing history
@freezed
abstract class MessageEditing with _$MessageEditing {
  const factory MessageEditing({
    required MessageContent originalContent,
    required List<MessageEdit> edits,
  }) = _MessageEditing;

  const MessageEditing._();

  factory MessageEditing.fromJson(Map<String, dynamic> json) =>
      _$MessageEditingFromJson(json);

  factory MessageEditing.initial(
    MessageContent original,
    MessageContent edited,
    DateTime editedAt,
  ) {
    return MessageEditing(
      originalContent: original,
      edits: [MessageEdit(content: edited, editedAt: editedAt)],
    );
  }

  /// Add a new edit
  MessageEditing addEdit(MessageContent newContent, DateTime editedAt) {
    return copyWith(
      edits: [
        ...edits,
        MessageEdit(content: newContent, editedAt: editedAt),
      ],
    );
  }

  /// Get the latest edit
  MessageEdit get latestEdit => edits.last;
}

/// Individual message edit
@freezed
abstract class MessageEdit with _$MessageEdit {
  const factory MessageEdit({
    required MessageContent content,
    required DateTime editedAt,
  }) = _MessageEdit;

  factory MessageEdit.fromJson(Map<String, dynamic> json) =>
      _$MessageEditFromJson(json);
}

/// Contact ID reference (shared with Chat aggregate)
@freezed
abstract class ContactId with _$ContactId {
  const factory ContactId(String value) = _ContactId;
  factory ContactId.fromJson(Map<String, dynamic> json) =>
      _$ContactIdFromJson(json);

  factory ContactId.generate() => ContactId(_generateUuid());
}

/// Handle ID reference (shared with Chat aggregate)
@freezed
abstract class HandleId with _$HandleId {
  const factory HandleId(String value) = _HandleId;
  factory HandleId.fromJson(Map<String, dynamic> json) =>
      _$HandleIdFromJson(json);

  factory HandleId.fromServiceAndAddress(String service, String address) {
    return HandleId('$service:$address');
  }
}

/// Import metadata for ETL tracking (shared)
@freezed
abstract class ImportMetadata with _$ImportMetadata {
  const factory ImportMetadata({
    required String sourceSystem,
    required int sourceId,
    required DateTime importedAt,
    String? sourceHash,
    int? sourceVersion,
  }) = _ImportMetadata;

  factory ImportMetadata.fromJson(Map<String, dynamic> json) =>
      _$ImportMetadataFromJson(json);
}

/// Domain exceptions
class MessageInvariantViolation extends Error {
  final String message;
  MessageInvariantViolation(this.message);

  @override
  String toString() => 'MessageInvariantViolation: $message';
}

class MessageValidationError extends Error {
  final String message;
  MessageValidationError(this.message);

  @override
  String toString() => 'MessageValidationError: $message';
}

// Utility function for UUID generation (placeholder)
String _generateUuid() {
  // Implementation would use uuid package
  return 'uuid-placeholder-${DateTime.now().millisecondsSinceEpoch}';
}
