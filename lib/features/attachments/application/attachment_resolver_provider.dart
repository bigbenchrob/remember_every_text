import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../messages/domain/entities/attachment_info.dart';
import '../domain/constants/attachment_provenance.dart';
import '../domain/constants/resolved_attachment_availability.dart';
import '../domain/entities/attachment_recovery_metadata.dart';
import '../domain/entities/resolved_attachment.dart';
import '../feature_level_providers.dart';
import 'archive_settings_provider.dart';
import 'attachment_archive_service_provider.dart';
import 'attachment_file_access.dart';
import 'attachment_recovery_metadata_merge.dart';

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
  AttachmentInfo attachmentInfo,
) async {
  final settings = await ref.watch(archiveSettingsProvider.future);
  final fileAccess = ref.watch(attachmentFileAccessProvider);

  if (!settings.isEnabled) {
    return _resolveForLiveOnlyMode(
      attachmentInfo: attachmentInfo,
      fileAccess: fileAccess,
    );
  }

  return _resolveForArchiveEnabledMode(
    ref,
    attachmentInfo: attachmentInfo,
    archiveKey: _archiveCompatibilityKeyFor(attachmentInfo),
    fileAccess: fileAccess,
  );
}

Future<ResolvedAttachment> _resolveForArchiveEnabledMode(
  AttachmentResolverRef ref, {
  required AttachmentInfo attachmentInfo,
  required ArchiveCompatibilityKey? archiveKey,
  required AttachmentFileAccess fileAccess,
}) async {
  final resolvedPath = fileAccess.expandPath(attachmentInfo.localPath);
  final liveFileExists = fileAccess.existingExpandedPath(resolvedPath) != null;
  AttachmentRecoveryMetadata? persistedRecoveryHint;

  if (archiveKey != null) {
    final archiveReadStore = await ref.watch(
      attachmentArchiveReadStoreProvider.future,
    );
    persistedRecoveryHint = await archiveReadStore.readRecoveryHint(archiveKey);

    final archiveRecord = await archiveReadStore.readArchiveRecord(archiveKey);

    if (archiveRecord != null && archiveRecord.archiveFileExists) {
      final provenance = switch (archiveRecord.provenance) {
        'imported_historical' => AttachmentProvenance.importedHistorical,
        _ => AttachmentProvenance.archived,
      };

      return ResolvedAttachment(
        attachmentInfo: attachmentInfo,
        availability: ResolvedAttachmentAvailability.available,
        provenance: provenance,
        resolvedFilePath: archiveRecord.archiveAbsolutePath,
      );
    }
  }

  if (liveFileExists && resolvedPath != null && archiveKey != null) {
    _triggerOnDemandArchive(
      ref,
      archiveKey: archiveKey,
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

  final isRecoverable = attachmentInfo.hasLocalFile || archiveKey != null;

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
  required AttachmentFileAccess fileAccess,
}) {
  final resolvedPath = fileAccess.expandPath(attachmentInfo.localPath);
  final resolvedFilePath = fileAccess.existingExpandedPath(resolvedPath);
  if (resolvedFilePath != null) {
    return ResolvedAttachment(
      attachmentInfo: attachmentInfo,
      availability: ResolvedAttachmentAvailability.available,
      provenance: AttachmentProvenance.messagesLive,
      resolvedFilePath: resolvedFilePath,
    );
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
  required ArchiveCompatibilityKey archiveKey,
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
        archiveKey: archiveKey,
        resolvedLocalPath: resolvedLocalPath,
        mimeType: mimeType,
        sha256Hex: null,
      );
}

ArchiveCompatibilityKey? _archiveCompatibilityKeyFor(
  AttachmentInfo attachmentInfo,
) {
  final messageGuid = attachmentInfo.messageGuid;
  final importAttachmentId = attachmentInfo.importAttachmentId;
  if (messageGuid == null ||
      messageGuid.isEmpty ||
      importAttachmentId == null) {
    return null;
  }
  return ArchiveCompatibilityKey(
    messageGuid: messageGuid,
    importAttachmentId: importAttachmentId,
  );
}
