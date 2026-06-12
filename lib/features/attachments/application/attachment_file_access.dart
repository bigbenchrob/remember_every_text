abstract interface class AttachmentFileAccess {
  String? expandPath(String? path);

  String? existingExpandedPath(String? path);
}
