import '../../../essentials/source_scoped_import/domain/historical_archive_source_identity.dart';
import '../../../essentials/source_scoped_import/domain/messages_lineage_admission.dart';
import '../../attachments/domain/entities/message_lens_attachment_recovery.dart';

sealed class MessageLensHistoricalArchivePreflightResult {
  const MessageLensHistoricalArchivePreflightResult();
}

final class MessageLensHistoricalArchiveInvalidFolder
    extends MessageLensHistoricalArchivePreflightResult {
  const MessageLensHistoricalArchiveInvalidFolder();
}

final class MessageLensHistoricalArchiveIncompatible
    extends MessageLensHistoricalArchivePreflightResult {
  const MessageLensHistoricalArchiveIncompatible({required this.detail});

  final String detail;
}

final class MessageLensHistoricalArchiveLineageRejected
    extends MessageLensHistoricalArchivePreflightResult {
  const MessageLensHistoricalArchiveLineageRejected({required this.admission});

  final MessagesLineageAdmission admission;
}

final class MessageLensHistoricalArchiveReady
    extends MessageLensHistoricalArchivePreflightResult {
  const MessageLensHistoricalArchiveReady({
    required this.folderPath,
    required this.identity,
    required this.archiveInstanceId,
    required this.lineageAdmission,
    required this.attachmentPreflight,
  });

  final String folderPath;
  final HistoricalArchiveSourceIdentity identity;
  final String archiveInstanceId;
  final SameMessagesLineageAdmission lineageAdmission;
  final MessageLensAttachmentRecoveryPreflight attachmentPreflight;
}

abstract interface class MessageLensHistoricalArchivePreflight {
  Future<MessageLensHistoricalArchivePreflightResult> inspect({
    required String folderPath,
  });
}
