import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart';

/// A single historical message↔attachment record from the snapshot.
class HistoricalAttachmentRecord {
  const HistoricalAttachmentRecord({
    required this.histMessageGuid,
    required this.histAttachmentGuid,
    required this.histLocalPath,
    required this.resolvedFilePath,
    required this.fileFound,
    required this.histTransferName,
    required this.histMimeType,
    required this.histUti,
    required this.histFileSize,
    required this.histIsOutgoing,
  });

  final String histMessageGuid;
  final String? histAttachmentGuid;
  final String? histLocalPath;
  final String? resolvedFilePath;
  final bool fileFound;
  final String? histTransferName;
  final String? histMimeType;
  final String? histUti;
  final int? histFileSize;
  final bool histIsOutgoing;
}

/// Summary of a snapshot enumeration pass.
class SnapshotEnumerationResult {
  const SnapshotEnumerationResult({
    required this.records,
    required this.totalHistoricalPairs,
    required this.filesFound,
    required this.filesMissing,
    required this.nullPathRecords,
    required this.walDetected,
    required this.shmDetected,
  });

  final List<HistoricalAttachmentRecord> records;
  final int totalHistoricalPairs;
  final int filesFound;
  final int filesMissing;
  final int nullPathRecords;
  final bool walDetected;
  final bool shmDetected;
}

/// Validation result returned before enumeration begins.
class SnapshotValidationResult {
  const SnapshotValidationResult({
    required this.isValid,
    required this.errorMessage,
    required this.walDetected,
    required this.shmDetected,
  });

  final bool isValid;
  final String? errorMessage;
  final bool walDetected;
  final bool shmDetected;
}

/// Reads a historical Messages chat.db snapshot in read-only mode and
/// enumerates all message↔attachment relationships with deterministic
/// file path resolution.
///
/// This is a pure data-access class, not a Riverpod provider.
class HistoricalSnapshotReader {
  HistoricalSnapshotReader({
    required this.chatDbPath,
    required this.attachmentsFolderPath,
  });

  /// Path to the historical chat.db file.
  final String chatDbPath;

  /// Path to the historical Attachments folder.
  final String attachmentsFolderPath;

  /// Known prefixes that Apple's chat.db uses for attachment.filename.
  static const _knownPrefixes = [
    '~/Library/Messages/Attachments/',
    '~/Library/Messages/',
  ];

  /// Validate inputs before enumeration.
  SnapshotValidationResult validate() {
    if (!File(chatDbPath).existsSync()) {
      return const SnapshotValidationResult(
        isValid: false,
        errorMessage: 'Historical chat.db file does not exist.',
        walDetected: false,
        shmDetected: false,
      );
    }

    if (!Directory(attachmentsFolderPath).existsSync()) {
      return const SnapshotValidationResult(
        isValid: false,
        errorMessage: 'Historical Attachments folder does not exist.',
        walDetected: false,
        shmDetected: false,
      );
    }

    final walExists = File('$chatDbPath-wal').existsSync();
    final shmExists = File('$chatDbPath-shm').existsSync();

    // Verify it's a valid SQLite database by attempting to open it.
    try {
      final db = sqlite3.open(chatDbPath, mode: OpenMode.readOnly);
      // Quick sanity check — table must exist.
      db.select('SELECT COUNT(*) FROM message LIMIT 1');
      db.dispose();
    } on SqliteException catch (e) {
      return SnapshotValidationResult(
        isValid: false,
        errorMessage: 'Invalid SQLite database: $e',
        walDetected: walExists,
        shmDetected: shmExists,
      );
    }

    return SnapshotValidationResult(
      isValid: true,
      errorMessage: null,
      walDetected: walExists,
      shmDetected: shmExists,
    );
  }

