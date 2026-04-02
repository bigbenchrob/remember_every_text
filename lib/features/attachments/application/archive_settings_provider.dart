import 'dart:io';

import 'package:file_selector_platform_interface/file_selector_platform_interface.dart';
import 'package:path/path.dart' as p;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../essentials/db/feature_level_providers.dart';
import '../../../essentials/db/infrastructure/data_sources/local/overlay/overlay_database.dart';

part 'archive_settings_provider.g.dart';

const _kArchiveEnabledKey = 'attachment_archive_enabled';

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

    // Compute archive stats from filesystem and overlay table.
    final stats = await _computeStats(archiveDir, overlayDb);

    return ArchiveSettingsState(
      isEnabled: enabled,
      archivedCount: stats.count,
      archiveSizeBytes: stats.sizeBytes,
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

  static Future<_ArchiveStats> _computeStats(
    String archiveDir,
    OverlayDatabase overlayDb,
  ) async {
    var sizeBytes = 0;
    final dir = Directory(archiveDir);
    if (dir.existsSync()) {
      await for (final entity in dir.list(recursive: true)) {
        if (entity is File) {
          sizeBytes += await entity.length();
        }
      }
    }

    // Count records from overlay DB.
    final countResult = await overlayDb
        .customSelect('SELECT COUNT(*) AS cnt FROM archived_attachments')
        .getSingle();
    final count = countResult.read<int>('cnt');

    return _ArchiveStats(count: count, sizeBytes: sizeBytes);
  }
}

class _ArchiveStats {
  const _ArchiveStats({required this.count, required this.sizeBytes});
  final int count;
  final int sizeBytes;
}

class ArchiveSettingsState {
  const ArchiveSettingsState({
    required this.isEnabled,
    required this.archivedCount,
    required this.archiveSizeBytes,
  });

  final bool isEnabled;
  final int archivedCount;
  final int archiveSizeBytes;

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
