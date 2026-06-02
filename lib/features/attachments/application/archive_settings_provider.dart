import 'dart:io';

import 'package:file_selector_platform_interface/file_selector_platform_interface.dart';
import 'package:path/path.dart' as p;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../essentials/db/feature_level_providers.dart';
import '../../../essentials/db/infrastructure/data_sources/local/overlay/overlay_database.dart';
import '../infrastructure/repositories/attachment_archive_stats_repository.dart';

part 'archive_settings_provider.g.dart';

const _kArchiveEnabledKey = 'attachment_archive_enabled';
const kArchiveSweepCursorKey = 'attachment_archive_sweep_cursor';
const kArchiveSweepLastStartedAtUtcKey =
    'attachment_archive_sweep_last_started_at_utc';
const kArchiveSweepLastCompletedAtUtcKey =
    'attachment_archive_sweep_last_completed_at_utc';
const kArchiveSweepLastTotalScannedKey =
    'attachment_archive_sweep_last_total_scanned';
const kArchiveSweepLastNewlyArchivedKey =
    'attachment_archive_sweep_last_newly_archived';
const kArchiveSweepLastSkippedKey = 'attachment_archive_sweep_last_skipped';
const kArchiveSweepLastFailedKey = 'attachment_archive_sweep_last_failed';
const kArchiveManualSweepLastStartedAtUtcKey =
    'attachment_archive_manual_sweep_last_started_at_utc';
const kArchiveManualSweepLastCompletedAtUtcKey =
    'attachment_archive_manual_sweep_last_completed_at_utc';
const kArchiveManualSweepLastTotalScannedKey =
    'attachment_archive_manual_sweep_last_total_scanned';
const kArchiveManualSweepLastNewlyArchivedKey =
    'attachment_archive_manual_sweep_last_newly_archived';
const kArchiveManualSweepLastSkippedKey =
    'attachment_archive_manual_sweep_last_skipped';
const kArchiveManualSweepLastFailedKey =
    'attachment_archive_manual_sweep_last_failed';
const kArchiveManualSweepLastSkippedSamplesKey =
    'attachment_archive_manual_sweep_last_skipped_samples';

/// Manages the attachment archive user preferences.
///
/// The archive-enabled flag is persisted in the overlay DB's
/// `overlay_settings` key-value table so it survives migrations.
@Riverpod(keepAlive: true)
class ArchiveSettings extends _$ArchiveSettings {
  @override
  Future<ArchiveSettingsState> build() async {
    final overlayDb = await ref.watch(overlayDatabaseProvider.future);
    final archiveDir = ref.watch(attachmentArchiveDirectoryProvider);

    // Read enabled flag from overlay settings.
    final enabledStr = await overlayDb.readOverlaySetting(_kArchiveEnabledKey);
    final enabled = enabledStr != 'false'; // Default: enabled.

    final stats = await AttachmentArchiveStatsRepository(
      archiveDirectoryPath: archiveDir,
      overlayDatabase: overlayDb,
    ).readStats();
    final sweepDebug = await _readSweepDebugState(overlayDb);
    final manualSweepDebug = await _readManualSweepDebugState(overlayDb);

    return ArchiveSettingsState(
      isEnabled: enabled,
      archivedCount: stats.recordCount,
      archiveSizeBytes: stats.sizeBytes,
      sweepDebug: sweepDebug,
      manualSweepDebug: manualSweepDebug,
    );
  }

  Future<void> setEnabled({required bool enabled}) async {
    final overlayDb = await ref.read(overlayDatabaseProvider.future);
    await overlayDb.writeOverlaySetting(
      settingKey: _kArchiveEnabledKey,
      settingValue: enabled.toString(),
    );
    ref.invalidateSelf();
  }

