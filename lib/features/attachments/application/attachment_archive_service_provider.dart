import 'dart:async';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart';
import 'package:path/path.dart' as p;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../essentials/db/feature_level_providers.dart';
import '../../../essentials/db/infrastructure/data_sources/local/overlay/overlay_database.dart';
import '../../../essentials/logging/application/app_logger.dart';
import '../domain/entities/attachment_recovery_metadata.dart';
import 'archive_settings_provider.dart';
import 'attachment_recovery_hint_storage.dart';

part 'attachment_archive_service_provider.g.dart';

/// Service that copies attachment files into the MessageLens archive and
/// records them in the overlay database.
///
/// Archiving is idempotent: if an overlay record already exists for the
/// given (messageGuid, importAttachmentId) pair, the file is not re-copied.
@Riverpod(keepAlive: true)
class AttachmentArchiveService extends _$AttachmentArchiveService {
  bool _pauseRequested = false;
  bool _cancelRequested = false;

  @override
  BulkArchiveProgress build() {
    return const BulkArchiveProgress(phase: BulkArchivePhase.idle);
  }

  /// Archive a single attachment file if not already archived.
  ///
  /// Returns `true` if the file was newly archived, `false` if skipped
  /// (already archived or source missing).
  Future<bool> archiveAttachment({
    required String messageGuid,
    required int importAttachmentId,
    required String resolvedLocalPath,
    required String? mimeType,
    required String? sha256Hex,
  }) async {
    final sourceFile = File(resolvedLocalPath);
    if (!sourceFile.existsSync()) {
      return false;
    }

    final overlayDb = await ref.read(overlayDatabaseProvider.future);
    final archiveDir = ref.read(attachmentArchiveDirectoryProvider);

    // Idempotency check: skip if already archived.
    final existing =
        await (overlayDb.select(overlayDb.archivedAttachments)..where(
              (t) =>
                  t.messageGuid.equals(messageGuid) &
                  t.importAttachmentId.equals(importAttachmentId),
            ))
            .getSingleOrNull();

    if (existing != null) {
      await _clearRecoveryHint(
        overlayDb,
        messageGuid: messageGuid,
        importAttachmentId: importAttachmentId,
      );
      return false;
    }

    // Compute hash if not available.
    final contentHash = sha256Hex ?? await _computeSha256(sourceFile);

    // Determine archive path.
    final ext = p.extension(resolvedLocalPath).toLowerCase();
    final String relativePath;
    if (contentHash != null && contentHash.length >= 2) {
      final prefix = contentHash.substring(0, 2);
      relativePath = '$prefix/$contentHash$ext';
    } else {
      relativePath = '_by_id/$importAttachmentId$ext';
    }

    final destFile = File('$archiveDir/$relativePath');

    // Copy file into archive.
    try {
      await destFile.parent.create(recursive: true);
      await sourceFile.copy(destFile.path);
    } on FileSystemException catch (e) {
      ref
          .read(appLoggerProvider.notifier)
          .warn(
            'Failed to archive attachment $importAttachmentId: $e',
            source: 'AttachmentArchiveService',
          );
      return false;
    }

    // Record in overlay DB.
    final fileSize = await destFile.length();
    await overlayDb
        .into(overlayDb.archivedAttachments)
        .insert(
          ArchivedAttachmentsCompanion.insert(
            messageGuid: messageGuid,
            importAttachmentId: importAttachmentId,
            archiveRelativePath: relativePath,
            archivedAtUtc: DateTime.now().toUtc().toIso8601String(),
            fileSizeBytes: fileSize,
            contentHash: Value(contentHash),
            originalLocalPath: Value(resolvedLocalPath),
          ),
        );

    await _clearRecoveryHint(
      overlayDb,
      messageGuid: messageGuid,
      importAttachmentId: importAttachmentId,
    );

    return true;
  }

  Future<void> prioritizeRecovery({
    required String messageGuid,
    required int importAttachmentId,
    required String? resolvedLocalPath,
    required String? mimeType,
  }) async {
    final settings = await ref.read(archiveSettingsProvider.future);
    if (!settings.isEnabled) {
      return;
    }

    final overlayDb = await ref.read(overlayDatabaseProvider.future);
    final hintKey = attachmentRecoveryHintSettingKey(
      messageGuid: messageGuid,
      importAttachmentId: importAttachmentId,
    );
    final existingHint = decodeAttachmentRecoveryHint(
      await overlayDb.readOverlaySetting(hintKey),
    );
    final now = DateTime.now().toUtc();
    final currentPriority = existingHint?.recoveryPriority ?? 0;

    final prioritizedHint = AttachmentRecoveryMetadata(
      lastRecoveryAttemptAt: existingHint?.lastRecoveryAttemptAt,
      nextRecoveryAttemptAt: now,
      recoveryAttemptCount: existingHint?.recoveryAttemptCount ?? 0,
      recoveryPriority: currentPriority >= 10 ? currentPriority : 10,
      userInterestRaisedAt: now,
      lastRecoveryErrorSummary: existingHint?.lastRecoveryErrorSummary,
      isNonRecoverable: existingHint?.isNonRecoverable ?? false,
    );

    await overlayDb.writeOverlaySetting(
      settingKey: hintKey,
      settingValue: encodeAttachmentRecoveryHint(prioritizedHint),
    );

    if (resolvedLocalPath == null || resolvedLocalPath.isEmpty) {
      return;
    }

    final sourceFile = File(resolvedLocalPath);
    if (!sourceFile.existsSync()) {
      return;
    }

    unawaited(
      archiveAttachment(
        messageGuid: messageGuid,
        importAttachmentId: importAttachmentId,
        resolvedLocalPath: resolvedLocalPath,
        mimeType: mimeType,
        sha256Hex: null,
      ),
    );
  }

