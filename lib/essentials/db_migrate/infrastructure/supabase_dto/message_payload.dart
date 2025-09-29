class SupabaseMessagePayload {
  const SupabaseMessagePayload({
    required this.ownerUserId,
    required this.guid,
    required this.chatId,
    required this.isFromMe,
    this.senderIdentityId,
    this.sentAtUtc,
    this.deliveredAtUtc,
    this.readAtUtc,
    this.status = 'unknown',
    this.text,
    this.hasAttachments = false,
    this.replyToGuid,
    this.systemType,
    this.reactionCarrier = false,
    this.balloonBundleId,
    this.reactionSummaryJson,
    this.isStarred = false,
    this.isDeletedLocal = false,
    this.updatedAtUtc,
  });

  final String ownerUserId;
  final String guid;
  final int chatId;
  final bool isFromMe;
  final int? senderIdentityId;
  final DateTime? sentAtUtc;
  final DateTime? deliveredAtUtc;
  final DateTime? readAtUtc;
  final String status;
  final String? text;
  final bool hasAttachments;
  final String? replyToGuid;
  final String? systemType;
  final bool reactionCarrier;
  final String? balloonBundleId;
  final Map<String, dynamic>? reactionSummaryJson;
  final bool isStarred;
  final bool isDeletedLocal;
  final DateTime? updatedAtUtc;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'owner_user_id': ownerUserId,
      'guid': guid,
      'chat_id': chatId,
      'sender_identity_id': senderIdentityId,
      'is_from_me': isFromMe,
      'sent_at_utc': sentAtUtc?.toIso8601String(),
      'delivered_at_utc': deliveredAtUtc?.toIso8601String(),
      'read_at_utc': readAtUtc?.toIso8601String(),
      'status': status,
      'text': text,
      'has_attachments': hasAttachments,
      'reply_to_guid': replyToGuid,
      'system_type': systemType,
      'reaction_carrier': reactionCarrier,
      'balloon_bundle_id': balloonBundleId,
      'reaction_summary_json': reactionSummaryJson,
      'is_starred': isStarred,
      'is_deleted_local': isDeletedLocal,
      'updated_at_utc': updatedAtUtc?.toIso8601String(),
    };
  }
}