  Future<void> clearArchive() async {
    final archiveDir = ref.read(attachmentArchiveDirectoryProvider);
    final overlayDb = await ref.read(overlayDatabaseProvider.future);

    // Delete all files in the archive directory.
    final dir = Directory(archiveDir);
    if (dir.existsSync()) {
      await dir.delete(recursive: true);
      await dir.create(recursive: true);
    }

    // Delete all overlay records.
    await overlayDb.delete(overlayDb.archivedAttachments).go();

    ref.invalidateSelf();
  }

  /// Export the archive directory to a user-chosen destination.
  ///
  /// Opens a native folder picker, then recursively copies the archive
  /// directory tree into `<chosen>/<timestamp>-messagelens-archive/`.
  /// Returns the number of files copied, or `null` if the user cancelled.
  Future<int?> exportArchive() async {
    final archiveDir = ref.read(attachmentArchiveDirectoryProvider);
    final sourceDir = Directory(archiveDir);
    if (!sourceDir.existsSync()) {
      return 0;
    }

    final destPath = await FileSelectorPlatform.instance
        .getDirectoryPathWithOptions(
          const FileDialogOptions(confirmButtonText: 'Export Here'),
        );

    if (destPath == null) {
      return null; // User cancelled.
    }

    final timestamp = DateTime.now()
        .toIso8601String()
        .replaceAll(':', '-')
        .split('.')
        .first;
    final exportDir = Directory(
      p.join(destPath, '$timestamp-messagelens-archive'),
    );
    await exportDir.create(recursive: true);

    var filesCopied = 0;
    await for (final entity in sourceDir.list(recursive: true)) {
      if (entity is File) {
        final relativePath = p.relative(entity.path, from: archiveDir);
        final destFile = File(p.join(exportDir.path, relativePath));
        await destFile.parent.create(recursive: true);
        await entity.copy(destFile.path);
        filesCopied++;
      }
    }

    return filesCopied;
  }

  static Future<ArchiveSweepDebugState> _readSweepDebugState(
    OverlayDatabase overlayDb,
  ) async {
    return ArchiveSweepDebugState(
      cursor: _parseInt(
        await overlayDb.readOverlaySetting(kArchiveSweepCursorKey),
      ),
      lastStartedAtUtc: await overlayDb.readOverlaySetting(
        kArchiveSweepLastStartedAtUtcKey,
      ),
      lastCompletedAtUtc: await overlayDb.readOverlaySetting(
        kArchiveSweepLastCompletedAtUtcKey,
      ),
      lastTotalScanned: _parseInt(
        await overlayDb.readOverlaySetting(kArchiveSweepLastTotalScannedKey),
      ),
      lastNewlyArchived: _parseInt(
        await overlayDb.readOverlaySetting(kArchiveSweepLastNewlyArchivedKey),
      ),
      lastSkipped: _parseInt(
        await overlayDb.readOverlaySetting(kArchiveSweepLastSkippedKey),
      ),
      lastFailed: _parseInt(
        await overlayDb.readOverlaySetting(kArchiveSweepLastFailedKey),
      ),
    );
  }

  static Future<ArchiveSweepRunDebugState> _readManualSweepDebugState(
    OverlayDatabase overlayDb,
  ) async {
    return ArchiveSweepRunDebugState(
      lastStartedAtUtc: await overlayDb.readOverlaySetting(
        kArchiveManualSweepLastStartedAtUtcKey,
      ),
      lastCompletedAtUtc: await overlayDb.readOverlaySetting(
        kArchiveManualSweepLastCompletedAtUtcKey,
      ),
      lastTotalScanned: _parseInt(
        await overlayDb.readOverlaySetting(
          kArchiveManualSweepLastTotalScannedKey,
        ),
      ),
      lastNewlyArchived: _parseInt(
        await overlayDb.readOverlaySetting(
          kArchiveManualSweepLastNewlyArchivedKey,
        ),
      ),
      lastSkipped: _parseInt(
        await overlayDb.readOverlaySetting(kArchiveManualSweepLastSkippedKey),
      ),
      lastFailed: _parseInt(
        await overlayDb.readOverlaySetting(kArchiveManualSweepLastFailedKey),
      ),
      lastSkippedSamples: _parseLines(
        await overlayDb.readOverlaySetting(
          kArchiveManualSweepLastSkippedSamplesKey,
        ),
      ),
    );
  }

