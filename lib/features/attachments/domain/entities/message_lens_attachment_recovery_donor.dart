/// One supported MessageLens attachment-recovery donor format.
enum MessageLensAttachmentRecoveryDonorFormat {
  currentMarkerV1('Current archive marker format 1'),
  importSchemaV8('Historical MessageLens import schema 8'),
  importSchemaV9('Historical MessageLens import schema 9'),
  importSchemaV10('Historical MessageLens import schema 10');

  const MessageLensAttachmentRecoveryDonorFormat(this.diagnosticLabel);

  final String diagnosticLabel;
}

/// Session-scoped evidence describing a qualified MessageLens recovery donor.
///
/// This is not a durable Historical Archives source. [rootPath] is only the
/// current inspection locator, and [archiveInstanceId] is optional diagnostic
/// evidence available from modern archive markers.
final class MessageLensAttachmentRecoveryDonor {
  const MessageLensAttachmentRecoveryDonor({
    required this.rootPath,
    required this.format,
    required this.archiveInstanceId,
  });

  final String rootPath;
  final MessageLensAttachmentRecoveryDonorFormat format;
  final String? archiveInstanceId;
}
