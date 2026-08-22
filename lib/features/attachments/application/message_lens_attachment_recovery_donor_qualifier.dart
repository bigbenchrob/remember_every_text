import '../domain/entities/message_lens_attachment_recovery_donor.dart';

enum MessageLensAttachmentRecoveryDonorQualificationStage {
  structuralQualification,
  compatibilityInspection,
}

typedef MessageLensAttachmentRecoveryDonorQualificationObserver =
    void Function(
      MessageLensAttachmentRecoveryDonorQualificationStage stage, {
      required bool completed,
    });

sealed class MessageLensAttachmentRecoveryDonorQualification {
  const MessageLensAttachmentRecoveryDonorQualification();
}

final class InvalidMessageLensAttachmentRecoveryDonor
    extends MessageLensAttachmentRecoveryDonorQualification {
  const InvalidMessageLensAttachmentRecoveryDonor();
}

final class IncompatibleMessageLensAttachmentRecoveryDonor
    extends MessageLensAttachmentRecoveryDonorQualification {
  const IncompatibleMessageLensAttachmentRecoveryDonor({required this.detail});

  final String detail;
}

final class SupportedMessageLensAttachmentRecoveryDonor
    extends MessageLensAttachmentRecoveryDonorQualification {
  const SupportedMessageLensAttachmentRecoveryDonor({required this.donor});

  final MessageLensAttachmentRecoveryDonor donor;
}

abstract interface class MessageLensAttachmentRecoveryDonorQualifier {
  Future<MessageLensAttachmentRecoveryDonorQualification> qualify({
    required String folderPath,
    MessageLensAttachmentRecoveryDonorQualificationObserver? onProgress,
  });
}