  static int _parseInt(String? rawValue) {
    if (rawValue == null || rawValue.isEmpty) {
      return 0;
    }

    return int.tryParse(rawValue) ?? 0;
  }

  static List<String> _parseLines(String? rawValue) {
    if (rawValue == null || rawValue.isEmpty) {
      return const [];
    }

    return rawValue
        .split('\n')
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .toList(growable: false);
  }
}

class ArchiveSettingsState {
  const ArchiveSettingsState({
    required this.isEnabled,
    required this.archivedCount,
    required this.archiveSizeBytes,
    required this.sweepDebug,
    required this.manualSweepDebug,
  });

  final bool isEnabled;
  final int archivedCount;
  final int archiveSizeBytes;
  final ArchiveSweepDebugState sweepDebug;
  final ArchiveSweepRunDebugState manualSweepDebug;

  String get formattedSize => _formatBytes(archiveSizeBytes);

  static String _formatBytes(int bytes) {
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

class ArchiveSweepDebugState {
  const ArchiveSweepDebugState({
    required this.cursor,
    required this.lastStartedAtUtc,
    required this.lastCompletedAtUtc,
    required this.lastTotalScanned,
    required this.lastNewlyArchived,
    required this.lastSkipped,
    required this.lastFailed,
  });

  final int cursor;
  final String? lastStartedAtUtc;
  final String? lastCompletedAtUtc;
  final int lastTotalScanned;
  final int lastNewlyArchived;
  final int lastSkipped;
  final int lastFailed;

  bool get hasCompletedRun => lastCompletedAtUtc != null;

  String get lastStartedLabel => _formatTimestamp(lastStartedAtUtc);

  String get lastCompletedLabel => _formatTimestamp(lastCompletedAtUtc);

  String get lastResultLabel =>
      'Scanned $lastTotalScanned, archived $lastNewlyArchived, '
      'skipped $lastSkipped, failed $lastFailed';

  static String _formatTimestamp(String? rawValue) {
    if (rawValue == null || rawValue.isEmpty) {
      return 'Never';
    }

    final parsed = DateTime.tryParse(rawValue);
    if (parsed == null) {
      return rawValue;
    }

    final local = parsed.toLocal();
    final year = local.year.toString().padLeft(4, '0');
    final month = local.month.toString().padLeft(2, '0');
    final day = local.day.toString().padLeft(2, '0');
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    final second = local.second.toString().padLeft(2, '0');

    return '$year-$month-$day $hour:$minute:$second';
  }
}

class ArchiveSweepRunDebugState {
  const ArchiveSweepRunDebugState({
    required this.lastStartedAtUtc,
    required this.lastCompletedAtUtc,
    required this.lastTotalScanned,
    required this.lastNewlyArchived,
    required this.lastSkipped,
    required this.lastFailed,
    required this.lastSkippedSamples,
  });

  final String? lastStartedAtUtc;
  final String? lastCompletedAtUtc;
  final int lastTotalScanned;
  final int lastNewlyArchived;
  final int lastSkipped;
  final int lastFailed;
  final List<String> lastSkippedSamples;

  bool get hasCompletedRun => lastCompletedAtUtc != null;

  String get lastStartedLabel =>
      ArchiveSweepDebugState._formatTimestamp(lastStartedAtUtc);

  String get lastCompletedLabel =>
      ArchiveSweepDebugState._formatTimestamp(lastCompletedAtUtc);

  String get lastResultLabel =>
      'Scanned $lastTotalScanned, archived $lastNewlyArchived, '
      'skipped $lastSkipped, failed $lastFailed';
}
