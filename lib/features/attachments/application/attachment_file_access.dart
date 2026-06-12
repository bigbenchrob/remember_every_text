import 'dart:io';

abstract interface class AttachmentFileAccess {
  String? expandPath(String? path);

  File? existingFileAt(String? path);

  String? existingExpandedPath(String? path);
}
