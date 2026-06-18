import '../../../essentials/retained_archive/domain/archive_compatibility_key.dart';

/// How a historical record was matched to a current attachment identity.
enum MatchMethod {
  /// Attachment GUID matched the current graph attachment topology.
  guidMatch,

  /// hist_attachment_guid was NULL, but exactly one attachment exists on
  /// both the historical and current side for this message.
  singleAttachmentFallback,
}

/// Why a historical record could not be mapped.
enum UnmappedReason {
  /// The message GUID is not present in the current graph.
  messageNotInGraph,

  /// The attachment GUID exists in the historical snapshot but does not
  /// match any row in the current source-scoped import ledger.
  guidMismatch,

  /// The attachment GUID was non-null but the matched import row belongs to
  /// a different message than expected.
  guidMessageMismatch,

  /// The attachment GUID is NULL and the message has multiple attachments
  /// on at least one side, making fallback ambiguous.
  guidNullMultiAttachment,

  /// The attachment GUID is NULL but the current message has zero
  /// attachments.
  guidNullNoCurrentAttachment,

  /// The resolved file was not found on disk.
  fileNotFound,
}

/// A historical record successfully mapped to current runtime identity.
class MappedAttachmentRecord {
  const MappedAttachmentRecord({
    required this.histMessageGuid,
    required this.currentMessageGuid,
    required this.currentImportAttachmentId,
    required this.resolvedFilePath,
    required this.matchMethod,
    required this.histAttachmentGuid,
    required this.histLocalPath,
    this.currentMessageSsId,
    this.currentAttachmentSsId,
  });

  final String histMessageGuid;
  final String currentMessageGuid;

  /// Compatibility row id used by existing overlay archive keys.
  ///
  /// Canonical graph attachment identity is [currentAttachmentSsId].
  final int currentImportAttachmentId;
  ArchiveCompatibilityKey get currentArchiveCompatibilityKey {
    return ArchiveCompatibilityKey(
      messageGuid: currentMessageGuid,
      importAttachmentId: currentImportAttachmentId,
    );
  }

  final String resolvedFilePath;
  final MatchMethod matchMethod;
  final String? histAttachmentGuid;
  final String? histLocalPath;
  final int? currentMessageSsId;
  final int? currentAttachmentSsId;
}

/// A historical record that could not be mapped.
class UnmappedAttachmentRecord {
  const UnmappedAttachmentRecord({
    required this.histMessageGuid,
    required this.reason,
    required this.histAttachmentGuid,
    required this.histLocalPath,
  });

  final String histMessageGuid;
  final UnmappedReason reason;
  final String? histAttachmentGuid;
  final String? histLocalPath;
}

/// Summary of a cross-snapshot mapping pass.
class CrossSnapshotMappingResult {
  const CrossSnapshotMappingResult({
    required this.mapped,
    required this.unmapped,
    required this.totalWithFiles,
    required this.mappedByGuid,
    required this.mappedBySingleFallback,
    required this.unmappedMessageMissing,
    required this.unmappedGuidMismatch,
    required this.unmappedAmbiguous,
    required this.unmappedNoCurrentAttachment,
    required this.unmappedFileMissing,
  });

  final List<MappedAttachmentRecord> mapped;
  final List<UnmappedAttachmentRecord> unmapped;
  final int totalWithFiles;
  final int mappedByGuid;
  final int mappedBySingleFallback;
  final int unmappedMessageMissing;
  final int unmappedGuidMismatch;
  final int unmappedAmbiguous;
  final int unmappedNoCurrentAttachment;
  final int unmappedFileMissing;
}