  /// Archive all locally available attachments from the working DB.
  ///
  /// Intended to be called after a migration cycle completes. Runs in the
  /// background without blocking the UI. Emits [BulkArchiveProgress] state
  /// updates and supports pause/cancel.
  Future<AttachmentArchiveResult> archiveAllAvailable() async {
    _pauseRequested = false;
    _cancelRequested = false;

    // Respect the user's archive-enabled preference.
    final settings = await ref.read(archiveSettingsProvider.future);
    if (!settings.isEnabled) {
      return const AttachmentArchiveResult(
        totalScanned: 0,
        newlyArchived: 0,
        skipped: 0,
        failed: 0,
      );
    }

    final workingDb = await ref.read(driftWorkingDatabaseProvider.future);
    final archiveDir = ref.read(attachmentArchiveDirectoryProvider);
    final logger = ref.read(appLoggerProvider.notifier);

    // Ensure archive directory exists.
    await Directory(archiveDir).create(recursive: true);

    // Query all attachments with a local path from working DB.
    final rows = await workingDb.customSelect('''
      SELECT
        a.id,
        a.message_guid,
        a.import_attachment_id,
        a.local_path,
        a.mime_type,
        a.sha256_hex
      FROM attachments a
      WHERE a.local_path IS NOT NULL
        AND LENGTH(TRIM(a.local_path)) > 0
      ''').get();

    var archived = 0;
    var skipped = 0;
    const failed = 0;

    state = BulkArchiveProgress(
      phase: BulkArchivePhase.running,
      totalItems: rows.length,
    );

    for (final row in rows) {
      // Handle cancellation.
      if (_cancelRequested) {
        state = const BulkArchiveProgress(phase: BulkArchivePhase.idle);
        break;
      }

      // Handle pause — spin-wait until resumed or cancelled.
      while (_pauseRequested && !_cancelRequested) {
        state = state.copyWith(phase: BulkArchivePhase.paused);
        await Future<void>.delayed(const Duration(milliseconds: 200));
      }
      if (_cancelRequested) {
        state = const BulkArchiveProgress(phase: BulkArchivePhase.idle);
        break;
      }
      if (state.phase == BulkArchivePhase.paused) {
        state = state.copyWith(phase: BulkArchivePhase.running);
      }

      final messageGuid = row.read<String>('message_guid');
      final importAttachmentId = row.readNullable<int>('import_attachment_id');
      final localPath = row.readNullable<String>('local_path');

      if (importAttachmentId == null || localPath == null) {
        skipped++;
        continue;
      }

      // Expand ~/
      final resolvedPath = _expandHomePath(localPath);

      final success = await archiveAttachment(
        messageGuid: messageGuid,
        importAttachmentId: importAttachmentId,
        resolvedLocalPath: resolvedPath,
        mimeType: row.readNullable<String>('mime_type'),
        sha256Hex: row.readNullable<String>('sha256_hex'),
      );

      if (success) {
        archived++;
      } else {
        skipped++;
      }

      // Update progress every 10 items or on the last item.
      final processed = archived + skipped;
      if (processed % 10 == 0 || processed == rows.length) {
        state = BulkArchiveProgress(
          phase: BulkArchivePhase.running,
          totalItems: rows.length,
          processedItems: processed,
          newlyArchived: archived,
        );
      }
    }

    logger.info(
      'Attachment archive: $archived new, $skipped skipped, $failed failed '
      'out of ${rows.length} attachments',
      source: 'AttachmentArchiveService',
    );

    state = BulkArchiveProgress(
      phase: BulkArchivePhase.complete,
      totalItems: rows.length,
      processedItems: rows.length,
      newlyArchived: archived,
    );

    return AttachmentArchiveResult(
      totalScanned: rows.length,
      newlyArchived: archived,
      skipped: skipped,
      failed: failed,
    );
  }

  /// Pause the running bulk archive operation.
  void pause() {
    _pauseRequested = true;
  }

