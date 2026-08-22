import '../../../../essentials/source_scoped_import/domain/source_scoped_row_key.dart';
import '../../domain/entities/message_lens_attachment_recovery.dart';

/// Converts source-ledger rows into typed attachment-recovery evidence.
///
/// Canonical source-scoped identity interpretation stays in infrastructure;
/// application matching consumes only the resulting coherence fact.
class MessageLensAttachmentIdentityEvidenceFactory {
  const MessageLensAttachmentIdentityEvidenceFactory();

  MessageLensAttachmentRelationshipEvidence create({
    required int messageSsId,
    required int messageSourceId,
    required int originalMessageRowId,
    required String messageGuid,
    required int attachmentSsId,
    required int attachmentSourceId,
    required int originalAttachmentRowId,
    required String? attachmentGuid,
    required int relationshipOccurrenceCount,
    String? filename,
    String? transferName,
    String? mimeType,
    String? uti,
    int? totalBytes,
  }) {
    return MessageLensAttachmentRelationshipEvidence(
      messageSsId: messageSsId,
      messageSourceId: messageSourceId,
      originalMessageRowId: originalMessageRowId,
      messageGuid: messageGuid,
      attachmentSsId: attachmentSsId,
      attachmentSourceId: attachmentSourceId,
      originalAttachmentRowId: originalAttachmentRowId,
      attachmentGuid: attachmentGuid,
      relationshipOccurrenceCount: relationshipOccurrenceCount,
      sourceScopedIdentityIsCoherent: _isCoherent(
        messageSsId: messageSsId,
        messageSourceId: messageSourceId,
        originalMessageRowId: originalMessageRowId,
        attachmentSsId: attachmentSsId,
        attachmentSourceId: attachmentSourceId,
        originalAttachmentRowId: originalAttachmentRowId,
      ),
      filename: filename,
      transferName: transferName,
      mimeType: mimeType,
      uti: uti,
      totalBytes: totalBytes,
    );
  }

  static bool _isCoherent({
    required int messageSsId,
    required int messageSourceId,
    required int originalMessageRowId,
    required int attachmentSsId,
    required int attachmentSourceId,
    required int originalAttachmentRowId,
  }) {
    try {
      return messageSourceId == attachmentSourceId &&
          SourceScopedRowKey.unpackSourceId(messageSsId) == messageSourceId &&
          SourceScopedRowKey.unpackSourceRowId(messageSsId) ==
              originalMessageRowId &&
          SourceScopedRowKey.unpackSourceId(attachmentSsId) ==
              attachmentSourceId &&
          SourceScopedRowKey.unpackSourceRowId(attachmentSsId) ==
              originalAttachmentRowId;
    } on RangeError {
      return false;
    }
  }
}
