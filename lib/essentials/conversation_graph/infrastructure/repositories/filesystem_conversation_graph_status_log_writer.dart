import 'dart:io';

import 'package:path/path.dart' as path;

import '../../application/conversation_graph_build_report.dart';
import '../../application/status/conversation_graph_status_log_writer.dart';
import '../../domain/status/conversation_graph_status.dart';

class FilesystemConversationGraphStatusLogWriter
    implements ConversationGraphStatusLogWriter {
  const FilesystemConversationGraphStatusLogWriter({
    required Directory logsDirectory,
  })
    : _logsDirectory = logsDirectory;

  final Directory _logsDirectory;

  @override
  Future<String> writeRun({
    required ConversationGraphStatus before,
    ConversationGraphStatus? after,
    ConversationGraphBuildReport? buildReport,
    Object? error,
    StackTrace? stackTrace,
  }) async {
    final capturedAt = DateTime.now();
    if (_isSymlink(_logsDirectory.path)) {
      throw StateError(
        'Conversation graph log directory must not be a symlink.',
      );
    }
    _logsDirectory.createSync(recursive: true);

    final file = File(
      path.join(
        _logsDirectory.path,
        'conversation_graph_status_${conversationGraphStatusLogFileTimestamp(capturedAt)}.md',
      ),
    );
    if (_isSymlink(file.path) || _isDirectory(file.path)) {
      throw StateError('Conversation graph log target must be a regular file.');
    }

    await file.writeAsString(
      formatConversationGraphStatusLogRun(
        capturedAt: capturedAt,
        before: before,
        after: after,
        buildReport: buildReport,
        error: error,
        stackTrace: stackTrace,
      ),
      flush: true,
    );

    return file.path;
  }
}

bool _isDirectory(String filePath) {
  return FileSystemEntity.typeSync(filePath, followLinks: false) ==
      FileSystemEntityType.directory;
}

bool _isSymlink(String filePath) {
  return FileSystemEntity.typeSync(filePath, followLinks: false) ==
      FileSystemEntityType.link;
}
