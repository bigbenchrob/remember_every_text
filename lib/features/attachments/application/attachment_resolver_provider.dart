import 'dart:io';

import 'package:drift/drift.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../essentials/db/feature_level_providers.dart';
import '../../messages/domain/entities/attachment_info.dart';
import '../domain/constants.dart';
import '../domain/constants/attachment_provenance.dart';
import '../domain/entities/resolved_attachment.dart';
import 'archive_settings_provider.dart';
import 'attachment_archive_service_provider.dart';

part 'attachment_resolver_provider.g.dart';

/// Resolves an attachment file through a multi-source pipeline:
///
/// 1. Try the Messages local path (~/Library/Messages/Attachments)
/// 2. Try the MessageLens archive (overlay DB + archive directory)
/// 3. Report cloudOnly or missing
///
/// This provider replaces inline `file.existsSync()` calls in message tiles.
@riverpod
Future<ResolvedAttachment> attachmentResolver(
  AttachmentResolverRef ref,
  AttachmentInfo attachmentInfo, {
  required String messageGuid,
  required int? importAttachmentId,
}) async {
  // Step 1: Try Messages local path.
  final resolvedPath = attachmentInfo.resolvedLocalPath();
  if (resolvedPath != null) {
    final file = File(resolvedPath);
    if (file.existsSync()) {
      // On-demand archiving: if the file is locally available but not yet
      // archived, trigger archiving in the background. This handles the
      // case where iCloud re-downloads a previously evicted file.
      if (importAttachmentId != null) {
        _triggerOnDemandArchive(
          ref,
          messageGuid: messageGuid,
          importAttachmentId: importAttachmentId,
          resolvedLocalPath: resolvedPath,
          mimeType: attachmentInfo.mimeType,
        );
      }

      return ResolvedAttachment(
        attachmentInfo: attachmentInfo,
        status: AttachmentStatus.available,
        provenance: AttachmentProvenance.messagesLive,
        resolvedFile: file,
      );
    }
  }

  // Step 2: Try MessageLens archive via overlay DB.
  if (importAttachmentId != null) {
    final overlayDb = await ref.watch(overlayDatabaseProvider.future);
    final archiveDir = ref.watch(attachmentArchiveDirectoryProvider);

    final archiveRecord =
        await (overlayDb.select(overlayDb.archivedAttachments)..where(
              (t) =>
                  t.messageGuid.equals(messageGuid) &
                  t.importAttachmentId.equals(importAttachmentId),
            ))
            .getSingleOrNull();

    if (archiveRecord != null) {
      final archivePath = '$archiveDir/${archiveRecord.archiveRelativePath}';
      final archiveFile = File(archivePath);
      if (archiveFile.existsSync()) {
        final provenance = switch (archiveRecord.provenance) {
          'imported_historical' => AttachmentProvenance.importedHistorical,
          _ => AttachmentProvenance.archived,
        };
        return ResolvedAttachment(
          attachmentInfo: attachmentInfo,
          status: AttachmentStatus.available,
          provenance: provenance,
          resolvedFile: archiveFile,
        );
      }
    }
  }

  // Step 3: No file found anywhere.
  // If we have a localPath in the DB, the file was known but evicted → cloudOnly.
  // If no localPath at all, the record is truly missing.
  final status = attachmentInfo.hasLocalFile
      ? AttachmentStatus.cloudOnly
      : AttachmentStatus.missing;

  return ResolvedAttachment(attachmentInfo: attachmentInfo, status: status);
}

/// Fire-and-forget: archive a locally-available file that may not yet be
/// in the archive. Checks settings to respect the user's preference.
void _triggerOnDemandArchive(
  AttachmentResolverRef ref, {
  required String messageGuid,
  required int importAttachmentId,
  required String resolvedLocalPath,
  required String? mimeType,
}) {
  // Read settings synchronously from cache to avoid blocking resolution.
  final settingsAsync = ref.read(archiveSettingsProvider);
  final settings = settingsAsync.valueOrNull;
  if (settings == null || !settings.isEnabled) {
    return;
  }

  // Fire-and-forget archive call.
  ref
      .read(attachmentArchiveServiceProvider.notifier)
      .archiveAttachment(
        messageGuid: messageGuid,
        importAttachmentId: importAttachmentId,
        resolvedLocalPath: resolvedLocalPath,
        mimeType: mimeType,
        sha256Hex: null,
      );
}
