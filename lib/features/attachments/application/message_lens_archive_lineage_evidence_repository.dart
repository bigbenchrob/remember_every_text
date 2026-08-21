import '../domain/entities/message_lens_archive_lineage_evidence.dart';

/// Read-only evidence boundary for MessageLens attachment-recovery lineage.
abstract interface class MessageLensArchiveLineageEvidenceRepository {
  Future<MessageLensArchiveLineageEvidence> compareExactly({
    required String donorImportDatabasePath,
    required String authoritativeCurrentMessagesDatabasePath,
  });
}