  /// Resume a paused bulk archive operation.
  void resume() {
    _pauseRequested = false;
  }

  /// Cancel the running bulk archive operation.
  void cancel() {
    _cancelRequested = true;
    _pauseRequested = false;
  }

  /// Dismiss the completed/idle progress display.
  void dismissProgress() {
    state = const BulkArchiveProgress(phase: BulkArchivePhase.idle);
  }

  /// Verify archive integrity by re-hashing files and comparing to stored
  /// content hashes. Returns a result describing how many passed, failed,
  /// or were missing.
  Future<ArchiveIntegrityResult> verifyIntegrity() async {
    final overlayDb = await ref.read(overlayDatabaseProvider.future);
    final archiveDir = ref.read(attachmentArchiveDirectoryProvider);
    final logger = ref.read(appLoggerProvider.notifier);

    final rows = await overlayDb
        .customSelect(
          'SELECT id, archive_relative_path, content_hash '
          'FROM archived_attachments',
        )
        .get();

    var verified = 0;
    var hashMismatch = 0;
    var fileMissing = 0;
    var noHash = 0;

    for (final row in rows) {
      final relativePath = row.read<String>('archive_relative_path');
      final storedHash = row.readNullable<String>('content_hash');
      final file = File('$archiveDir/$relativePath');

      if (!file.existsSync()) {
        fileMissing++;
        continue;
      }

      if (storedHash == null || storedHash.isEmpty) {
        noHash++;
        continue;
      }

      final actualHash = await _computeSha256(file);
      if (actualHash == storedHash) {
        verified++;
      } else {
        hashMismatch++;
        logger.warn(
          'Archive integrity: hash mismatch for $relativePath '
          '(stored: $storedHash, actual: $actualHash)',
          source: 'AttachmentArchiveService',
        );
      }
    }

    logger.info(
      'Archive integrity check: $verified OK, '
      '$hashMismatch mismatch, $fileMissing missing, $noHash no-hash '
      'out of ${rows.length} records',
      source: 'AttachmentArchiveService',
    );

    return ArchiveIntegrityResult(
      totalRecords: rows.length,
      verified: verified,
      hashMismatch: hashMismatch,
      fileMissing: fileMissing,
      noHash: noHash,
    );
  }

  static String _expandHomePath(String rawPath) {
    if (rawPath.startsWith('~/')) {
      final home = Platform.environment['HOME'] ?? '';
      if (home.isNotEmpty) {
        return rawPath.replaceFirst('~', home);
      }
    }
    return rawPath;
  }

  static Future<String?> _computeSha256(File file) async {
    try {
      final bytes = await file.readAsBytes();
      return sha256.convert(bytes).toString();
    } on Exception {
      return null;
    }
  }

  Future<void> _clearRecoveryHint(
    OverlayDatabase overlayDb, {
    required String messageGuid,
    required int importAttachmentId,
  }) async {
    final hintKey = attachmentRecoveryHintSettingKey(
      messageGuid: messageGuid,
      importAttachmentId: importAttachmentId,
    );
    await (overlayDb.delete(
      overlayDb.overlaySettings,
    )..where((tbl) => tbl.key.equals(hintKey))).go();
  }
}

/// Result of a bulk archiving operation.
class AttachmentArchiveResult {
  const AttachmentArchiveResult({
    required this.totalScanned,
    required this.newlyArchived,
    required this.skipped,
    required this.failed,
  });

  final int totalScanned;
  final int newlyArchived;
  final int skipped;
  final int failed;
}

/// Phases of a bulk archive operation.
enum BulkArchivePhase { idle, running, paused, complete }

/// Live progress of a bulk archive operation.
class BulkArchiveProgress {
  const BulkArchiveProgress({
    required this.phase,
    this.totalItems = 0,
    this.processedItems = 0,
    this.newlyArchived = 0,
  });

  final BulkArchivePhase phase;
  final int totalItems;
  final int processedItems;
  final int newlyArchived;

  double get progress => totalItems > 0 ? processedItems / totalItems : 0;

  BulkArchiveProgress copyWith({
    BulkArchivePhase? phase,
    int? totalItems,
    int? processedItems,
    int? newlyArchived,
  }) {
    return BulkArchiveProgress(
      phase: phase ?? this.phase,
      totalItems: totalItems ?? this.totalItems,
      processedItems: processedItems ?? this.processedItems,
      newlyArchived: newlyArchived ?? this.newlyArchived,
    );
  }
}

/// Result of an archive integrity verification.
class ArchiveIntegrityResult {
  const ArchiveIntegrityResult({
    required this.totalRecords,
    required this.verified,
    required this.hashMismatch,
    required this.fileMissing,
    required this.noHash,
  });

  final int totalRecords;
  final int verified;
  final int hashMismatch;
  final int fileMissing;
  final int noHash;

  bool get allGood => hashMismatch == 0 && fileMissing == 0;
}
