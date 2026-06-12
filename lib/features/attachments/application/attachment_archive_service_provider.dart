import 'dart:async';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../essentials/db/feature_level_providers.dart';
import '../../../essentials/db/infrastructure/data_sources/local/conversation_graph/conversation_graph_database.dart';
import '../../../essentials/db/infrastructure/data_sources/local/overlay/overlay_database.dart';
import '../../../essentials/logging/application/app_logger.dart';
import '../../../essentials/source_scoped_import/domain/known_sources.dart';
import '../../../essentials/source_scoped_import/domain/source_scoped_row_key.dart';
import '../domain/entities/attachment_recovery_metadata.dart';
import '../feature_level_providers.dart';
import 'archive_settings_provider.dart';
import 'attachment_recovery_hint_storage.dart';

part 'attachment_archive_service_provider.g.dart';

const _kDefaultGraphSweepLimit = 100;
const _kGraphSweepSelectionPageSize = 250;
const _kManualSweepBurstChunkCount = 25;
const _kManualSweepSkippedSampleLimit = 3;

/// Service that copies attachment files into the MessageLens archive and
/// records them in the overlay database.
///
/// Archiving is idempotent: if an overlay record already exists for the
/// given (messageGuid, importAttachmentId) pair, the file is not re-copied.
@Riverpod(keepAlive: true)
class AttachmentArchiveService extends _$AttachmentArchiveService {
  bool _pauseRequested = false;
  bool _cancelRequested = false;
  bool _graphSweepInFlight = false;

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

    final sourcePath = await _resolveArchivableSourcePath(
      preferredLocalPath: resolvedLocalPath,
      importAttachmentId: importAttachmentId,
    );
    if (sourcePath == null) {
      return false;
    }

    final sourceFile = File(sourcePath);

    // Compute hash if not available.
    final contentHash = sha256Hex ?? await _computeSha256(sourceFile);

    // Determine archive path.
    final ext = p.extension(sourcePath).toLowerCase();
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
            originalLocalPath: Value(sourcePath),
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

  Future<AttachmentArchiveResult> archiveGraphMessageSourceRange({
    required int sourceId,
    required int startedAfterSourceRowId,
    required int? lastImportedSourceRowId,
  }) async {
    final lastSourceRowId = lastImportedSourceRowId;
    if (lastSourceRowId == null || lastSourceRowId <= startedAfterSourceRowId) {
      return const AttachmentArchiveResult(
        totalScanned: 0,
        newlyArchived: 0,
        skipped: 0,
        failed: 0,
      );
    }

    final settings = await ref.read(archiveSettingsProvider.future);
    if (!settings.isEnabled) {
      return const AttachmentArchiveResult(
        totalScanned: 0,
        newlyArchived: 0,
        skipped: 0,
        failed: 0,
      );
    }

    final graphDb = await ref.read(
      driftConversationGraphDatabaseProvider.future,
    );
    final logger = ref.read(appLoggerProvider.notifier);

    final rows = await graphDb.selectRows(
      '''
      SELECT DISTINCT
        a.ss_id AS graph_attachment_id,
        m.guid AS message_guid,
        (a.ss_id & ?) AS import_attachment_id,
        a.filename AS local_path,
        a.mime_type,
        NULL AS sha256_hex
      FROM messages m
      JOIN message_to_attachment mta ON mta.message_ss_id = m.ss_id
      JOIN attachments a ON a.ss_id = mta.attachment_ss_id
      WHERE (m.ss_id >> ?) = ?
        AND (m.ss_id & ?) > ?
        AND (m.ss_id & ?) <= ?
        AND (a.ss_id >> ?) = ?
        AND a.filename IS NOT NULL
        AND LENGTH(TRIM(a.filename)) > 0
      ORDER BY m.ss_id, a.ss_id
      ''',
      <Object?>[
        SourceScopedRowKey.maxSourceRowId,
        SourceScopedRowKey.sourceRowIdBits,
        sourceId,
        SourceScopedRowKey.maxSourceRowId,
        startedAfterSourceRowId,
        SourceScopedRowKey.maxSourceRowId,
        lastSourceRowId,
        SourceScopedRowKey.sourceRowIdBits,
        sourceId,
      ],
    );

    final archiveOutcome = await _archiveRows(
      rows: rows,
      updateProgressState: false,
    );
    final result = archiveOutcome.result;

    logger.info(
      'Attachment archive graph source range '
      '$startedAfterSourceRowId-$lastSourceRowId: '
      '${result.newlyArchived} new, ${result.skipped} skipped, '
      '${result.failed} failed out of ${result.totalScanned} attachment(s)',
      source: 'AttachmentArchiveService',
    );

    ref.invalidate(archiveSettingsProvider);

    return result;
  }

