class SupabaseAttachmentPayload {
  const SupabaseAttachmentPayload({
    required this.ownerUserId,
    required this.messageGuid,
    this.importAttachmentId,
    this.localPath,
    this.mimeType,
    this.uti,
    this.transferName,
    this.sizeBytes,
    this.isSticker = false,
    this.thumbPath,
    this.createdAtUtc,
  });

  final String ownerUserId;
  final String messageGuid;
  final int? importAttachmentId;
  final String? localPath;
  final String? mimeType;
  final String? uti;
  final String? transferName;
  final int? sizeBytes;
  final bool isSticker;
  final String? thumbPath;
  final DateTime? createdAtUtc;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'owner_user_id': ownerUserId,
      'message_guid': messageGuid,
      'import_attachment_id': importAttachmentId,
      'local_path': localPath,
      'mime_type': mimeType,
      'uti': uti,
      'transfer_name': transferName,
      'size_bytes': sizeBytes,
      'is_sticker': isSticker,
      'thumb_path': thumbPath,
      'created_at_utc': createdAtUtc?.toIso8601String(),
    };
  }
}
