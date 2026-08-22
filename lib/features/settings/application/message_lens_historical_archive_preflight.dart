import '../../../essentials/source_scoped_import/domain/messages_lineage_admission.dart';
import '../../attachments/domain/entities/message_lens_attachment_recovery.dart';
import '../../attachments/domain/entities/message_lens_attachment_recovery_donor.dart';

enum MessageLensHistoricalArchivePreflightPhase {
  structuralQualification,
  compatibilityInspection,
  lineageAdmission,
  donorAttachmentEvidence,
  currentAttachmentEvidence,
  donorPayloadEvidence,
  relationshipMatching,
  currentPayloadPresence,
  donorPayloadPresence,
  classification,
}

final class MessageLensHistoricalArchivePreflightProgress {
  const MessageLensHistoricalArchivePreflightProgress({
    required this.phase,
    required this.completedUnits,
    required this.totalUnits,
  });

  final MessageLensHistoricalArchivePreflightPhase phase;
  final int completedUnits;
  final int? totalUnits;
}

final class MessageLensHistoricalArchivePreflightTiming {
  const MessageLensHistoricalArchivePreflightTiming({
    required this.phase,
    required this.elapsed,
  });

  final MessageLensHistoricalArchivePreflightPhase phase;
  final Duration elapsed;
}

typedef MessageLensHistoricalArchivePreflightProgressObserver =
    void Function(MessageLensHistoricalArchivePreflightProgress progress);

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
    required this.donor,
    required this.lineageAdmission,
    required this.attachmentPreflight,
    this.phaseTimings = const <MessageLensHistoricalArchivePreflightTiming>[],
  });

  final MessageLensAttachmentRecoveryDonor donor;
  final SameMessagesLineageAdmission lineageAdmission;
  final MessageLensAttachmentRecoveryPreflight attachmentPreflight;
  final List<MessageLensHistoricalArchivePreflightTiming> phaseTimings;
}

final class MessageLensHistoricalArchivePreflightCancelled
    extends MessageLensHistoricalArchivePreflightResult {
  const MessageLensHistoricalArchivePreflightCancelled();
}

abstract interface class MessageLensHistoricalArchivePreflight {
  Future<MessageLensHistoricalArchivePreflightResult> inspect({
    required String folderPath,
    MessageLensHistoricalArchivePreflightProgressObserver? onProgress,
    bool Function()? isCancelled,
  });
}
