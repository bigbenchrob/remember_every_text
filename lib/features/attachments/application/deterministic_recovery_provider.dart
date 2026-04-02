import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart';
import 'package:path/path.dart' as p;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../essentials/db/feature_level_providers.dart';
import '../../../essentials/db/infrastructure/data_sources/local/overlay/overlay_database.dart';
import '../../../essentials/logging/application/app_logger.dart';
import 'cross_snapshot_mapper.dart';
import 'historical_snapshot_reader.dart';

part 'deterministic_recovery_provider.g.dart';

/// Phase of the deterministic recovery operation.
enum DeterministicRecoveryPhase {
  idle,
  validating,
  readingSnapshot,
  mapping,
  archiving,
  complete,
  error,
}

/// Full result of a deterministic recovery operation.
class DeterministicRecoveryResult {
  const DeterministicRecoveryResult({
    required this.totalHistoricalPairs,
    required this.filesFound,
    required this.filesMissing,
    required this.nullPathRecords,
    required this.mappedByGuid,
    required this.mappedBySingleFallback,
    required this.unmappedMessageMissing,
    required this.unmappedGuidMismatch,
    required this.unmappedAmbiguous,
    required this.unmappedNoCurrentAttachment,
    required this.unmappedFileMissing,
    required this.archivedNew,
    required this.skippedAlreadyArchived,
    required this.archiveFailed,
    required this.totalBytesArchived,
    required this.walDetected,
    required this.shmDetected,
  });

  final int totalHistoricalPairs;
  final int filesFound;
  final int filesMissing;
  final int nullPathRecords;
  final int mappedByGuid;
  final int mappedBySingleFallback;
  final int unmappedMessageMissing;
  final int unmappedGuidMismatch;
  final int unmappedAmbiguous;
  final int unmappedNoCurrentAttachment;
  final int unmappedFileMissing;
  final int archivedNew;
  final int skippedAlreadyArchived;
  final int archiveFailed;
  final int totalBytesArchived;
  final bool walDetected;
  final bool shmDetected;

  int get totalMapped => mappedByGuid + mappedBySingleFallback;
}

/// Current state of the deterministic recovery operation.
class DeterministicRecoveryState {
  const DeterministicRecoveryState({
    required this.phase,
    this.phaseProgress = 0,
    this.phaseTotal = 0,
    this.result,
    this.errorMessage,
  });

  final DeterministicRecoveryPhase phase;
  final int phaseProgress;
  final int phaseTotal;
  final DeterministicRecoveryResult? result;
  final String? errorMessage;

  bool get isRunning =>
      phase == DeterministicRecoveryPhase.validating ||
      phase == DeterministicRecoveryPhase.readingSnapshot ||
      phase == DeterministicRecoveryPhase.mapping ||
      phase == DeterministicRecoveryPhase.archiving;

