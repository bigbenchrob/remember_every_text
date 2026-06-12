import 'dart:io';

import '../../application/attachment_file_access.dart';

class LocalAttachmentFileAccess implements AttachmentFileAccess {
  const LocalAttachmentFileAccess();

  @override
  String? expandPath(String? path) {
    if (path == null || path.isEmpty) {
      return null;
    }

    final expandedPath = path.startsWith('~/')
        ? path.replaceFirst('~', Platform.environment['HOME'] ?? '')
        : path;
    if (expandedPath.isEmpty) {
      return null;
    }

    return expandedPath;
  }

  @override
  File? existingFileAt(String? path) {
    final expandedPath = existingExpandedPath(path);
    if (expandedPath == null) {
      return null;
    }
    return File(expandedPath);
  }

  @override
  String? existingExpandedPath(String? path) {
    final expandedPath = expandPath(path);
    if (expandedPath == null) {
      return null;
    }

    final file = File(expandedPath);
    if (!file.existsSync()) {
      return null;
    }

    return expandedPath;
  }
}
