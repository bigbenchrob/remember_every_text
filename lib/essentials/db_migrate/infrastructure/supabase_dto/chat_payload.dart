class SupabaseChatPayload {
  const SupabaseChatPayload({
    required this.ownerUserId,
    required this.guid,
    required this.service,
    required this.isGroup,
    this.lastMessageAtUtc,
    this.lastSenderIdentityId,
    this.lastMessagePreview,
    this.unreadCount = 0,
    this.pinned = false,
    this.archived = false,
    this.mutedUntilUtc,
    this.favourite = false,
    this.createdAtUtc,
    this.updatedAtUtc,
  });

  final String ownerUserId;
  final String guid;
  final String service;
  final bool isGroup;
  final DateTime? lastMessageAtUtc;
  final int? lastSenderIdentityId;
  final String? lastMessagePreview;
  final int unreadCount;
  final bool pinned;
  final bool archived;
  final DateTime? mutedUntilUtc;
  final bool favourite;
  final DateTime? createdAtUtc;
  final DateTime? updatedAtUtc;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'owner_user_id': ownerUserId,
      'guid': guid,
      'service': service,
      'is_group': isGroup,
      'last_message_at_utc': lastMessageAtUtc?.toIso8601String(),
      'last_sender_identity_id': lastSenderIdentityId,
      'last_message_preview': lastMessagePreview,
      'unread_count': unreadCount,
      'pinned': pinned,
      'archived': archived,
      'muted_until_utc': mutedUntilUtc?.toIso8601String(),
      'favourite': favourite,
      'created_at_utc': createdAtUtc?.toIso8601String(),
      'updated_at_utc': updatedAtUtc?.toIso8601String(),
    };
  }
}