  DeterministicRecoveryState copyWith({
    DeterministicRecoveryPhase? phase,
    int? phaseProgress,
    int? phaseTotal,
    DeterministicRecoveryResult? result,
    String? errorMessage,
  }) {
    return DeterministicRecoveryState(
      phase: phase ?? this.phase,
      phaseProgress: phaseProgress ?? this.phaseProgress,
      phaseTotal: phaseTotal ?? this.phaseTotal,
      result: result ?? this.result,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

/// Orchestrates the full deterministic historical attachment recovery pipeline:
/// Phase 1 (snapshot reader) → Phase 2 (mapper) → Phase 3 (archive writer).
@Riverpod(keepAlive: true)
class DeterministicRecovery extends _$DeterministicRecovery {
  bool _cancelRequested = false;

  @override
  DeterministicRecoveryState build() {
    return const DeterministicRecoveryState(
      phase: DeterministicRecoveryPhase.idle,
    );
  }

  /// Run the full deterministic recovery pipeline.
  Future<void> recover({
    required String chatDbPath,
    required String attachmentsFolderPath,
  }) async {
    if (state.isRunning) {
      return;
    }

    _cancelRequested = false;
    final logger = ref.read(appLoggerProvider.notifier);

    // --- Validation ---
    state = const DeterministicRecoveryState(
      phase: DeterministicRecoveryPhase.validating,
    );

    final reader = HistoricalSnapshotReader(
      chatDbPath: chatDbPath,
      attachmentsFolderPath: attachmentsFolderPath,
    );

    final validation = reader.validate();
    if (!validation.isValid) {
      state = DeterministicRecoveryState(
        phase: DeterministicRecoveryPhase.error,
        errorMessage: validation.errorMessage,
      );
      return;
    }

    // Check import DB precondition.
    final importDb = await ref.read(sqfliteImportDatabaseProvider.future);
    final workingDb = await ref.read(driftWorkingDatabaseProvider.future);

    final mapper = CrossSnapshotMapper(
      importDb: importDb,
      workingDb: workingDb,
    );

    final isPopulated = await mapper.isImportDbPopulated();
    if (!isPopulated) {
      state = const DeterministicRecoveryState(
        phase: DeterministicRecoveryPhase.error,
        errorMessage:
            'Current import data must be populated first. '
            'Run a normal import before historical recovery.',
      );
      return;
    }

    if (_cancelRequested) {
      _resetToIdle();
      return;
    }

    // --- Phase 1: Read snapshot ---
    state = const DeterministicRecoveryState(
      phase: DeterministicRecoveryPhase.readingSnapshot,
    );

    logger.info(
      'Deterministic recovery: reading historical snapshot from $chatDbPath',
      source: 'DeterministicRecovery',
    );

    final enumerationResult = reader.enumerate(
      onProgress: (processed) {
        state = state.copyWith(phaseProgress: processed);
      },
      isCancelled: () => _cancelRequested,
    );

    if (enumerationResult == null || _cancelRequested) {
      _resetToIdle();
      return;
    }

    logger.info(
      'Deterministic recovery: enumerated ${enumerationResult.totalHistoricalPairs} pairs, '
      '${enumerationResult.filesFound} files found, '
      '${enumerationResult.filesMissing} missing',
      source: 'DeterministicRecovery',
    );

    // --- Phase 2: Map to current identity ---
    state = DeterministicRecoveryState(
      phase: DeterministicRecoveryPhase.mapping,
      phaseTotal: enumerationResult.records.length,
    );

    final mappingResult = await mapper.mapRecords(
      historicalRecords: enumerationResult.records,
      onProgress: (processed) {
        state = state.copyWith(phaseProgress: processed);
      },
      isCancelled: () => _cancelRequested,
    );

    if (mappingResult == null || _cancelRequested) {
      _resetToIdle();
      return;
    }

    logger.info(
      'Deterministic recovery: mapped ${mappingResult.mapped.length} records '
      '(${mappingResult.mappedByGuid} by GUID, '
      '${mappingResult.mappedBySingleFallback} by fallback), '
      '${mappingResult.unmapped.length} unmapped',
      source: 'DeterministicRecovery',
    );

    // --- Phase 3: Archive ---
    state = DeterministicRecoveryState(
      phase: DeterministicRecoveryPhase.archiving,
      phaseTotal: mappingResult.mapped.length,
    );

    final overlayDb = await ref.read(overlayDatabaseProvider.future);
    final archiveDir = ref.read(attachmentArchiveDirectoryProvider);

    var archivedNew = 0;
    var skippedAlreadyArchived = 0;
    var archiveFailed = 0;
    var totalBytesArchived = 0;

    for (var i = 0; i < mappingResult.mapped.length; i++) {
      if (_cancelRequested) {
        break;
      }

      final record = mappingResult.mapped[i];

      try {
        final archived = await _archiveFile(
          record: record,
          overlayDb: overlayDb,
          archiveDir: archiveDir,
        );

        if (archived == null) {
          skippedAlreadyArchived++;
        } else {
          archivedNew++;
          totalBytesArchived += archived;
        }
      } on Exception catch (e) {
        archiveFailed++;
        logger.warn(
          'Deterministic recovery: failed to archive '
          '${record.resolvedFilePath}: $e',
          source: 'DeterministicRecovery',
        );
      }

      if (i % 10 == 0 || i == mappingResult.mapped.length - 1) {
        state = state.copyWith(phaseProgress: i + 1);
      }
    }

    logger.info(
      'Deterministic recovery complete: '
      '$archivedNew new, $skippedAlreadyArchived already archived, '
      '$archiveFailed failed, '
      '${_formatSize(totalBytesArchived)} archived',
      source: 'DeterministicRecovery',
    );

    // --- Complete ---
    state = DeterministicRecoveryState(
      phase: DeterministicRecoveryPhase.complete,
      result: DeterministicRecoveryResult(
        totalHistoricalPairs: enumerationResult.totalHistoricalPairs,
        filesFound: enumerationResult.filesFound,
        filesMissing: enumerationResult.filesMissing,
        nullPathRecords: enumerationResult.nullPathRecords,
        mappedByGuid: mappingResult.mappedByGuid,
        mappedBySingleFallback: mappingResult.mappedBySingleFallback,
        unmappedMessageMissing: mappingResult.unmappedMessageMissing,
        unmappedGuidMismatch: mappingResult.unmappedGuidMismatch,
        unmappedAmbiguous: mappingResult.unmappedAmbiguous,
        unmappedNoCurrentAttachment: mappingResult.unmappedNoCurrentAttachment,
        unmappedFileMissing: mappingResult.unmappedFileMissing,
        archivedNew: archivedNew,
        skippedAlreadyArchived: skippedAlreadyArchived,
        archiveFailed: archiveFailed,
        totalBytesArchived: totalBytesArchived,
        walDetected: enumerationResult.walDetected,
        shmDetected: enumerationResult.shmDetected,
      ),
    );
  }

  /// Archive a single mapped file to the content-addressable store.
  /// Returns file size in bytes if newly archived, null if already exists.
  Future<int?> _archiveFile({
    required MappedAttachmentRecord record,
    required OverlayDatabase overlayDb,
    required String archiveDir,
  }) async {
    // Idempotency check.
    final existing =
        await (overlayDb.select(overlayDb.archivedAttachments)..where(
              (t) =>
                  t.messageGuid.equals(record.currentMessageGuid) &
                  t.importAttachmentId.equals(record.currentImportAttachmentId),
            ))
            .getSingleOrNull();

    if (existing != null) {
      return null;
    }

    // Hash the source file.
    final sourceFile = File(record.resolvedFilePath);
    final bytes = await sourceFile.readAsBytes();
    final contentHash = sha256.convert(bytes).toString();

    // Content-addressable path.
    final ext = p.extension(record.resolvedFilePath).toLowerCase();
    final prefix = contentHash.substring(0, 2);
    final relativePath = '$prefix/$contentHash$ext';
    final destFile = File('$archiveDir/$relativePath');

    // Copy (only once per hash — subsequent records reuse same file).
    if (!destFile.existsSync()) {
      await destFile.parent.create(recursive: true);
      await sourceFile.copy(destFile.path);

      // Verify integrity.
      final verifyBytes = await destFile.readAsBytes();
      final verifyHash = sha256.convert(verifyBytes).toString();
      if (verifyHash != contentHash) {
        await destFile.delete();
        throw StateError(
          'Archive integrity check failed: hash mismatch after copy',
        );
      }
    }

    final fileSize = await destFile.length();

    // Insert overlay row.
    await overlayDb
        .into(overlayDb.archivedAttachments)
        .insert(
          ArchivedAttachmentsCompanion.insert(
            messageGuid: record.currentMessageGuid,
            importAttachmentId: record.currentImportAttachmentId,
            archiveRelativePath: relativePath,
            archivedAtUtc: DateTime.now().toUtc().toIso8601String(),
            fileSizeBytes: fileSize,
            contentHash: Value(contentHash),
            provenance: const Value('imported_historical_snapshot'),
            originalLocalPath: Value(record.histLocalPath ?? ''),
          ),
        );

    return fileSize;
  }

  /// Request cooperative cancellation.
  void cancel() {
    _cancelRequested = true;
  }

  /// Reset to idle.
  void reset() {
    _cancelRequested = false;
    state = const DeterministicRecoveryState(
      phase: DeterministicRecoveryPhase.idle,
    );
  }

  void _resetToIdle() {
    _cancelRequested = false;
    state = const DeterministicRecoveryState(
      phase: DeterministicRecoveryPhase.idle,
    );
  }

  static String _formatSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    }
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }
}
