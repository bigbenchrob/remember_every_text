import 'package:drift/drift.dart';

import '../../../essentials/db/infrastructure/data_sources/local/import/sqflite_import_database.dart';
import '../../../essentials/db/infrastructure/data_sources/local/working/working_database.dart';
import 'historical_snapshot_reader.dart';

/// How a historical record was matched to a current attachment identity.
enum MatchMethod {
  /// Attachment GUID matched in import DB and confirmed in working DB.
  guidMatch,

  /// hist_attachment_guid was NULL, but exactly one attachment exists on
  /// both the historical and current side for this message.
  singleAttachmentFallback,
}

/// Why a historical record could not be mapped.
enum UnmappedReason {
  /// The message GUID is not present in the current working DB.
  messageNotInWorking,

  /// The attachment GUID exists in the historical snapshot but does not
  /// match any row in the current import DB.
  guidMismatch,

  /// The attachment GUID was non-null but the matched import DB row
  /// belongs to a different message than expected.
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
  });

  final String histMessageGuid;
  final String currentMessageGuid;
  final int currentImportAttachmentId;
  final String resolvedFilePath;
  final MatchMethod matchMethod;
  final String? histAttachmentGuid;
  final String? histLocalPath;
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

/// Maps historical attachment records to current MessageLens runtime identity
/// using the three-layer read topology:
///
///   Layer 1: Historical snapshot (provided as [HistoricalAttachmentRecord] list)
///   Layer 2: Current import DB (bridge: attachment.guid → attachments.id)
///   Layer 3: Current working DB (runtime identity: message_guid, import_attachment_id)
///
/// This is a pure data-access class, not a Riverpod provider.
class CrossSnapshotMapper {
  CrossSnapshotMapper({required this.importDb, required this.workingDb});

  final SqfliteImportDatabase importDb;
  final WorkingDatabase workingDb;

  /// Check precondition: import DB must have attachment data.
  Future<bool> isImportDbPopulated() async {
    final rows = await importDb.rawQuery(
      'SELECT COUNT(*) AS c FROM attachments',
    );
    final count = rows.first['c'] as int? ?? 0;
    return count > 0;
  }

