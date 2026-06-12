abstract interface class CurrentMessagesAttachmentPathLookup {
  Future<String?> attachmentPathForSourceRowId(int sourceRowId);
}
