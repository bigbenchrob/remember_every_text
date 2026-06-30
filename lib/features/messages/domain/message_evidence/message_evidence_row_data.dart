class MessageEvidenceRowData {
  const MessageEvidenceRowData({
    required this.messageId,
    required this.dateUtc,
    required this.isFromMe,
    required this.text,
    required this.associatedMessageId,
    required this.attachmentCount,
    this.senderHandleId,
    this.senderCanonicalHandleId,
    this.senderDisplayHandle,
    this.senderRawHandleLabel,
    this.semanticKind,
    this.itemKind,
    this.isSystemMessage = false,
    this.isSparseArtifact = false,
    this.hasAttributedBodySource = false,
    this.hasMessageSummaryInfo = false,
    this.hasPayloadDataSource = false,
    this.errorCode,
  });

  final int messageId;
  final String? dateUtc;
  final bool isFromMe;
  final String? text;
  final int? associatedMessageId;
  final int attachmentCount;
  final int? senderHandleId;
  final int? senderCanonicalHandleId;
  final String? senderDisplayHandle;
  final String? senderRawHandleLabel;
  final String? semanticKind;
  final String? itemKind;
  final bool isSystemMessage;
  final bool isSparseArtifact;
  final bool hasAttributedBodySource;
  final bool hasMessageSummaryInfo;
  final bool hasPayloadDataSource;
  final int? errorCode;
}
