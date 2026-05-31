import '../entities/attachment_info.dart';

class RecoveredUnlinkedMessageItem {
  const RecoveredUnlinkedMessageItem({
    required this.id,
    required this.guid,
    required this.senderHandleId,
    this.contactName,
    this.rawItemType,
    this.rawAssociatedMessageType,
    required this.semanticKind,
    required this.isSparseArtifact,
    required this.isFromMe,
    required this.isInferred,
    required this.senderLabel,
    required this.service,
    required this.text,
    required this.sentAt,
    required this.itemType,
    required this.hasAttachments,
    required this.attachmentCount,
    required this.attachments,
  });

  final int id;
  final String guid;
  final int? senderHandleId;
  final String? contactName;
  final int? rawItemType;
  final int? rawAssociatedMessageType;
  final String semanticKind;
  final bool isSparseArtifact;
  final bool isFromMe;
  final bool isInferred;
  final String senderLabel;
  final String service;
  final String text;
  final DateTime? sentAt;
  final String itemType;
  final bool hasAttachments;
  final int attachmentCount;
  final List<AttachmentInfo> attachments;
}

List<RecoveredUnlinkedMessageItem> filterRecoveredTimelineMessages({
  required List<RecoveredUnlinkedMessageItem> messages,
  required bool onlyNoHandleFromMe,
}) {
  if (!onlyNoHandleFromMe) {
    return messages;
  }

  return messages
      .where((message) {
        return message.isFromMe && message.senderHandleId == null;
      })
      .toList(growable: false);
}

abstract interface class RecoveredMessageEvidenceRepository {
  Stream<List<RecoveredUnlinkedMessageItem>> watchMessages({
    int? contactId,
    Set<int>? scopedHandleIds,
  });
}
