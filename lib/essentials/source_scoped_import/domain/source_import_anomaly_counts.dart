import 'package:meta/meta.dart';

/// Exact, non-PII totals for source facts handled outside the normal path.
///
/// Each field names one approved domain outcome. This is intentionally not a
/// generic error bag: adding a field requires proving that the corresponding
/// degraded or omitted outcome preserves structural truth.
@immutable
final class SourceImportAnomalyCounts {
  const SourceImportAnomalyCounts({
    this.preservedUnnormalizedHandleCount = 0,
    this.messageTimestampUnavailableCount = 0,
    this.recoveredUnlinkedMessageCount = 0,
    this.richTextDecodeUnavailableCount = 0,
    this.attachmentMetadataDegradedCount = 0,
    this.unresolvedReactionTargetCount = 0,
    this.omittedContactRecordCount = 0,
    this.contactEnrichmentUnavailableCount = 0,
    this.omittedContactChannelCount = 0,
    this.omittedChatMessageRelationshipCount = 0,
    this.omittedChatHandleRelationshipCount = 0,
    this.omittedMessageAttachmentRelationshipCount = 0,
  }) : assert(preservedUnnormalizedHandleCount >= 0),
       assert(messageTimestampUnavailableCount >= 0),
       assert(recoveredUnlinkedMessageCount >= 0),
       assert(richTextDecodeUnavailableCount >= 0),
       assert(attachmentMetadataDegradedCount >= 0),
       assert(unresolvedReactionTargetCount >= 0),
       assert(omittedContactRecordCount >= 0),
       assert(contactEnrichmentUnavailableCount >= 0),
       assert(omittedContactChannelCount >= 0),
       assert(omittedChatMessageRelationshipCount >= 0),
       assert(omittedChatHandleRelationshipCount >= 0),
       assert(omittedMessageAttachmentRelationshipCount >= 0);

  static const empty = SourceImportAnomalyCounts();

  final int preservedUnnormalizedHandleCount;
  final int messageTimestampUnavailableCount;
  final int recoveredUnlinkedMessageCount;
  final int richTextDecodeUnavailableCount;
  final int attachmentMetadataDegradedCount;
  final int unresolvedReactionTargetCount;
  final int omittedContactRecordCount;
  final int contactEnrichmentUnavailableCount;
  final int omittedContactChannelCount;
  final int omittedChatMessageRelationshipCount;
  final int omittedChatHandleRelationshipCount;
  final int omittedMessageAttachmentRelationshipCount;

  int get totalCount =>
      preservedUnnormalizedHandleCount +
      messageTimestampUnavailableCount +
      recoveredUnlinkedMessageCount +
      richTextDecodeUnavailableCount +
      attachmentMetadataDegradedCount +
      unresolvedReactionTargetCount +
      omittedContactRecordCount +
      contactEnrichmentUnavailableCount +
      omittedContactChannelCount +
      omittedChatMessageRelationshipCount +
      omittedChatHandleRelationshipCount +
      omittedMessageAttachmentRelationshipCount;

