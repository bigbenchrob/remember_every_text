import 'dart:io';

import 'package:path/path.dart' as path;

import '../message_importer.dart';
import '../message_projector.dart';
import 'incremental_update_status_provider.dart';

class SourceScopedProofLogWriter {
  const SourceScopedProofLogWriter({Directory? logsDirectory})
    : _logsDirectory = logsDirectory;

  final Directory? _logsDirectory;

  Future<File> writeRun({
    required IncrementalUpdateStatus before,
    IncrementalUpdateStatus? after,
    MessageImportResult? importResult,
    MessageProjectionResult? projectionResult,
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
        'source_scoped_incremental_update_${_fileTimestamp(capturedAt)}.md',
      ),
    );

    await file.writeAsString(
      _formatRun(
        capturedAt: capturedAt,
        before: before,
        after: after,
        importResult: importResult,
        projectionResult: projectionResult,
        error: error,
        stackTrace: stackTrace,
      ),
      flush: true,
    );

    return file;
  }
}

String _formatRun({
  required DateTime capturedAt,
  required IncrementalUpdateStatus before,
  required IncrementalUpdateStatus? after,
  required MessageImportResult? importResult,
  required MessageProjectionResult? projectionResult,
  required Object? error,
  required StackTrace? stackTrace,
}) {
  final errorBlock = error == null
      ? ''
      : '\n## Error\n\n'
            '- error: ${_singleLine(error.toString())}\n'
            '- stack_trace: ${_singleLine(stackTrace.toString())}\n';

  return '# Source-scoped incremental-update proof log\n\n'
      '- captured_at: ${capturedAt.toIso8601String()}\n'
      '- action: Import + Project SS Graph\n'
      '- source: dev status panel\n\n'
      '## Import result\n\n'
      '- started_after_source_rowid: ${_formatInt(importResult?.startedAfterSourceRowId)}\n'
      '- inserted_messages: ${_formatInt(importResult?.insertedMessageCount)}\n'
      '- last_imported_source_rowid: ${_formatInt(importResult?.lastImportedSourceRowId)}\n\n'
      '## Projection result\n\n'
      '- examined_messages: ${_formatInt(projectionResult?.examinedMessageCount)}\n'
      '- inserted_messages: ${_formatInt(projectionResult?.insertedMessageCount)}\n\n'
      '## Before\n\n'
      '${_formatStatus(before)}\n'
      '## After\n\n'
      '${after == null ? '- not captured\n' : _formatStatus(after)}'
      '$errorBlock';
}

String _formatStatus(IncrementalUpdateStatus status) {
  return '- source_messages: ${status.sourceMessageCount}\n'
      '- import_ss_messages: ${status.ledgerMessageCount}\n'
      '- working_ss_messages: ${status.workingMessageCount}\n'
      '- associated_message_edges: ${status.associatedMessageEdgeCount}\n'
      '- source_chats: ${status.sourceChatCount}\n'
      '- import_ss_chats: ${status.importChatCount}\n'
      '- working_ss_chats: ${status.workingChatCount}\n'
      '- source_handles: ${status.sourceHandleCount}\n'
      '- import_ss_handles: ${status.importHandleCount}\n'
      '- working_ss_handles: ${status.workingHandleCount}\n'
      '- import_ss_chat_to_message_edges: ${status.importTopologyEdgeCount}\n'
      '- working_ss_chat_to_message_edges: ${status.workingTopologyEdgeCount}\n'
      '- duplicate_working_chat_to_message_edges: ${status.duplicateWorkingTopologyEdgeCount}\n'
      '- import_ss_chat_to_handle_edges: ${status.importChatToHandleEdgeCount}\n'
      '- working_ss_chat_to_handle_edges: ${status.workingChatToHandleEdgeCount}\n'
      '- duplicate_working_chat_to_handle_edges: ${status.duplicateWorkingChatToHandleEdgeCount}\n'
      '- source_max_rowid: ${status.sourceMaxRowId}\n'
      '- last_imported_source_rowid: ${status.ledgerMaxSourceRowId}\n'
      '- rowIdDelta: ${status.rowIdDelta}\n'
      '- messageCountDelta: ${status.messageCountDelta}\n';
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

String _fileTimestamp(DateTime value) {
  final local = value.toLocal();
  final year = local.year.toString().padLeft(4, '0');
  final month = local.month.toString().padLeft(2, '0');
  final day = local.day.toString().padLeft(2, '0');
  final hour = local.hour.toString().padLeft(2, '0');
  final minute = local.minute.toString().padLeft(2, '0');
  final second = local.second.toString().padLeft(2, '0');
  return '${year}_${month}_${day}_${hour}_${minute}_$second';
}

String _formatInt(int? value) {
  if (value == null) {
    return 'not captured';
  }
  return '$value';
}

String _singleLine(String value) {
  return value.replaceAll('\n', r'\n');
}