  /// Enumerate all message↔attachment pairs from the historical snapshot.
  ///
  /// The [onProgress] callback fires periodically with the number of rows
  /// processed so far. Returns null if cancelled via [isCancelled].
  SnapshotEnumerationResult? enumerate({
    void Function(int processed)? onProgress,
    bool Function()? isCancelled,
  }) {
    final db = sqlite3.open(chatDbPath, mode: OpenMode.readOnly);

    try {
      final results = db.select('''
        SELECT
          m.ROWID   AS hist_message_rowid,
          m.guid    AS hist_message_guid,
          a.ROWID   AS hist_attachment_rowid,
          a.guid    AS hist_attachment_guid,
          a.filename AS hist_local_path,
          a.transfer_name AS hist_transfer_name,
          a.mime_type,
          a.uti,
          a.total_bytes AS hist_file_size,
          a.is_outgoing
        FROM message_attachment_join maj
        JOIN message m ON m.ROWID = maj.message_id
        JOIN attachment a ON a.ROWID = maj.attachment_id
        WHERE m.guid IS NOT NULL
          AND LENGTH(TRIM(m.guid)) > 0
      ''');

      final records = <HistoricalAttachmentRecord>[];
      var filesFound = 0;
      var filesMissing = 0;
      var nullPathRecords = 0;

      for (var i = 0; i < results.length; i++) {
        if (isCancelled != null && isCancelled()) {
          return null;
        }

        final row = results[i];

        final histMessageGuid = row['hist_message_guid'] as String;
        final histAttachmentGuid = row['hist_attachment_guid'] as String?;
        final histLocalPath = row['hist_local_path'] as String?;
        final histTransferName = row['hist_transfer_name'] as String?;
        final histMimeType = row['mime_type'] as String?;
        final histUti = row['uti'] as String?;
        final histFileSize = row['hist_file_size'] as int?;
        final isOutgoing = (row['is_outgoing'] as int?) == 1;

        String? resolvedPath;
        var found = false;

        if (histLocalPath != null && histLocalPath.isNotEmpty) {
          resolvedPath = _resolveFilePath(histLocalPath);
          if (resolvedPath != null) {
            found = File(resolvedPath).existsSync();
            if (!found) {
              resolvedPath = null;
            }
          }
          if (found) {
            filesFound++;
          } else {
            filesMissing++;
          }
        } else {
          nullPathRecords++;
        }

        records.add(
          HistoricalAttachmentRecord(
            histMessageGuid: histMessageGuid,
            histAttachmentGuid: histAttachmentGuid,
            histLocalPath: histLocalPath,
            resolvedFilePath: resolvedPath,
            fileFound: found,
            histTransferName: histTransferName,
            histMimeType: histMimeType,
            histUti: histUti,
            histFileSize: histFileSize,
            histIsOutgoing: isOutgoing,
          ),
        );

        if (onProgress != null && (i % 500 == 0 || i == results.length - 1)) {
          onProgress(i + 1);
        }
      }

      final walDetected = File('$chatDbPath-wal').existsSync();
      final shmDetected = File('$chatDbPath-shm').existsSync();

      return SnapshotEnumerationResult(
        records: records,
        totalHistoricalPairs: records.length,
        filesFound: filesFound,
        filesMissing: filesMissing,
        nullPathRecords: nullPathRecords,
        walDetected: walDetected,
        shmDetected: shmDetected,
      );
    } finally {
      db.dispose();
    }
  }

  /// Deterministic path rewrite: strip the known Apple prefix and prepend
  /// the user-selected historical Attachments folder.
  String? _resolveFilePath(String histLocalPath) {
    // Expand ~/
    var path = histLocalPath;
    if (path.startsWith('~/')) {
      final home = Platform.environment['HOME'];
      if (home != null) {
        path = '$home${path.substring(1)}';
      }
    }

    // Try each known prefix to extract the relative portion.
    for (final prefix in _knownPrefixes) {
      var expandedPrefix = prefix;
      if (expandedPrefix.startsWith('~/')) {
        final home = Platform.environment['HOME'];
        if (home != null) {
          expandedPrefix = '$home${expandedPrefix.substring(1)}';
        }
      }

      if (path.startsWith(expandedPrefix)) {
        final relativePart = path.substring(expandedPrefix.length);
        return p.join(attachmentsFolderPath, relativePart);
      }
    }

    // If no known prefix matched, try using just the filename portion
    // within the Attachments folder structure. This is still deterministic —
    // we construct the expected path and check existence.
    // However, we cannot know the subdirectory without the prefix, so
    // return null (file cannot be resolved deterministically).
    return null;
  }
}