  /// Sweep a small rolling chunk of graph attachments looking for image
  /// files that are not yet archived but may now exist in Messages/Attachments.
  ///
  /// This is intentionally low-cost: it advances by graph attachment ID,
  /// touches only a bounded chunk per invocation, and persists its cursor in
  /// overlay settings so historical iCloud downloads are eventually archived.
  Future<AttachmentArchiveResult> archiveNextGraphSweepChunk({
    int limit = _kDefaultGraphSweepLimit,
    bool updateSweepDebugState = true,
  }) async {
    if (limit <= 0) {
      return const AttachmentArchiveResult(
        totalScanned: 0,
        newlyArchived: 0,
        skipped: 0,
        failed: 0,
      );
    }

    final settings = await ref.read(archiveSettingsProvider.future);
    if (!settings.isEnabled) {
      return const AttachmentArchiveResult(
        totalScanned: 0,
        newlyArchived: 0,
        skipped: 0,
        failed: 0,
      );
    }

    if (_graphSweepInFlight) {
      return const AttachmentArchiveResult(
        totalScanned: 0,
        newlyArchived: 0,
        skipped: 0,
        failed: 0,
      );
    }

    _graphSweepInFlight = true;

    try {
      final overlayDb = await ref.read(overlayDatabaseProvider.future);
      final graphDb = await ref.read(
        driftConversationGraphDatabaseProvider.future,
      );
      final logger = ref.read(appLoggerProvider.notifier);
      final startedAtUtc = DateTime.now().toUtc().toIso8601String();

      final cursor = await _readGraphSweepCursor(overlayDb);
      final selection = await _selectGraphSweepRows(
        overlayDb: overlayDb,
        graphDb: graphDb,
        afterAttachmentId: cursor,
        limit: limit,
      );

      final archiveOutcome = await _archiveRows(
        rows: selection.rows,
        updateProgressState: false,
      );
      final result = archiveOutcome.result;
      if (updateSweepDebugState) {
        final completedAtUtc = DateTime.now().toUtc().toIso8601String();
        await _writeGraphSweepStatus(
          overlayDb,
          startedAtUtc: startedAtUtc,
          completedAtUtc: completedAtUtc,
          nextCursor: selection.nextCursor,
          result: result,
        );
      } else {
        await _writeGraphSweepCursor(
          overlayDb,
          nextCursor: selection.nextCursor,
        );
      }

      logger.debug(
        'Graph attachment sweep: ${result.newlyArchived} new, '
        '${result.skipped} skipped, ${result.failed} failed out of '
        '${result.totalScanned} attachment(s); next cursor ${selection.nextCursor}',
        source: 'AttachmentArchiveService',
      );

      ref.invalidate(archiveSettingsProvider);

      return result;
    } finally {
      _graphSweepInFlight = false;
    }
  }

