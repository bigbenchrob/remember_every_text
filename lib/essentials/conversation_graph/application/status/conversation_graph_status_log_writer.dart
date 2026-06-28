import '../../domain/status/conversation_graph_status.dart';
import '../conversation_graph_build_report.dart';

abstract interface class ConversationGraphStatusLogWriter {
  Future<String> writeRun({
    required ConversationGraphStatus before,
    ConversationGraphStatus? after,
    ConversationGraphBuildReport? buildReport,
    Object? error,
    StackTrace? stackTrace,
  });
}

String formatConversationGraphStatusLogRun({
  required DateTime capturedAt,
  required ConversationGraphStatus before,
  required ConversationGraphStatus? after,
  required ConversationGraphBuildReport? buildReport,
  required Object? error,
  required StackTrace? stackTrace,
}) {
  final errorBlock = error == null
      ? ''
      : '\n## Error\n\n'
            '- error: ${_singleLine(error.toString())}\n'
            '- stack_trace: ${_singleLine(stackTrace.toString())}\n';

  return '# Conversation graph status log\n\n'
      '- captured_at: ${capturedAt.toIso8601String()}\n'
      '- action: Import + Project Graph\n'
      '- source: graph status panel\n\n'
      '## Build report\n\n'
      '- started_at: ${buildReport?.startedAt.toIso8601String() ?? 'not captured'}\n'
      '- finished_at: ${buildReport?.finishedAt.toIso8601String() ?? 'not captured'}\n'
      '- duration_ms: ${_formatBuildDurationMs(buildReport)}\n'
      '- completed_stages: ${buildReport?.completedStageNames.join(', ') ?? 'not captured'}\n\n'
      '## Build stage timings\n\n'
      '${_formatStageTimings(buildReport)}\n'
      '## Import result\n\n'
      '- started_after_source_rowid: ${_formatInt(buildReport?.messageImportResult.startedAfterSourceRowId)}\n'
      '- inserted_messages: ${_formatInt(buildReport?.messageImportResult.insertedMessageCount)}\n'
      '- last_imported_source_rowid: ${_formatInt(buildReport?.messageImportResult.lastImportedSourceRowId)}\n\n'
      '## Rich-text enrichment result\n\n'
      '- candidates: ${_formatInt(buildReport?.richTextEnrichmentResult.candidateMessageCount)}\n'
      '- enriched_messages: ${_formatInt(buildReport?.richTextEnrichmentResult.enrichedMessageCount)}\n'
      '- missing_extractions: ${_formatInt(buildReport?.richTextEnrichmentResult.missingExtractionCount)}\n'
      '- extractor_available: ${buildReport?.richTextEnrichmentResult.extractorAvailable ?? 'not captured'}\n\n'
      '## Projection result\n\n'
      '- examined_messages: ${_formatInt(buildReport?.messageProjectionResult.examinedMessageCount)}\n'
      '- inserted_messages: ${_formatInt(buildReport?.messageProjectionResult.insertedMessageCount)}\n\n'
      '## Before\n\n'
      '${_formatStatus(before)}\n'
      '## After\n\n'
      '${after == null ? '- not captured\n' : _formatStatus(after)}'
      '$errorBlock';
}

String _formatBuildDurationMs(ConversationGraphBuildReport? buildReport) {
  if (buildReport == null) {
    return 'not captured';
  }
  return buildReport.finishedAt
      .difference(buildReport.startedAt)
      .inMilliseconds
      .toString();
}

String _formatStageTimings(ConversationGraphBuildReport? buildReport) {
  final timings = buildReport?.stageTimings;
  if (timings == null) {
    return '- not captured\n';
  }
  if (timings.isEmpty) {
    return '- none\n';
  }
  return timings
      .map((timing) => '- ${timing.stageName}: ${timing.durationMs} ms')
      .join('\n')
      .replaceFirst(RegExp(r'$'), '\n');
}

String _formatStatus(ConversationGraphStatus status) {
  return '- source_messages: ${status.sourceMessageCount}\n'
      '- import_ss_messages: ${status.ledgerMessageCount}\n'
      '- graph_messages: ${status.graphMessageCount}\n'
      '- associated_message_edges: ${status.associatedMessageEdgeCount}\n'
      '- source_chats: ${status.sourceChatCount}\n'
      '- import_ss_chats: ${status.importChatCount}\n'
      '- graph_chats: ${status.graphChatCount}\n'
      '- source_handles: ${status.sourceHandleCount}\n'
      '- import_ss_handles: ${status.importHandleCount}\n'
      '- graph_handles: ${status.graphHandleCount}\n'
      '- import_ss_chat_to_message_edges: ${status.importTopologyEdgeCount}\n'
      '- graph_chat_to_message_edges: ${status.graphTopologyEdgeCount}\n'
      '- duplicate_graph_chat_to_message_edges: ${status.duplicateGraphTopologyEdgeCount}\n'
      '- import_ss_chat_to_handle_edges: ${status.importChatToHandleEdgeCount}\n'
      '- graph_chat_to_handle_edges: ${status.graphChatToHandleEdgeCount}\n'
      '- duplicate_graph_chat_to_handle_edges: ${status.duplicateGraphChatToHandleEdgeCount}\n'
      '- source_attachments: ${status.sourceAttachmentCount}\n'
      '- import_ss_attachments: ${status.importAttachmentCount}\n'
      '- graph_attachments: ${status.graphAttachmentCount}\n'
      '- import_ss_message_to_attachment_edges: ${status.importMessageToAttachmentEdgeCount}\n'
      '- graph_message_to_attachment_edges: ${status.graphMessageToAttachmentEdgeCount}\n'
      '- duplicate_graph_message_to_attachment_edges: ${status.duplicateGraphMessageToAttachmentEdgeCount}\n'
      '- source_max_rowid: ${status.sourceMaxRowId}\n'
      '- last_imported_source_rowid: ${status.ledgerMaxSourceRowId}\n'
      '- rowIdDelta: ${status.rowIdDelta}\n'
      '- messageCountDelta: ${status.messageCountDelta}\n';
}

String conversationGraphStatusLogFileTimestamp(DateTime value) {
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
