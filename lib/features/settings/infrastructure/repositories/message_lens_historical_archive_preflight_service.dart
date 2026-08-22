import 'dart:io';

import 'package:path/path.dart' as path;

import '../../../../essentials/archive_environment/domain/archive_environment.dart';
import '../../../../essentials/archive_environment/domain/archive_marker.dart';
import '../../../../essentials/archive_environment/infrastructure/file_system_archive_marker_store.dart';
import '../../../../essentials/db/app_database_files.dart';
import '../../../../essentials/source_scoped_import/application/messages_lineage_admission_authority.dart';
import '../../../../essentials/source_scoped_import/domain/historical_archive_source_identity.dart';
import '../../../../essentials/source_scoped_import/domain/messages_lineage_admission.dart';
import '../../../attachments/application/message_lens_attachment_evidence_reader.dart';
import '../../../attachments/application/message_lens_attachment_recovery_matcher.dart';
import '../../../attachments/domain/entities/message_lens_attachment_recovery.dart';
import '../../../attachments/infrastructure/repositories/message_lens_attachment_payload_inspector.dart';
import '../../../attachments/infrastructure/repositories/sqlite_message_lens_attachment_donor_evidence_reader.dart';
import '../../application/message_lens_historical_archive_preflight.dart';

final class MessageLensHistoricalArchivePreflightService
    implements MessageLensHistoricalArchivePreflight {
  const MessageLensHistoricalArchivePreflightService({
    required this.currentArchiveRoot,
    required this.currentArchiveInstanceId,
    required this.currentArchiveEnvironment,
    required this.lineageAdmissionAuthority,
    required this.currentEvidenceReader,
    this.matcher = const MessageLensAttachmentRecoveryMatcher(),
    this.payloadInspector = const MessageLensAttachmentPayloadInspector(),
  });

  final String currentArchiveRoot;
  final String currentArchiveInstanceId;
  final ArchiveEnvironment currentArchiveEnvironment;
  final MessagesLineageAdmissionAuthority lineageAdmissionAuthority;
  final CurrentMessageLensAttachmentEvidenceReader currentEvidenceReader;
  final MessageLensAttachmentRecoveryMatcher matcher;
  final MessageLensAttachmentPayloadInspector payloadInspector;

  @override
  Future<MessageLensHistoricalArchivePreflightResult> inspect({
    required String folderPath,
  }) async {
    final normalizedFolder = path.normalize(path.absolute(folderPath));
    if (FileSystemEntity.typeSync(normalizedFolder, followLinks: false) !=
        FileSystemEntityType.directory) {
      return const MessageLensHistoricalArchiveInvalidFolder();
    }

    final ArchiveMarker? marker;
    try {
      marker = await FileSystemArchiveMarkerStore(
        rootPath: normalizedFolder,
      ).read();
    } catch (error) {
      return MessageLensHistoricalArchiveIncompatible(
        detail: 'The MessageLens archive marker could not be read: $error',
      );
    }
    if (marker == null) {
      return const MessageLensHistoricalArchiveInvalidFolder();
    }
    if (marker.formatVersion != ArchiveMarker.currentFormatVersion) {
      return MessageLensHistoricalArchiveIncompatible(
        detail:
            'Archive marker format ${marker.formatVersion} is not supported.',
      );
    }
    if (marker.archiveInstanceId.value == currentArchiveInstanceId ||
        path.equals(normalizedFolder, path.normalize(currentArchiveRoot))) {
      return const MessageLensHistoricalArchiveIncompatible(
        detail: 'The active MessageLens data folder cannot be its own donor.',
      );
    }
    if (currentArchiveEnvironment == ArchiveEnvironment.production &&
        marker.environment != ArchiveEnvironment.production) {
      return const MessageLensHistoricalArchiveIncompatible(
        detail:
            'Production MessageLens accepts only production archive donors.',
      );
    }

    final sourceLedgerPath = appDatabasePath(
      AppDatabaseFile.sourceScopedImport,
      databaseDirectory: normalizedFolder,
    );
    final overlayPath = appDatabasePath(
      AppDatabaseFile.overlay,
      databaseDirectory: normalizedFolder,
    );
    if (!_isRegularFile(sourceLedgerPath) || !_isRegularFile(overlayPath)) {
      return const MessageLensHistoricalArchiveIncompatible(
        detail:
            'The folder is a MessageLens archive but does not contain the supported attachment evidence stores.',
      );
    }

    final donorReader = SqliteMessageLensAttachmentDonorEvidenceReader(
      donorArchiveRoot: normalizedFolder,
      donorSourceScopedImportDatabasePath: sourceLedgerPath,
      donorOverlayDatabasePath: overlayPath,
    );
    try {
      await donorReader.validateCompatibility();
    } catch (error) {
      return MessageLensHistoricalArchiveIncompatible(
        detail: 'This MessageLens archive cannot be inspected safely: $error',
      );
    }

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
        folderPath: normalizedFolder,
        identity:
            HistoricalArchiveSourceIdentity.messageLensFromArchiveInstanceId(
              marker.archiveInstanceId.value,
            ),
        archiveInstanceId: marker.archiveInstanceId.value,
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

  static bool _isRegularFile(String candidatePath) {
    return FileSystemEntity.typeSync(candidatePath, followLinks: false) ==
        FileSystemEntityType.file;
  }
}