  /// Run a stronger manual sweep for developer tooling.
  ///
  /// This scans multiple regular sweep chunks in one call, stopping once it
  /// reaches the end of the current cursor cycle so it does not rescan the
  /// same tail candidates repeatedly inside a single manual run.
  Future<AttachmentArchiveResult> archiveGraphSweepBurst({
    int chunkLimit = _kDefaultGraphSweepLimit,
    int maxChunks = _kManualSweepBurstChunkCount,
  }) async {
    if (chunkLimit <= 0 || maxChunks <= 0) {
      return const AttachmentArchiveResult(
        totalScanned: 0,
        newlyArchived: 0,
        skipped: 0,
        failed: 0,
      );
    }

    final settings = await ref.read(archiveSettingsProvider.future);
    if (!settings.isEnabled) {
      return const AttachmentArchiveResult(
        totalScanned: 0,
        newlyArchived: 0,
        skipped: 0,
        failed: 0,
      );
    }

    if (_graphSweepInFlight) {
      return const AttachmentArchiveResult(
        totalScanned: 0,
        newlyArchived: 0,
        skipped: 0,
        failed: 0,
      );
    }

    _graphSweepInFlight = true;

    try {
      final overlayDb = await ref.read(overlayDatabaseProvider.future);
      final graphDb = await ref.read(
        driftConversationGraphDatabaseProvider.future,
      );
      final startedAtUtc = DateTime.now().toUtc().toIso8601String();
      var cursor = await _readGraphSweepCursor(overlayDb);
      var totalScanned = 0;
      var newlyArchived = 0;
      var skipped = 0;
      var failed = 0;
      final skippedSamples = <String>[];

      for (var index = 0; index < maxChunks; index++) {
        final previousCursor = cursor;
        final selection = await _selectGraphSweepRows(
          overlayDb: overlayDb,
          graphDb: graphDb,
          afterAttachmentId: cursor,
          limit: chunkLimit,
        );
        final archiveOutcome = await _archiveRows(
          rows: selection.rows,
          updateProgressState: false,
          skippedSampleLimit:
              _kManualSweepSkippedSampleLimit - skippedSamples.length,
        );
        final result = archiveOutcome.result;
        totalScanned += result.totalScanned;
        newlyArchived += result.newlyArchived;
        skipped += result.skipped;
        failed += result.failed;
        skippedSamples.addAll(archiveOutcome.skippedSamples);

        cursor = selection.nextCursor;
        await _writeGraphSweepCursor(overlayDb, nextCursor: cursor);

        if (result.totalScanned == 0) {
          break;
        }

        if (cursor == 0) {
          break;
        }

        if (previousCursor > 0 && cursor <= previousCursor) {
          break;
        }
      }

      final burstResult = AttachmentArchiveResult(
        totalScanned: totalScanned,
        newlyArchived: newlyArchived,
        skipped: skipped,
        failed: failed,
      );

      final completedAtUtc = DateTime.now().toUtc().toIso8601String();
      await _writeManualSweepBurstStatus(
        overlayDb,
        startedAtUtc: startedAtUtc,
        completedAtUtc: completedAtUtc,
        result: burstResult,
        skippedSamples: skippedSamples,
      );

      ref.invalidate(archiveSettingsProvider);

      return burstResult;
    } finally {
      _graphSweepInFlight = false;
    }
  }

  /// Archive all locally available attachments from the conversation graph.
  ///
  /// Intended for retained full/manual archive sweeps. Live graph updates use
  /// source-row-range archiving instead. Runs in the background without
  /// blocking the UI. Emits [BulkArchiveProgress] state updates and supports
  /// pause/cancel.
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

    final graphDb = await ref.read(
      driftConversationGraphDatabaseProvider.future,
    );
    final archiveDir = ref.read(attachmentArchiveDirectoryProvider);
    final logger = ref.read(appLoggerProvider.notifier);

    // Ensure archive directory exists.
    await Directory(archiveDir).create(recursive: true);

    // Query all graph attachments with a source path.
    final rows = await graphDb.selectRows(
      '''
      SELECT
        a.ss_id AS graph_attachment_id,
        m.guid AS message_guid,
        (a.ss_id & ?) AS import_attachment_id,
        a.filename AS local_path,
        a.mime_type,
        NULL AS sha256_hex
      FROM attachments a
      JOIN message_to_attachment mta ON mta.attachment_ss_id = a.ss_id
      JOIN messages m ON m.ss_id = mta.message_ss_id
      WHERE (a.ss_id >> ?) = ?
        AND a.filename IS NOT NULL
        AND LENGTH(TRIM(a.filename)) > 0
      ''',
      <Object?>[
        SourceScopedRowKey.maxSourceRowId,
        SourceScopedRowKey.sourceRowIdBits,
        liveChatDbSourceId,
      ],
    );

    final archiveOutcome = await _archiveRows(
      rows: rows,
      updateProgressState: true,
    );
    final result = archiveOutcome.result;

