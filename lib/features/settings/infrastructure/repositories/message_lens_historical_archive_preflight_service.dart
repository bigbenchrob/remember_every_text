import '../../../../essentials/db/app_database_files.dart';
import '../../../../essentials/source_scoped_import/application/messages_lineage_admission_authority.dart';
import '../../../../essentials/source_scoped_import/domain/messages_lineage_admission.dart';
import '../../../attachments/application/message_lens_attachment_evidence_reader.dart';
import '../../../attachments/application/message_lens_attachment_recovery_donor_qualifier.dart';
import '../../../attachments/application/message_lens_attachment_recovery_matcher.dart';
import '../../../attachments/domain/entities/message_lens_attachment_recovery.dart';
import '../../../attachments/domain/entities/message_lens_attachment_recovery_donor.dart';
import '../../../attachments/infrastructure/repositories/message_lens_attachment_payload_inspector.dart';
import '../../../attachments/infrastructure/repositories/sqlite_message_lens_attachment_donor_evidence_reader.dart';
import '../../application/message_lens_historical_archive_preflight.dart';

final class MessageLensHistoricalArchivePreflightService
    implements MessageLensHistoricalArchivePreflight {
  const MessageLensHistoricalArchivePreflightService({
    required this.donorQualifier,
    required this.lineageAdmissionAuthority,
    required this.currentEvidenceReader,
    this.matcher = const MessageLensAttachmentRecoveryMatcher(),
    this.payloadInspector = const MessageLensAttachmentPayloadInspector(),
  });

  final MessageLensAttachmentRecoveryDonorQualifier donorQualifier;
  final MessagesLineageAdmissionAuthority lineageAdmissionAuthority;
  final CurrentMessageLensAttachmentEvidenceReader currentEvidenceReader;
  final MessageLensAttachmentRecoveryMatcher matcher;
  final MessageLensAttachmentPayloadInspector payloadInspector;

  @override
  Future<MessageLensHistoricalArchivePreflightResult> inspect({
    required String folderPath,
  }) async {
    final qualification = await donorQualifier.qualify(folderPath: folderPath);
    switch (qualification) {
      case InvalidMessageLensAttachmentRecoveryDonor():
        return const MessageLensHistoricalArchiveInvalidFolder();
      case IncompatibleMessageLensAttachmentRecoveryDonor(:final detail):
        return MessageLensHistoricalArchiveIncompatible(detail: detail);
      case SupportedMessageLensAttachmentRecoveryDonor(:final donor):
        return _inspectQualifiedDonor(donor);
    }
  }

  Future<MessageLensHistoricalArchivePreflightResult> _inspectQualifiedDonor(
    MessageLensAttachmentRecoveryDonor donor,
  ) async {
    final normalizedFolder = donor.rootPath;
    final sourceLedgerPath = appDatabasePath(
      AppDatabaseFile.sourceScopedImport,
      databaseDirectory: normalizedFolder,
    );
    final overlayPath = appDatabasePath(
      AppDatabaseFile.overlay,
      databaseDirectory: normalizedFolder,
    );
    final donorReader = SqliteMessageLensAttachmentDonorEvidenceReader(
      donorArchiveRoot: normalizedFolder,
      donorSourceScopedImportDatabasePath: sourceLedgerPath,
      donorOverlayDatabasePath: overlayPath,
    );
    final MessagesLineageAdmission admission;
    try {
      admission = await lineageAdmissionAuthority.verifyMessageLensCandidate(
        candidateImportLedgerPath: sourceLedgerPath,
      );
    } catch (error) {
      return MessageLensHistoricalArchiveIncompatible(
        detail: 'Messages-lineage evidence could not be read: $error',
      );
    }
    if (admission is! SameMessagesLineageAdmission) {
      return MessageLensHistoricalArchiveLineageRejected(admission: admission);
    }

    try {
      final attachmentPreflight = await _inspectAttachments(
        donorRoot: normalizedFolder,
        donorReader: donorReader,
        lineageAdmission: admission,
      );
      return MessageLensHistoricalArchiveReady(
        donor: donor,
        lineageAdmission: admission,
        attachmentPreflight: attachmentPreflight,
      );
    } catch (error) {
      return MessageLensHistoricalArchiveIncompatible(
        detail: 'Attachment recovery evidence could not be read: $error',
      );
    }
  }

  Future<MessageLensAttachmentRecoveryPreflight> _inspectAttachments({
    required String donorRoot,
    required MessageLensDonorAttachmentEvidenceReader donorReader,
    required SameMessagesLineageAdmission lineageAdmission,
  }) async {
    final donorRelationships = await donorReader.readLiveSourceRelationships();
    final currentRelationships = await currentEvidenceReader
        .readLiveSourceRelationships();
    final payloadClaims = await donorReader.readArchivedPayloadClaims();

    final donorRelationshipsByKey =
        <String, List<MessageLensAttachmentRelationshipEvidence>>{};
    for (final relationship in donorRelationships) {
      donorRelationshipsByKey
          .putIfAbsent(
            relationship.archiveCompatibilityKey.storageKeySegment,
            () => <MessageLensAttachmentRelationshipEvidence>[],
          )
          .add(relationship);
    }
    final currentRelationshipsByRows =
        <String, List<MessageLensAttachmentRelationshipEvidence>>{};
    for (final relationship in currentRelationships) {
      currentRelationshipsByRows
          .putIfAbsent(
            '${relationship.originalMessageRowId}:'
            '${relationship.originalAttachmentRowId}',
            () => <MessageLensAttachmentRelationshipEvidence>[],
          )
          .add(relationship);
    }

    final inputs = <MessageLensAttachmentRecoveryInput>[];
    var unmatchedPayloadClaims = 0;
    for (final claim in payloadClaims) {
      final donorCandidates =
          donorRelationshipsByKey[claim
              .archiveCompatibilityKey
              .storageKeySegment] ??
          const <MessageLensAttachmentRelationshipEvidence>[];
      if (donorCandidates.length != 1) {
        unmatchedPayloadClaims += 1;
        continue;
      }
      final donorRelationship = donorCandidates.single;
      final inspectedPayload = await payloadInspector.inspect(
        donorArchiveRoot: donorRoot,
        payload: claim.payload,
      );
      final currentCandidates =
          currentRelationshipsByRows['${donorRelationship.originalMessageRowId}:'
              '${donorRelationship.originalAttachmentRowId}'] ??
          const <MessageLensAttachmentRelationshipEvidence>[];
      final currentPayloadStatus = await currentEvidenceReader
          .readPayloadStatus(claim.archiveCompatibilityKey);
      inputs.add(
        MessageLensAttachmentRecoveryInput(
          donorRelationship: donorRelationship,
          currentRelationshipCandidates: currentCandidates,
          donorPayload: claim.payload,
          donorPayloadInspection: inspectedPayload,
          currentPayloadStatus: currentPayloadStatus,
        ),
      );
    }

    final matched = matcher.inspect(
      lineageAdmission: lineageAdmission,
      inputs: inputs,
    );
    if (unmatchedPayloadClaims == 0) {
      return matched;
    }
    return MessageLensAttachmentRecoveryPreflight(
      candidates: matched.candidates,
      examinedCount: matched.examinedCount + unmatchedPayloadClaims,
      recoverableCount: matched.recoverableCount,
      recoverableBytes: matched.recoverableBytes,
      alreadyPresentCount: matched.alreadyPresentCount,
      donorMissingCount: matched.donorMissingCount,
      messageMismatchCount: matched.messageMismatchCount,
      attachmentMismatchCount: matched.attachmentMismatchCount,
      conflictCount: matched.conflictCount,
      ambiguousCount: matched.ambiguousCount + unmatchedPayloadClaims,
      unsafeDonorPathCount: matched.unsafeDonorPathCount,
    );
  }
}
