import 'dart:io';

import 'package:path/path.dart' as path;

import '../../application/orchestrators/conversation_graph_build_orchestrator.dart';
import '../../application/status/conversation_graph_status_log_writer.dart';
import '../../application/status/conversation_graph_status_provider.dart';

class FilesystemConversationGraphStatusLogWriter
    implements ConversationGraphStatusLogWriter {
  const FilesystemConversationGraphStatusLogWriter({Directory? logsDirectory})
    : _logsDirectory = logsDirectory;

  final Directory? _logsDirectory;

  @override
  Future<String> writeRun({
    required ConversationGraphStatus before,
    ConversationGraphStatus? after,
    ConversationGraphBuildReport? buildReport,
    Object? error,
    StackTrace? stackTrace,
  }) async {
    final capturedAt = DateTime.now();
    final logsDirectory =
        _logsDirectory ?? Directory(path.join(_projectRootPath(), '_LOGS'));
    logsDirectory.createSync(recursive: true);

    final file = File(
      path.join(
        logsDirectory.path,
        'conversation_graph_status_${conversationGraphStatusLogFileTimestamp(capturedAt)}.md',
      ),
    );

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

String _projectRootPath() {
  var directory = Directory.current;

  while (true) {
    final pubspec = File(path.join(directory.path, 'pubspec.yaml'));
    final agentInstructions = Directory(
      path.join(directory.path, '_AGENT_INSTRUCTIONS'),
    );
    if (pubspec.existsSync() && agentInstructions.existsSync()) {
      return directory.path;
    }

    final parent = directory.parent;
    if (parent.path == directory.path) {
      return Directory.current.path;
    }
    directory = parent;
  }
}
