import 'dart:io';

import 'package:drift/drift.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../essentials/db/feature_level_providers.dart';
import '../../messages/domain/entities/attachment_info.dart';
import '../domain/constants/attachment_provenance.dart';
import '../domain/constants/resolved_attachment_availability.dart';
import '../domain/entities/attachment_recovery_metadata.dart';
import '../domain/entities/resolved_attachment.dart';
import 'archive_settings_provider.dart';
import 'attachment_archive_service_provider.dart';
import 'attachment_recovery_hint_storage.dart';

part 'attachment_resolver_provider.g.dart';

/// Resolves an attachment file through the app's source-policy boundary.
///
/// Archive disabled:
/// - render directly from the live Messages path when present
/// - otherwise report unresolved availability
///
/// Archive enabled:
/// - render only from the MessageLens archive
/// - if a live file exists but the archive is missing, trigger archive ingestion
///   and report a pending archive state
@riverpod
Future<ResolvedAttachment> attachmentResolver(
  AttachmentResolverRef ref,
  AttachmentInfo attachmentInfo, {
  required String messageGuid,
  required int? importAttachmentId,
}) async {
  final settings = await ref.watch(archiveSettingsProvider.future);

  if (!settings.isEnabled) {
    return _resolveForLiveOnlyMode(attachmentInfo: attachmentInfo);
  }

  return _resolveForArchiveEnabledMode(
    ref,
    attachmentInfo: attachmentInfo,
    messageGuid: messageGuid,
    importAttachmentId: importAttachmentId,
  );
}

Future<ResolvedAttachment> _resolveForArchiveEnabledMode(
  AttachmentResolverRef ref, {
  required AttachmentInfo attachmentInfo,
  required String messageGuid,
  required int? importAttachmentId,
}) async {
  final resolvedPath = attachmentInfo.resolvedLocalPath();
  final liveFile = resolvedPath == null ? null : File(resolvedPath);
  final liveFileExists = liveFile != null && liveFile.existsSync();
  AttachmentRecoveryMetadata? persistedRecoveryHint;

  if (importAttachmentId != null) {
    final overlayDb = await ref.watch(overlayDatabaseProvider.future);
    final archiveDir = ref.watch(attachmentArchiveDirectoryProvider);
    persistedRecoveryHint = decodeAttachmentRecoveryHint(
      await overlayDb.readOverlaySetting(
        attachmentRecoveryHintSettingKey(
          messageGuid: messageGuid,
          importAttachmentId: importAttachmentId,
        ),
      ),
    );

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
      final archiveFileExists = archiveFile.existsSync();
      if (archiveFileExists) {
        final provenance = switch (archiveRecord.provenance) {
          'imported_historical' => AttachmentProvenance.importedHistorical,
          _ => AttachmentProvenance.archived,
        };

        return ResolvedAttachment(
          attachmentInfo: attachmentInfo,
          availability: ResolvedAttachmentAvailability.available,
          provenance: provenance,
          resolvedFile: archiveFile,
        );
      }
    }
  }

  if (liveFileExists && resolvedPath != null && importAttachmentId != null) {
    _triggerOnDemandArchive(
      ref,
      messageGuid: messageGuid,
      importAttachmentId: importAttachmentId,
      resolvedLocalPath: resolvedPath,
      mimeType: attachmentInfo.mimeType,
    );

    return ResolvedAttachment(
      attachmentInfo: attachmentInfo,
      availability: ResolvedAttachmentAvailability.pendingArchive,
      recoveryMetadata: mergeAttachmentRecoveryMetadata(
        base: AttachmentRecoveryMetadata(
          nextRecoveryAttemptAt: DateTime.now().toUtc(),
          recoveryPriority: 1,
        ),
        persistedHint: persistedRecoveryHint,
      ),
    );
  }

  if (liveFileExists) {
    return ResolvedAttachment(
      attachmentInfo: attachmentInfo,
      availability: ResolvedAttachmentAvailability.unavailableAwaitingRecovery,
      recoveryMetadata: mergeAttachmentRecoveryMetadata(
        base: AttachmentRecoveryMetadata(
          nextRecoveryAttemptAt: DateTime.now().toUtc(),
          lastRecoveryErrorSummary:
              'Live attachment is present but cannot be archived yet.',
        ),
        persistedHint: persistedRecoveryHint,
      ),
    );
  }

  final isRecoverable =
      attachmentInfo.hasLocalFile || importAttachmentId != null;

  return ResolvedAttachment(
    attachmentInfo: attachmentInfo,
    availability: isRecoverable
        ? ResolvedAttachmentAvailability.unavailableAwaitingRecovery
        : ResolvedAttachmentAvailability.nonRecoverable,
    recoveryMetadata: mergeAttachmentRecoveryMetadata(
      base: AttachmentRecoveryMetadata(
        nextRecoveryAttemptAt: isRecoverable ? DateTime.now().toUtc() : null,
        lastRecoveryErrorSummary: isRecoverable
            ? null
            : 'Attachment has no viable live or archive recovery key.',
        isNonRecoverable: !isRecoverable,
      ),
      persistedHint: persistedRecoveryHint,
    ),
  );
}

ResolvedAttachment _resolveForLiveOnlyMode({
  required AttachmentInfo attachmentInfo,
}) {
  final resolvedPath = attachmentInfo.resolvedLocalPath();
  if (resolvedPath != null) {
    final file = File(resolvedPath);
    final exists = file.existsSync();
    if (exists) {
      return ResolvedAttachment(
        attachmentInfo: attachmentInfo,
        availability: ResolvedAttachmentAvailability.available,
        provenance: AttachmentProvenance.messagesLive,
        resolvedFile: file,
      );
    }
  }

  if (attachmentInfo.hasLocalFile) {
    return ResolvedAttachment(
      attachmentInfo: attachmentInfo,
      availability: ResolvedAttachmentAvailability.unavailableAwaitingRecovery,
      recoveryMetadata: AttachmentRecoveryMetadata(
        nextRecoveryAttemptAt: DateTime.now().toUtc(),
      ),
    );
  }

  return ResolvedAttachment(
    attachmentInfo: attachmentInfo,
    availability: ResolvedAttachmentAvailability.nonRecoverable,
    recoveryMetadata: const AttachmentRecoveryMetadata(
      isNonRecoverable: true,
      lastRecoveryErrorSummary:
          'Attachment has no local path for live-only resolution.',
    ),
  );
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
