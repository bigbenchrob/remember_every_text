import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_aggregate.freezed.dart';
part 'chat_aggregate.g.dart';

/// Chat Aggregate Root
///
/// Represents a conversation context with one or more participants.
/// Maintains conversation-level invariants and metadata.
@freezed
abstract class Chat with _$Chat {
  const factory Chat({
    required ChatId id,
    required String guid,
    required ChatDisplayName displayName,
    required List<ChatParticipant> participants,
    required ChatTimestamps timestamps,
    required ChatStats stats,
    ContactId? primaryContactId, // For 1:1 chats
    @Default([]) List<String> tags,
    ImportMetadata? importMetadata,
  }) = _Chat;

  const Chat._();

  factory Chat.fromJson(Map<String, dynamic> json) => _$ChatFromJson(json);

  // Domain behavior methods

  /// Add a participant to the chat
  Chat addParticipant(ChatParticipant participant) {
    if (participants.any((p) => p.contactId == participant.contactId)) {
      throw ChatInvariantViolation('Participant already exists in chat');
    }

    return copyWith(
      participants: [...participants, participant],
      timestamps: timestamps.copyWith(lastModified: DateTime.now()),
    );
  }

  /// Remove a participant from the chat
  Chat removeParticipant(ContactId contactId) {
    final newParticipants = participants
        .where((p) => p.contactId != contactId)
        .toList();

    if (newParticipants.isEmpty) {
      throw ChatInvariantViolation('Chat must have at least one participant');
    }

    return copyWith(
      participants: newParticipants,
      timestamps: timestamps.copyWith(lastModified: DateTime.now()),
    );
  }

  /// Update chat display name
  Chat updateDisplayName(ChatDisplayName newDisplayName) {
    return copyWith(
      displayName: newDisplayName,
      timestamps: timestamps.copyWith(lastModified: DateTime.now()),
    );
  }

  /// Check if chat is a direct message (1:1)
  bool get isDirectMessage => participants.length == 1;

  /// Check if chat is a group conversation
  bool get isGroupChat => participants.length > 1;

  /// Get the other participant in a direct message
  ChatParticipant? get otherParticipant {
    if (!isDirectMessage) {
      return null;
    }
    return participants.first;
  }
}

/// Chat unique identifier
@freezed
abstract class ChatId with _$ChatId {
  const factory ChatId(String value) = _ChatId;
  factory ChatId.fromJson(Map<String, dynamic> json) => _$ChatIdFromJson(json);

  factory ChatId.generate() => ChatId(_generateUuid());
  factory ChatId.fromGuid(String guid) => ChatId(guid);
}

/// Chat display name with validation
@freezed
abstract class ChatDisplayName with _$ChatDisplayName {
  const factory ChatDisplayName({
    required String value,
    required DisplayNameSource source,
  }) = _ChatDisplayName;

  const ChatDisplayName._();

  factory ChatDisplayName.fromJson(Map<String, dynamic> json) =>
      _$ChatDisplayNameFromJson(json);

  factory ChatDisplayName.explicit(String name) {
    if (name.trim().isEmpty) {
      throw ChatValidationError('Display name cannot be empty');
    }
    if (name.length > 200) {
      throw ChatValidationError('Display name too long (max 200 characters)');
    }

    return ChatDisplayName(
      value: name.trim(),
      source: DisplayNameSource.explicit,
    );
  }

  factory ChatDisplayName.derived(String name, DisplayNameSource source) {
    return ChatDisplayName(
      value: name.isEmpty ? 'Unnamed Chat' : name,
      source: source,
    );
  }
}

/// Source of chat display name
enum DisplayNameSource {
  explicit, // User-set name
  contact, // Derived from contact name
  handle, // Derived from handle/phone
  participants, // Derived from participant list
  fallback, // System-generated fallback
}

/// Chat participant information
@freezed
abstract class ChatParticipant with _$ChatParticipant {
  const factory ChatParticipant({
    required ContactId contactId,
    required HandleId handleId,
    required DateTime joinedAt,
    DateTime? leftAt,
    @Default(ChatRole.member) ChatRole role,
  }) = _ChatParticipant;

  factory ChatParticipant.fromJson(Map<String, dynamic> json) =>
      _$ChatParticipantFromJson(json);
}

/// Participant role in chat
enum ChatRole { member, admin, owner }

/// Chat timestamp information
@freezed
abstract class ChatTimestamps with _$ChatTimestamps {
  const factory ChatTimestamps({
    required DateTime createdAt,
    required DateTime lastModified,
    DateTime? firstMessageAt,
    DateTime? lastMessageAt,
  }) = _ChatTimestamps;

  factory ChatTimestamps.fromJson(Map<String, dynamic> json) =>
      _$ChatTimestampsFromJson(json);

  factory ChatTimestamps.now() =>
      ChatTimestamps(createdAt: DateTime.now(), lastModified: DateTime.now());
}

/// Chat statistics
@freezed
abstract class ChatStats with _$ChatStats {
  const factory ChatStats({
    @Default(0) int messageCount,
    @Default(0) int unreadCount,
    @Default(0) int attachmentCount,
  }) = _ChatStats;

  factory ChatStats.fromJson(Map<String, dynamic> json) =>
      _$ChatStatsFromJson(json);
}

/// Contact ID reference
@freezed
abstract class ContactId with _$ContactId {
  const factory ContactId(String value) = _ContactId;
  factory ContactId.fromJson(Map<String, dynamic> json) =>
      _$ContactIdFromJson(json);

  factory ContactId.generate() => ContactId(_generateUuid());
}

/// Handle ID reference
@freezed
abstract class HandleId with _$HandleId {
  const factory HandleId(String value) = _HandleId;
  factory HandleId.fromJson(Map<String, dynamic> json) =>
      _$HandleIdFromJson(json);

  factory HandleId.fromServiceAndAddress(String service, String address) {
    return HandleId('$service:$address');
  }
}

/// Import metadata for ETL tracking
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
class ChatInvariantViolation extends Error {
  final String message;
  ChatInvariantViolation(this.message);

  @override
  String toString() => 'ChatInvariantViolation: $message';
}

class ChatValidationError extends Error {
  final String message;
  ChatValidationError(this.message);

  @override
  String toString() => 'ChatValidationError: $message';
}

// Utility function for UUID generation (placeholder)
String _generateUuid() {
  // Implementation would use uuid package
  return 'uuid-placeholder-${DateTime.now().millisecondsSinceEpoch}';
}