  SourceImportAnomalyCounts mergeMaximum(SourceImportAnomalyCounts other) {
    return SourceImportAnomalyCounts(
      preservedUnnormalizedHandleCount: _max(
        preservedUnnormalizedHandleCount,
        other.preservedUnnormalizedHandleCount,
      ),
      messageTimestampUnavailableCount: _max(
        messageTimestampUnavailableCount,
        other.messageTimestampUnavailableCount,
      ),
      recoveredUnlinkedMessageCount: _max(
        recoveredUnlinkedMessageCount,
        other.recoveredUnlinkedMessageCount,
      ),
      richTextDecodeUnavailableCount: _max(
        richTextDecodeUnavailableCount,
        other.richTextDecodeUnavailableCount,
      ),
      attachmentMetadataDegradedCount: _max(
        attachmentMetadataDegradedCount,
        other.attachmentMetadataDegradedCount,
      ),
      unresolvedReactionTargetCount: _max(
        unresolvedReactionTargetCount,
        other.unresolvedReactionTargetCount,
      ),
      omittedContactRecordCount: _max(
        omittedContactRecordCount,
        other.omittedContactRecordCount,
      ),
      contactEnrichmentUnavailableCount: _max(
        contactEnrichmentUnavailableCount,
        other.contactEnrichmentUnavailableCount,
      ),
      omittedContactChannelCount: _max(
        omittedContactChannelCount,
        other.omittedContactChannelCount,
      ),
      omittedChatMessageRelationshipCount: _max(
        omittedChatMessageRelationshipCount,
        other.omittedChatMessageRelationshipCount,
      ),
      omittedChatHandleRelationshipCount: _max(
        omittedChatHandleRelationshipCount,
        other.omittedChatHandleRelationshipCount,
      ),
      omittedMessageAttachmentRelationshipCount: _max(
        omittedMessageAttachmentRelationshipCount,
        other.omittedMessageAttachmentRelationshipCount,
      ),
    );
  }

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'preserved_unnormalized_handle_count': preservedUnnormalizedHandleCount,
      'message_timestamp_unavailable_count': messageTimestampUnavailableCount,
      'recovered_unlinked_message_count': recoveredUnlinkedMessageCount,
      'rich_text_decode_unavailable_count': richTextDecodeUnavailableCount,
      'attachment_metadata_degraded_count': attachmentMetadataDegradedCount,
      'unresolved_reaction_target_count': unresolvedReactionTargetCount,
      'omitted_contact_record_count': omittedContactRecordCount,
      'contact_enrichment_unavailable_count': contactEnrichmentUnavailableCount,
      'omitted_contact_channel_count': omittedContactChannelCount,
      'omitted_chat_message_relationship_count':
          omittedChatMessageRelationshipCount,
      'omitted_chat_handle_relationship_count':
          omittedChatHandleRelationshipCount,
      'omitted_message_attachment_relationship_count':
          omittedMessageAttachmentRelationshipCount,
    };
  }

  factory SourceImportAnomalyCounts.fromJson(Map<String, Object?> json) {
    return SourceImportAnomalyCounts(
      preservedUnnormalizedHandleCount: _count(
        json,
        'preserved_unnormalized_handle_count',
      ),
      messageTimestampUnavailableCount: _count(
        json,
        'message_timestamp_unavailable_count',
      ),
      recoveredUnlinkedMessageCount: _count(
        json,
        'recovered_unlinked_message_count',
      ),
      richTextDecodeUnavailableCount: _count(
        json,
        'rich_text_decode_unavailable_count',
      ),
      attachmentMetadataDegradedCount: _count(
        json,
        'attachment_metadata_degraded_count',
      ),
      unresolvedReactionTargetCount: _count(
        json,
        'unresolved_reaction_target_count',
      ),
      omittedContactRecordCount: _count(json, 'omitted_contact_record_count'),
      contactEnrichmentUnavailableCount: _count(
        json,
        'contact_enrichment_unavailable_count',
      ),
      omittedContactChannelCount: _count(json, 'omitted_contact_channel_count'),
      omittedChatMessageRelationshipCount: _count(
        json,
        'omitted_chat_message_relationship_count',
      ),
      omittedChatHandleRelationshipCount: _count(
        json,
        'omitted_chat_handle_relationship_count',
      ),
      omittedMessageAttachmentRelationshipCount: _count(
        json,
        'omitted_message_attachment_relationship_count',
      ),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is SourceImportAnomalyCounts &&
        other.preservedUnnormalizedHandleCount ==
            preservedUnnormalizedHandleCount &&
        other.messageTimestampUnavailableCount ==
            messageTimestampUnavailableCount &&
        other.recoveredUnlinkedMessageCount == recoveredUnlinkedMessageCount &&
        other.richTextDecodeUnavailableCount ==
            richTextDecodeUnavailableCount &&
        other.attachmentMetadataDegradedCount ==
            attachmentMetadataDegradedCount &&
        other.unresolvedReactionTargetCount == unresolvedReactionTargetCount &&
        other.omittedContactRecordCount == omittedContactRecordCount &&
        other.contactEnrichmentUnavailableCount ==
            contactEnrichmentUnavailableCount &&
        other.omittedContactChannelCount == omittedContactChannelCount &&
        other.omittedChatMessageRelationshipCount ==
            omittedChatMessageRelationshipCount &&
        other.omittedChatHandleRelationshipCount ==
            omittedChatHandleRelationshipCount &&
        other.omittedMessageAttachmentRelationshipCount ==
            omittedMessageAttachmentRelationshipCount;
  }

  @override
  int get hashCode => Object.hashAll(<Object?>[
    preservedUnnormalizedHandleCount,
    messageTimestampUnavailableCount,
    recoveredUnlinkedMessageCount,
    richTextDecodeUnavailableCount,
    attachmentMetadataDegradedCount,
    unresolvedReactionTargetCount,
    omittedContactRecordCount,
    contactEnrichmentUnavailableCount,
    omittedContactChannelCount,
    omittedChatMessageRelationshipCount,
    omittedChatHandleRelationshipCount,
    omittedMessageAttachmentRelationshipCount,
  ]);
}

int _max(int first, int second) => first > second ? first : second;

int _count(Map<String, Object?> json, String key) {
  final value = json[key] ?? 0;
  if (value is! int || value < 0) {
    throw FormatException('Invalid source anomaly count: $key');
  }
  return value;
}