  /// Map historical records to current runtime identity.
  ///
  /// Only records where [HistoricalAttachmentRecord.fileFound] is true are
  /// considered for mapping. Records without resolved files are classified
  /// as [UnmappedReason.fileNotFound].
  ///
  /// The [onProgress] callback fires periodically with the number of records
  /// processed. Returns null if cancelled via [isCancelled].
  Future<CrossSnapshotMappingResult?> mapRecords({
    required List<HistoricalAttachmentRecord> historicalRecords,
    void Function(int processed)? onProgress,
    bool Function()? isCancelled,
  }) async {
    final mapped = <MappedAttachmentRecord>[];
    final unmapped = <UnmappedAttachmentRecord>[];

    var mappedByGuid = 0;
    var mappedBySingleFallback = 0;
    var unmappedMessageMissing = 0;
    var unmappedGuidMismatch = 0;
    var unmappedAmbiguous = 0;
    var unmappedNoCurrentAttachment = 0;
    var unmappedFileMissing = 0;
    var totalWithFiles = 0;

    // Pre-build a count of historical attachments per message for fallback
    // ambiguity checking.
    final historicalAttachmentCounts = <String, int>{};
    for (final record in historicalRecords) {
      historicalAttachmentCounts[record.histMessageGuid] =
          (historicalAttachmentCounts[record.histMessageGuid] ?? 0) + 1;
    }

    for (var i = 0; i < historicalRecords.length; i++) {
      if (isCancelled != null && isCancelled()) {
        return null;
      }

      final record = historicalRecords[i];

      // Skip records where the file was not found on disk.
      if (!record.fileFound || record.resolvedFilePath == null) {
        unmapped.add(
          UnmappedAttachmentRecord(
            histMessageGuid: record.histMessageGuid,
            reason: UnmappedReason.fileNotFound,
            histAttachmentGuid: record.histAttachmentGuid,
            histLocalPath: record.histLocalPath,
          ),
        );
        unmappedFileMissing++;
        if (onProgress != null &&
            (i % 200 == 0 || i == historicalRecords.length - 1)) {
          onProgress(i + 1);
        }
        continue;
      }

      totalWithFiles++;

      // --- Message-side mapping ---
      // Check if this message_guid exists in the current working DB.
      final messageRows = await workingDb
          .customSelect(
            'SELECT DISTINCT message_guid FROM attachments '
            'WHERE message_guid = ?',
            variables: [Variable<String>(record.histMessageGuid)],
          )
          .get();

      if (messageRows.isEmpty) {
        unmapped.add(
          UnmappedAttachmentRecord(
            histMessageGuid: record.histMessageGuid,
            reason: UnmappedReason.messageNotInWorking,
            histAttachmentGuid: record.histAttachmentGuid,
            histLocalPath: record.histLocalPath,
          ),
        );
        unmappedMessageMissing++;
        if (onProgress != null &&
            (i % 200 == 0 || i == historicalRecords.length - 1)) {
          onProgress(i + 1);
        }
        continue;
      }

      // --- Attachment-side mapping ---
      final result = await _mapAttachment(
        record: record,
        historicalAttachmentCount:
            historicalAttachmentCounts[record.histMessageGuid] ?? 1,
      );

      if (result != null) {
        mapped.add(result);
        if (result.matchMethod == MatchMethod.guidMatch) {
          mappedByGuid++;
        } else {
          mappedBySingleFallback++;
        }
      } else {
        // Determine the specific unmapped reason.
        final reason = await _classifyUnmappedReason(
          record: record,
          historicalAttachmentCount:
              historicalAttachmentCounts[record.histMessageGuid] ?? 1,
        );
        unmapped.add(
          UnmappedAttachmentRecord(
            histMessageGuid: record.histMessageGuid,
            reason: reason,
            histAttachmentGuid: record.histAttachmentGuid,
            histLocalPath: record.histLocalPath,
          ),
        );
        switch (reason) {
          case UnmappedReason.guidMismatch:
          case UnmappedReason.guidMessageMismatch:
            unmappedGuidMismatch++;
          case UnmappedReason.guidNullMultiAttachment:
            unmappedAmbiguous++;
          case UnmappedReason.guidNullNoCurrentAttachment:
            unmappedNoCurrentAttachment++;
          case UnmappedReason.messageNotInWorking:
            unmappedMessageMissing++;
          case UnmappedReason.fileNotFound:
            unmappedFileMissing++;
        }
      }

      if (onProgress != null &&
          (i % 200 == 0 || i == historicalRecords.length - 1)) {
        onProgress(i + 1);
      }
    }

    return CrossSnapshotMappingResult(
      mapped: mapped,
      unmapped: unmapped,
      totalWithFiles: totalWithFiles,
      mappedByGuid: mappedByGuid,
      mappedBySingleFallback: mappedBySingleFallback,
      unmappedMessageMissing: unmappedMessageMissing,
      unmappedGuidMismatch: unmappedGuidMismatch,
      unmappedAmbiguous: unmappedAmbiguous,
      unmappedNoCurrentAttachment: unmappedNoCurrentAttachment,
      unmappedFileMissing: unmappedFileMissing,
    );
  }

