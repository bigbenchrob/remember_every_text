import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/features/attachments/application/message_lens_archive_lineage_evidence_repository.dart';
import 'package:remember_this_text/features/attachments/application/message_lens_attachment_recovery_lineage_verifier.dart';
import 'package:remember_this_text/features/attachments/domain/entities/message_lens_archive_lineage_evidence.dart';

void main() {
  group('MessageLensAttachmentRecoveryLineageVerifier', () {
    test('admits coherent exact evidence with enough distributed matches', () {
      final status = MessageLensAttachmentRecoveryLineageVerifier.classify(
        _evidence(matchingCount: 80, matchingRowIdBandCount: 4),
      );

      expect(status, MessageLensArchiveLineageAdmissionStatus.sameLineage);
    });

    test('one ROWID to different GUID contradiction rejects the donor', () {
      final status = MessageLensAttachmentRecoveryLineageVerifier.classify(
        _evidence(
          matchingCount: 79,
          contradictionCount: 1,
          matchingRowIdBandCount: 4,
        ),
      );

      expect(
        status,
        MessageLensArchiveLineageAdmissionStatus.contradictoryLineage,
      );
    });

    test('too few matches remains insufficient rather than probably okay', () {
      final status = MessageLensAttachmentRecoveryLineageVerifier.classify(
        _evidence(matchingCount: 63, matchingRowIdBandCount: 4),
      );

      expect(
        status,
        MessageLensArchiveLineageAdmissionStatus.insufficientEvidence,
      );
    });

    test(
      'matches concentrated in too little of the donor remain insufficient',
      () {
        final status = MessageLensAttachmentRecoveryLineageVerifier.classify(
          _evidence(matchingCount: 80, matchingRowIdBandCount: 2),
        );

        expect(
          status,
          MessageLensArchiveLineageAdmissionStatus.insufficientEvidence,
        );
      },
    );

    test('inconsistent donor source scoping remains insufficient', () {
      final status = MessageLensAttachmentRecoveryLineageVerifier.classify(
        _evidence(
          matchingCount: 80,
          inconsistentScopedIdentityCount: 1,
          matchingRowIdBandCount: 4,
        ),
      );

      expect(
        status,
        MessageLensArchiveLineageAdmissionStatus.insufficientEvidence,
      );
    });

    test('verification fixes current source path at composition', () async {
      final repository = _RecordingEvidenceRepository(
        evidence: _evidence(matchingCount: 80, matchingRowIdBandCount: 4),
      );
      final verifier = MessageLensAttachmentRecoveryLineageVerifier(
        evidenceRepository: repository,
        authoritativeCurrentMessagesDatabasePath:
            '/Users/test/Library/Messages/chat.db',
      );

      final result = await verifier.verifyDonor(
        donorImportDatabasePath: '/Archives/Donor/macos_import_ss.db',
      );

      expect(
        result.status,
        MessageLensArchiveLineageAdmissionStatus.sameLineage,
      );
      expect(
        repository.lastCurrentPath,
        '/Users/test/Library/Messages/chat.db',
      );
      expect(repository.lastDonorPath, '/Archives/Donor/macos_import_ss.db');
    });
  });
}

MessageLensArchiveLineageEvidence _evidence({
  int matchingCount = 0,
  int contradictionCount = 0,
  int inconsistentScopedIdentityCount = 0,
  int matchingRowIdBandCount = 0,
}) {
  return MessageLensArchiveLineageEvidence(
    donorRegisteredSourceCount: 2,
    donorLiveSourceCount: 1,
    donorMessageCount: 80,
    usableDonorIdentityCount: 80,
    blankDonorGuidCount: 0,
    inconsistentScopedIdentityCount: inconsistentScopedIdentityCount,
    duplicateDonorRowIdCount: 0,
    currentRowsInDonorRangeCount: matchingCount + contradictionCount,
    comparableCount: matchingCount + contradictionCount,
    matchingCount: matchingCount,
    contradictionCount: contradictionCount,
    missingCurrentRowCount: 80 - matchingCount - contradictionCount,
    unusableCurrentGuidCount: 0,
    matchingRowIdBandCount: matchingRowIdBandCount,
  );
}

final class _RecordingEvidenceRepository
    implements MessageLensArchiveLineageEvidenceRepository {
  _RecordingEvidenceRepository({required this.evidence});

  final MessageLensArchiveLineageEvidence evidence;
  String? lastDonorPath;
  String? lastCurrentPath;

  @override
  Future<MessageLensArchiveLineageEvidence> compareExactly({
    required String donorImportDatabasePath,
    required String authoritativeCurrentMessagesDatabasePath,
  }) async {
    lastDonorPath = donorImportDatabasePath;
    lastCurrentPath = authoritativeCurrentMessagesDatabasePath;
    return evidence;
  }
}
