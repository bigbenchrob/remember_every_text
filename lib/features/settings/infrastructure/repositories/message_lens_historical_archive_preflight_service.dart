import '../../../../essentials/archive_compatibility/domain/archive_compatibility_key.dart';
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
    MessageLensHistoricalArchivePreflightProgressObserver? onProgress,
    bool Function()? isCancelled,
  }) async {
    final profiler = _MessageLensPreflightProfiler(onProgress: onProgress);
    try {
      final qualification = await donorQualifier.qualify(
        folderPath: folderPath,
        onProgress: (stage, {required completed}) {
          final phase = switch (stage) {
            MessageLensAttachmentRecoveryDonorQualificationStage
                .structuralQualification =>
              MessageLensHistoricalArchivePreflightPhase
                  .structuralQualification,
            MessageLensAttachmentRecoveryDonorQualificationStage
                .compatibilityInspection =>
              MessageLensHistoricalArchivePreflightPhase
                  .compatibilityInspection,
          };
          if (completed) {
            profiler.complete(phase, completedUnits: 1, totalUnits: 1);
          } else {
            profiler.begin(phase, totalUnits: 1);
          }
          _throwIfCancelled(isCancelled);
        },
      );
      _throwIfCancelled(isCancelled);
      switch (qualification) {
        case InvalidMessageLensAttachmentRecoveryDonor():
          return const MessageLensHistoricalArchiveInvalidFolder();
        case IncompatibleMessageLensAttachmentRecoveryDonor(:final detail):
          return MessageLensHistoricalArchiveIncompatible(detail: detail);
        case SupportedMessageLensAttachmentRecoveryDonor(:final donor):
          return await _inspectQualifiedDonor(
            donor,
            profiler: profiler,
            isCancelled: isCancelled,
          );
      }
    } on _MessageLensPreflightCancellation {
      return const MessageLensHistoricalArchivePreflightCancelled();
    }
  }

  Future<MessageLensHistoricalArchivePreflightResult> _inspectQualifiedDonor(
    MessageLensAttachmentRecoveryDonor donor, {
    required _MessageLensPreflightProfiler profiler,
    required bool Function()? isCancelled,
  }) async {
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
      profiler.begin(
        MessageLensHistoricalArchivePreflightPhase.lineageAdmission,
        totalUnits: 1,
      );
      admission = await lineageAdmissionAuthority.verifyMessageLensCandidate(
        candidateImportLedgerPath: sourceLedgerPath,
      );
      profiler.complete(
        MessageLensHistoricalArchivePreflightPhase.lineageAdmission,
        completedUnits: 1,
        totalUnits: 1,
      );
      _throwIfCancelled(isCancelled);
    } on _MessageLensPreflightCancellation {
      rethrow;
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
        profiler: profiler,
        isCancelled: isCancelled,
      );
      return MessageLensHistoricalArchiveReady(
        donor: donor,
        lineageAdmission: admission,
        attachmentPreflight: attachmentPreflight,
        phaseTimings: profiler.timings,
      );
    } on _MessageLensPreflightCancellation {
      rethrow;
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
    required _MessageLensPreflightProfiler profiler,
    required bool Function()? isCancelled,
  }) async {
    profiler.begin(
      MessageLensHistoricalArchivePreflightPhase.donorAttachmentEvidence,
    );
    final donorRelationships = await donorReader.readLiveSourceRelationships();
    profiler.complete(
      MessageLensHistoricalArchivePreflightPhase.donorAttachmentEvidence,
      completedUnits: donorRelationships.length,
      totalUnits: donorRelationships.length,
    );
    _throwIfCancelled(isCancelled);
    profiler.begin(
      MessageLensHistoricalArchivePreflightPhase.currentAttachmentEvidence,
    );
    final currentRelationships = await currentEvidenceReader
        .readLiveSourceRelationships();
    profiler.complete(
      MessageLensHistoricalArchivePreflightPhase.currentAttachmentEvidence,
      completedUnits: currentRelationships.length,
      totalUnits: currentRelationships.length,
    );
    _throwIfCancelled(isCancelled);
    profiler.begin(
      MessageLensHistoricalArchivePreflightPhase.donorPayloadEvidence,
    );
    final payloadClaims = await donorReader.readArchivedPayloadClaims();
    profiler.complete(
      MessageLensHistoricalArchivePreflightPhase.donorPayloadEvidence,
      completedUnits: payloadClaims.length,
      totalUnits: payloadClaims.length,
    );
    _throwIfCancelled(isCancelled);

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

    profiler.begin(
      MessageLensHistoricalArchivePreflightPhase.relationshipMatching,
      totalUnits: payloadClaims.length,
    );
    final matchedClaims =
        <
          ({
            MessageLensArchivedPayloadClaim claim,
            MessageLensAttachmentRelationshipEvidence donorRelationship,
            List<MessageLensAttachmentRelationshipEvidence> currentCandidates,
          })
        >[];
    var unmatchedPayloadClaims = 0;
    for (var index = 0; index < payloadClaims.length; index++) {
      final claim = payloadClaims[index];
      final donorCandidates =
          donorRelationshipsByKey[claim
              .archiveCompatibilityKey
              .storageKeySegment] ??
          const <MessageLensAttachmentRelationshipEvidence>[];
      if (donorCandidates.length != 1) {
        unmatchedPayloadClaims += 1;
      } else {
        final donorRelationship = donorCandidates.single;
        final currentCandidates =
            currentRelationshipsByRows['${donorRelationship.originalMessageRowId}:'
                '${donorRelationship.originalAttachmentRowId}'] ??
            const <MessageLensAttachmentRelationshipEvidence>[];
        matchedClaims.add((
          claim: claim,
          donorRelationship: donorRelationship,
          currentCandidates: currentCandidates,
        ));
      }
      final completed = index + 1;
      if (completed % 1000 == 0 || completed == payloadClaims.length) {
        profiler.update(
          MessageLensHistoricalArchivePreflightPhase.relationshipMatching,
          completedUnits: completed,
          totalUnits: payloadClaims.length,
        );
        _throwIfCancelled(isCancelled);
        await Future<void>.delayed(Duration.zero);
      }
    }
    profiler.complete(
      MessageLensHistoricalArchivePreflightPhase.relationshipMatching,
      completedUnits: payloadClaims.length,
      totalUnits: payloadClaims.length,
    );

    profiler.begin(
      MessageLensHistoricalArchivePreflightPhase.currentPayloadPresence,
      totalUnits: matchedClaims.length,
    );
    final currentPayloadStatuses = await currentEvidenceReader
        .readPayloadStatuses(
          [
            for (final matched in matchedClaims)
              matched.claim.archiveCompatibilityKey,
          ],
          onProgress: (completed, total) {
            profiler.update(
              MessageLensHistoricalArchivePreflightPhase.currentPayloadPresence,
              completedUnits: completed,
              totalUnits: total,
            );
            _throwIfCancelled(isCancelled);
          },
        );
    profiler.complete(
      MessageLensHistoricalArchivePreflightPhase.currentPayloadPresence,
      completedUnits: matchedClaims.length,
      totalUnits: matchedClaims.length,
    );
    _throwIfCancelled(isCancelled);

    profiler.begin(
      MessageLensHistoricalArchivePreflightPhase.donorPayloadPresence,
      totalUnits: matchedClaims.length,
    );
    final Map<ArchiveCompatibilityKey, AttachmentPayloadInspection>
    donorPayloadInspections;
    try {
      donorPayloadInspections = await payloadInspector.inspectClaims(
        archiveDirectoryPath: '$donorRoot/attachment_archive',
        claims: [for (final matched in matchedClaims) matched.claim],
        onProgress: (completed, total) {
          profiler.update(
            MessageLensHistoricalArchivePreflightPhase.donorPayloadPresence,
            completedUnits: completed,
            totalUnits: total,
          );
          _throwIfCancelled(isCancelled);
        },
        isCancelled: isCancelled,
      );
    } on MessageLensAttachmentInspectionCancelled {
      throw const _MessageLensPreflightCancellation();
    }
    final inputs = <MessageLensAttachmentRecoveryInput>[];
    for (final matchedClaim in matchedClaims) {
      inputs.add(
        MessageLensAttachmentRecoveryInput(
          donorRelationship: matchedClaim.donorRelationship,
          currentRelationshipCandidates: matchedClaim.currentCandidates,
          donorPayload: matchedClaim.claim.payload,
          donorPayloadInspection:
              donorPayloadInspections[matchedClaim
                  .claim
                  .archiveCompatibilityKey] ??
              const AttachmentPayloadInspection(
                status: AttachmentPayloadInspectionStatus.invalid,
                actualSizeBytes: null,
                actualSha256: null,
              ),
          currentPayloadStatus:
              currentPayloadStatuses[matchedClaim
                  .claim
                  .archiveCompatibilityKey] ??
              CurrentAttachmentPayloadStatus.inaccessible,
        ),
      );
    }
    profiler.complete(
      MessageLensHistoricalArchivePreflightPhase.donorPayloadPresence,
      completedUnits: matchedClaims.length,
      totalUnits: matchedClaims.length,
    );

    profiler.begin(
      MessageLensHistoricalArchivePreflightPhase.classification,
      totalUnits: inputs.length,
    );
    final matched = matcher.inspect(
      lineageAdmission: lineageAdmission,
      inputs: inputs,
    );
    profiler.complete(
      MessageLensHistoricalArchivePreflightPhase.classification,
      completedUnits: inputs.length,
      totalUnits: inputs.length,
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

  static void _throwIfCancelled(bool Function()? isCancelled) {
    if (isCancelled?.call() ?? false) {
      throw const _MessageLensPreflightCancellation();
    }
  }
}

final class _MessageLensPreflightCancellation implements Exception {
  const _MessageLensPreflightCancellation();
}

final class _MessageLensPreflightProfiler {
  _MessageLensPreflightProfiler({required this.onProgress});

  final MessageLensHistoricalArchivePreflightProgressObserver? onProgress;
  final Map<MessageLensHistoricalArchivePreflightPhase, Stopwatch> _running =
      <MessageLensHistoricalArchivePreflightPhase, Stopwatch>{};
  final Map<MessageLensHistoricalArchivePreflightPhase, (int, int?)>
  _lastProgress = <MessageLensHistoricalArchivePreflightPhase, (int, int?)>{};
  final List<MessageLensHistoricalArchivePreflightTiming> _timings =
      <MessageLensHistoricalArchivePreflightTiming>[];

  List<MessageLensHistoricalArchivePreflightTiming> get timings =>
      List<MessageLensHistoricalArchivePreflightTiming>.unmodifiable(_timings);

  void begin(
    MessageLensHistoricalArchivePreflightPhase phase, {
    int? totalUnits,
  }) {
    _running[phase] = Stopwatch()..start();
    update(phase, completedUnits: 0, totalUnits: totalUnits);
  }

  void update(
    MessageLensHistoricalArchivePreflightPhase phase, {
    required int completedUnits,
    required int? totalUnits,
  }) {
    final value = (completedUnits, totalUnits);
    if (_lastProgress[phase] == value) {
      return;
    }
    _lastProgress[phase] = value;
    onProgress?.call(
      MessageLensHistoricalArchivePreflightProgress(
        phase: phase,
        completedUnits: completedUnits,
        totalUnits: totalUnits,
      ),
    );
  }

  void complete(
    MessageLensHistoricalArchivePreflightPhase phase, {
    required int completedUnits,
    required int? totalUnits,
  }) {
    final stopwatch = _running.remove(phase)?..stop();
    if (stopwatch != null) {
      _timings.add(
        MessageLensHistoricalArchivePreflightTiming(
          phase: phase,
          elapsed: stopwatch.elapsed,
        ),
      );
    }
    update(phase, completedUnits: completedUnits, totalUnits: totalUnits);
  }
}