    logger.info(
      'Attachment archive: ${result.newlyArchived} new, ${result.skipped} '
      'skipped, ${result.failed} failed out of ${result.totalScanned} '
      'attachments',
      source: 'AttachmentArchiveService',
    );

    state = BulkArchiveProgress(
      phase: BulkArchivePhase.complete,
      totalItems: result.totalScanned,
      processedItems: result.totalScanned,
      newlyArchived: result.newlyArchived,
    );

    ref.invalidate(archiveSettingsProvider);

    return result;
  }

  Future<_ArchiveRowsOutcome> _archiveRows({
    required List<dynamic> rows,
    required bool updateProgressState,
    int skippedSampleLimit = 0,
  }) async {
    if (updateProgressState) {
      state = BulkArchiveProgress(
        phase: BulkArchivePhase.running,
        totalItems: rows.length,
      );
    }

    var archived = 0;
    var skipped = 0;
    var failed = 0;
    final skippedSamples = <String>[];

    for (final row in rows) {
      // Handle cancellation.
      if (_cancelRequested) {
        if (updateProgressState) {
          state = const BulkArchiveProgress(phase: BulkArchivePhase.idle);
        }
        break;
      }

      // Handle pause — spin-wait until resumed or cancelled.
      while (_pauseRequested && !_cancelRequested) {
        if (updateProgressState) {
          state = state.copyWith(phase: BulkArchivePhase.paused);
        }
        await Future<void>.delayed(const Duration(milliseconds: 200));
      }
      if (_cancelRequested) {
        if (updateProgressState) {
          state = const BulkArchiveProgress(phase: BulkArchivePhase.idle);
        }
        break;
      }
      if (updateProgressState && state.phase == BulkArchivePhase.paused) {
        state = state.copyWith(phase: BulkArchivePhase.running);
      }

      final messageGuid = _readRequiredString(row, 'message_guid');
      final importAttachmentId = _readNullableInt(row, 'import_attachment_id');
      final localPath = _readNullableString(row, 'local_path');

      if (importAttachmentId == null || localPath == null) {
        skipped++;
        _recordSkippedSample(
          skippedSamples,
          messageGuid: messageGuid,
          importAttachmentId: importAttachmentId,
          localPath: localPath,
          reason: 'missing metadata',
          sampleLimit: skippedSampleLimit,
        );
        continue;
      }

      // Expand ~/
      final resolvedPath = _expandHomePath(localPath);

      final archivablePath = await _resolveArchivableSourcePath(
        preferredLocalPath: resolvedPath,
        importAttachmentId: importAttachmentId,
      );
      if (archivablePath == null) {
        skipped++;
        _recordSkippedSample(
          skippedSamples,
          messageGuid: messageGuid,
          importAttachmentId: importAttachmentId,
          localPath: resolvedPath,
          reason: 'source missing',
          sampleLimit: skippedSampleLimit,
        );
        continue;
      }

      try {
        final success = await archiveAttachment(
          messageGuid: messageGuid,
          importAttachmentId: importAttachmentId,
          resolvedLocalPath: archivablePath,
          mimeType: _readNullableString(row, 'mime_type'),
          sha256Hex: _readNullableString(row, 'sha256_hex'),
        );

        if (success) {
          archived++;
        } else {
          skipped++;
          _recordSkippedSample(
            skippedSamples,
            messageGuid: messageGuid,
            importAttachmentId: importAttachmentId,
            localPath: resolvedPath,
            reason: 'not archived',
            sampleLimit: skippedSampleLimit,
          );
        }
      } on Exception {
        failed++;
      }

      // Update progress every 10 items or on the last item.
      final processed = archived + skipped;
      if (updateProgressState &&
          (processed % 10 == 0 || processed == rows.length)) {
        state = BulkArchiveProgress(
          phase: BulkArchivePhase.running,
          totalItems: rows.length,
          processedItems: processed,
          newlyArchived: archived,
        );
      }
    }

    return _ArchiveRowsOutcome(
      result: AttachmentArchiveResult(
        totalScanned: rows.length,
        newlyArchived: archived,
        skipped: skipped,
        failed: failed,
      ),
      skippedSamples: skippedSamples,
    );
  }

  void _recordSkippedSample(
    List<String> skippedSamples, {
    required String messageGuid,
    required int? importAttachmentId,
    required String? localPath,
    required String reason,
    required int sampleLimit,
  }) {
    if (sampleLimit <= 0 || skippedSamples.length >= sampleLimit) {
      return;
    }

    final attachmentLabel = importAttachmentId == null
        ? 'unknown-id'
        : '$importAttachmentId';
    final pathLabel = localPath == null || localPath.isEmpty
        ? 'no-path'
        : localPath;
    final sample = '$attachmentLabel | $reason | $pathLabel';
    if (skippedSamples.contains(sample)) {
      return;
    }

    skippedSamples.add(sample);
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

  Future<String?> _resolveArchivableSourcePath({
    required String preferredLocalPath,
    required int importAttachmentId,
  }) async {
    final expandedPreferredPath = _expandHomePath(preferredLocalPath);
    if (File(expandedPreferredPath).existsSync()) {
      return expandedPreferredPath;
    }

    final refreshedPath = await _lookupCurrentMessagesAttachmentPath(
      importAttachmentId,
    );
    if (refreshedPath == null) {
      return null;
    }

    final expandedRefreshedPath = _expandHomePath(refreshedPath);
    if (!File(expandedRefreshedPath).existsSync()) {
      return null;
    }

    if (expandedRefreshedPath != expandedPreferredPath) {
      ref
          .read(appLoggerProvider.notifier)
          .debug(
            'Attachment $importAttachmentId resolved via refreshed chat.db '
            'path $expandedRefreshedPath',
            source: 'AttachmentArchiveService',
          );
    }

    return expandedRefreshedPath;
  }

  Future<String?> _lookupCurrentMessagesAttachmentPath(
    int importAttachmentId,
  ) async {
    try {
      final lookup = await ref.read(
        currentMessagesAttachmentPathLookupProvider.future,
      );
      return lookup.attachmentPathForSourceRowId(importAttachmentId);
    } on Object catch (error) {
      ref
          .read(appLoggerProvider.notifier)
          .warn(
            'Failed to refresh attachment path for $importAttachmentId: $error',
            source: 'AttachmentArchiveService',
          );
      return null;
    }
  }

  Future<int> _readGraphSweepCursor(OverlayDatabase overlayDb) async {
    final rawValue = await overlayDb.readOverlaySetting(kArchiveSweepCursorKey);
    if (rawValue == null || rawValue.isEmpty) {
      return 0;
    }

    return int.tryParse(rawValue) ?? 0;
  }

  Future<_GraphSweepSelection> _selectGraphSweepRows({
    required OverlayDatabase overlayDb,
    required ConversationGraphDatabase graphDb,
    required int afterAttachmentId,
    required int limit,
  }) async {
    final selectedRows = <dynamic>[];
    final selectedAttachmentIds = <int>{};
    var cursor = afterAttachmentId;
    var wrappedToStart = false;

    while (selectedRows.length < limit) {
      final rawRows = await _fetchGraphSweepRows(
        graphDb,
        afterAttachmentId: cursor,
        limit: _kGraphSweepSelectionPageSize,
      );

      if (rawRows.isEmpty) {
        if (!wrappedToStart && afterAttachmentId > 0) {
          wrappedToStart = true;
          cursor = 0;
          continue;
        }

        return _GraphSweepSelection(rows: selectedRows, nextCursor: 0);
      }

      final archivedKeys = await _loadArchivedKeysForRows(
        overlayDb,
        rows: rawRows,
      );
      var lastProcessedAttachmentId = cursor;

      for (final row in rawRows) {
        final graphAttachmentId = _readNullableInt(row, 'graph_attachment_id');
        lastProcessedAttachmentId =
            graphAttachmentId ?? lastProcessedAttachmentId;
        final archiveKey = _buildArchiveIdentityKeyForRow(row);
        if (archiveKey == null || archivedKeys.contains(archiveKey)) {
          continue;
        }

        if (graphAttachmentId != null &&
            selectedAttachmentIds.contains(graphAttachmentId)) {
          continue;
        }

        selectedRows.add(row);
        if (graphAttachmentId != null) {
          selectedAttachmentIds.add(graphAttachmentId);
        }
        if (selectedRows.length == limit) {
          break;
        }
      }

      cursor = lastProcessedAttachmentId;
      if (rawRows.length < _kGraphSweepSelectionPageSize) {
        if (selectedRows.length < limit &&
            !wrappedToStart &&
            afterAttachmentId > 0) {
          wrappedToStart = true;
          cursor = 0;
          continue;
        }

        return _GraphSweepSelection(
          rows: selectedRows,
          nextCursor: selectedRows.length < limit ? 0 : cursor,
        );
      }
    }

    return _GraphSweepSelection(rows: selectedRows, nextCursor: cursor);
  }

  Future<List<dynamic>> _fetchGraphSweepRows(
    ConversationGraphDatabase graphDb, {
    required int afterAttachmentId,
    required int limit,
  }) async {
    return graphDb.selectRows(
      '''
          SELECT
            a.ss_id AS graph_attachment_id,
            m.guid AS message_guid,
            (a.ss_id & ?) AS import_attachment_id,
            a.filename AS local_path,
            a.mime_type,
            NULL AS sha256_hex
          FROM attachments a
          JOIN message_to_attachment mta ON mta.attachment_ss_id = a.ss_id
          JOIN messages m ON m.ss_id = mta.message_ss_id
          WHERE a.ss_id > ?
            AND (a.ss_id >> ?) = ?
            AND a.filename IS NOT NULL
            AND LENGTH(TRIM(a.filename)) > 0
            AND a.mime_type LIKE 'image/%'
          ORDER BY a.ss_id
          LIMIT ?
          ''',
      <Object?>[
        SourceScopedRowKey.maxSourceRowId,
        afterAttachmentId,
        SourceScopedRowKey.sourceRowIdBits,
        liveChatDbSourceId,
        limit,
      ],
    );
  }

  Future<Set<String>> _loadArchivedKeysForRows(
    OverlayDatabase overlayDb, {
    required List<dynamic> rows,
  }) async {
    final keyedRows = rows
        .map((row) {
          final messageGuid = _readNullableString(row, 'message_guid');
          final importAttachmentId = _readNullableInt(
            row,
            'import_attachment_id',
          );
          if (messageGuid == null || importAttachmentId == null) {
            return null;
          }
          return (messageGuid, importAttachmentId);
        })
        .whereType<(String, int)>()
        .toList(growable: false);

    if (keyedRows.isEmpty) {
      return <String>{};
    }

    final predicates = <String>[];
    final variables = <Variable<Object>>[];
    for (final (messageGuid, importAttachmentId) in keyedRows) {
      predicates.add('(message_guid = ? AND import_attachment_id = ?)');
      variables.add(Variable<String>(messageGuid));
      variables.add(Variable<int>(importAttachmentId));
    }

    final rowsResult = await overlayDb
        .customSelect(
          'SELECT message_guid, import_attachment_id '
          'FROM archived_attachments '
          'WHERE ${predicates.join(' OR ')}',
          variables: variables,
        )
        .get();

    return rowsResult
        .map(
          (row) => _buildArchiveIdentityKey(
            messageGuid: row.read<String>('message_guid'),
            importAttachmentId: row.read<int>('import_attachment_id'),
          ),
        )
        .toSet();
  }

  String? _buildArchiveIdentityKeyForRow(dynamic row) {
    final messageGuid = _readNullableString(row, 'message_guid');
    final importAttachmentId = _readNullableInt(row, 'import_attachment_id');
    if (messageGuid == null || importAttachmentId == null) {
      return null;
    }

    return _buildArchiveIdentityKey(
      messageGuid: messageGuid,
      importAttachmentId: importAttachmentId,
    );
  }

  String _buildArchiveIdentityKey({
    required String messageGuid,
    required int importAttachmentId,
  }) {
    return '$messageGuid::$importAttachmentId';
  }

  Future<void> _writeGraphSweepStatus(
    OverlayDatabase overlayDb, {
    required String startedAtUtc,
    required String completedAtUtc,
    required int nextCursor,
    required AttachmentArchiveResult result,
  }) async {
    await _writeGraphSweepCursor(overlayDb, nextCursor: nextCursor);
    await overlayDb.writeOverlaySetting(
      settingKey: kArchiveSweepLastStartedAtUtcKey,
      settingValue: startedAtUtc,
    );
    await overlayDb.writeOverlaySetting(
      settingKey: kArchiveSweepLastCompletedAtUtcKey,
      settingValue: completedAtUtc,
    );
    await overlayDb.writeOverlaySetting(
      settingKey: kArchiveSweepLastTotalScannedKey,
      settingValue: '${result.totalScanned}',
    );
    await overlayDb.writeOverlaySetting(
      settingKey: kArchiveSweepLastNewlyArchivedKey,
      settingValue: '${result.newlyArchived}',
    );
    await overlayDb.writeOverlaySetting(
      settingKey: kArchiveSweepLastSkippedKey,
      settingValue: '${result.skipped}',
    );
    await overlayDb.writeOverlaySetting(
      settingKey: kArchiveSweepLastFailedKey,
      settingValue: '${result.failed}',
    );
  }

  Future<void> _writeGraphSweepCursor(
    OverlayDatabase overlayDb, {
    required int nextCursor,
  }) async {
    await overlayDb.writeOverlaySetting(
      settingKey: kArchiveSweepCursorKey,
      settingValue: '$nextCursor',
    );
  }

  Future<void> _writeManualSweepBurstStatus(
    OverlayDatabase overlayDb, {
    required String startedAtUtc,
    required String completedAtUtc,
    required AttachmentArchiveResult result,
    List<String> skippedSamples = const [],
  }) async {
    await overlayDb.writeOverlaySetting(
      settingKey: kArchiveManualSweepLastStartedAtUtcKey,
      settingValue: startedAtUtc,
    );
    await overlayDb.writeOverlaySetting(
      settingKey: kArchiveManualSweepLastCompletedAtUtcKey,
      settingValue: completedAtUtc,
    );
    await overlayDb.writeOverlaySetting(
      settingKey: kArchiveManualSweepLastTotalScannedKey,
      settingValue: '${result.totalScanned}',
    );
    await overlayDb.writeOverlaySetting(
      settingKey: kArchiveManualSweepLastNewlyArchivedKey,
      settingValue: '${result.newlyArchived}',
    );
    await overlayDb.writeOverlaySetting(
      settingKey: kArchiveManualSweepLastSkippedKey,
      settingValue: '${result.skipped}',
    );
    await overlayDb.writeOverlaySetting(
      settingKey: kArchiveManualSweepLastFailedKey,
      settingValue: '${result.failed}',
    );
    await overlayDb.writeOverlaySetting(
      settingKey: kArchiveManualSweepLastSkippedSamplesKey,
      settingValue: skippedSamples.join('\n'),
    );
  }

  String _readRequiredString(Object? row, String key) {
    final value = _readNullableString(row, key);
    if (value == null) {
      throw StateError('Missing required string column $key');
    }
    return value;
  }

  String? _readNullableString(Object? row, String key) {
    if (row is Map<String, Object?>) {
      final value = row[key];
      return value == null ? null : '$value';
    }
    if (row is QueryRow) {
      return row.readNullable<String>(key);
    }

    throw StateError('Unsupported row type for string column $key: $row');
  }

  int? _readNullableInt(Object? row, String key) {
    if (row is Map<String, Object?>) {
      final value = row[key];
      if (value == null) {
        return null;
      }
      if (value is int) {
        return value;
      }
      if (value is num) {
        return value.toInt();
      }
      return int.tryParse('$value');
    }
    if (row is QueryRow) {
      return row.readNullable<int>(key);
    }

    throw StateError('Unsupported row type for int column $key: $row');
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

class _GraphSweepSelection {
  const _GraphSweepSelection({required this.rows, required this.nextCursor});

  final List<dynamic> rows;
  final int nextCursor;
}

class _ArchiveRowsOutcome {
  const _ArchiveRowsOutcome({
    required this.result,
    required this.skippedSamples,
  });

  final AttachmentArchiveResult result;
  final List<String> skippedSamples;
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