  /// Attempt to map a single historical record to current identity.
  /// Returns null if mapping fails.
  Future<MappedAttachmentRecord?> _mapAttachment({
    required HistoricalAttachmentRecord record,
    required int historicalAttachmentCount,
  }) async {
    // --- Step 1: Primary GUID match ---
    if (record.histAttachmentGuid != null &&
        record.histAttachmentGuid!.isNotEmpty) {
      final importRows = await importDb.rawQuery(
        'SELECT id FROM attachments WHERE guid = ?',
        [record.histAttachmentGuid],
      );

      if (importRows.isNotEmpty) {
        final rawId = importRows.first['id'];
        if (rawId == null) {
          return null;
        }
        final candidateId = rawId as int;

        // Verify the matched attachment belongs to the correct message.
        final confirmRows = await workingDb
            .customSelect(
              'SELECT 1 FROM attachments '
              'WHERE message_guid = ? AND import_attachment_id = ?',
              variables: [
                Variable<String>(record.histMessageGuid),
                Variable<int>(candidateId),
              ],
            )
            .get();

        if (confirmRows.isNotEmpty) {
          return MappedAttachmentRecord(
            histMessageGuid: record.histMessageGuid,
            currentMessageGuid: record.histMessageGuid,
            currentImportAttachmentId: candidateId,
            resolvedFilePath: record.resolvedFilePath!,
            matchMethod: MatchMethod.guidMatch,
            histAttachmentGuid: record.histAttachmentGuid,
            histLocalPath: record.histLocalPath,
          );
        }
        // GUID matched in import DB but belongs to a different message —
        // this is a mismatch, not a fallback case.
        return null;
      }
      // GUID not found in import DB — mismatch.
      return null;
    }

    // --- Step 2: Fallback (NULL GUID only) ---
    // Condition (a): hist_attachment_guid IS NULL — already verified above.
    // Condition (b): Historical message has EXACTLY ONE attachment.
    if (historicalAttachmentCount != 1) {
      return null;
    }

    // Condition (c): Current working DB has EXACTLY ONE attachment for this
    // message_guid.
    final currentAttachmentRows = await workingDb
        .customSelect(
          'SELECT import_attachment_id FROM attachments '
          'WHERE message_guid = ?',
          variables: [Variable<String>(record.histMessageGuid)],
        )
        .get();

    if (currentAttachmentRows.length != 1) {
      return null;
    }

    final currentImportAttachmentId = currentAttachmentRows.first.read<int>(
      'import_attachment_id',
    );

    return MappedAttachmentRecord(
      histMessageGuid: record.histMessageGuid,
      currentMessageGuid: record.histMessageGuid,
      currentImportAttachmentId: currentImportAttachmentId,
      resolvedFilePath: record.resolvedFilePath!,
      matchMethod: MatchMethod.singleAttachmentFallback,
      histAttachmentGuid: null,
      histLocalPath: record.histLocalPath,
    );
  }

  /// Classify the reason a record could not be mapped (for reporting).
  Future<UnmappedReason> _classifyUnmappedReason({
    required HistoricalAttachmentRecord record,
    required int historicalAttachmentCount,
  }) async {
    // Non-null GUID that didn't match.
    if (record.histAttachmentGuid != null &&
        record.histAttachmentGuid!.isNotEmpty) {
      // Check if the GUID exists in import DB at all.
      final importRows = await importDb.rawQuery(
        'SELECT id FROM attachments WHERE guid = ?',
        [record.histAttachmentGuid],
      );
      if (importRows.isEmpty) {
        return UnmappedReason.guidMismatch;
      }
      // GUID exists but under a different message.
      return UnmappedReason.guidMessageMismatch;
    }

    // NULL GUID — check fallback conditions.
    if (historicalAttachmentCount != 1) {
      return UnmappedReason.guidNullMultiAttachment;
    }

    final currentAttachmentRows = await workingDb
        .customSelect(
          'SELECT import_attachment_id FROM attachments '
          'WHERE message_guid = ?',
          variables: [Variable<String>(record.histMessageGuid)],
        )
        .get();

    if (currentAttachmentRows.isEmpty) {
      return UnmappedReason.guidNullNoCurrentAttachment;
    }

    // Multiple current attachments → ambiguous.
    return UnmappedReason.guidNullMultiAttachment;
  }
}
