import 'conversation_graph_build_report.dart';

enum ConversationGraphBuildStatus { idle, running, succeeded, failed }

class ConversationGraphBuildState {
  const ConversationGraphBuildState({
    required this.status,
    this.owner,
    this.startedAt,
    this.finishedAt,
    this.lastReport,
    this.lastError,
  });

  const ConversationGraphBuildState.idle()
    : status = ConversationGraphBuildStatus.idle,
      owner = null,
      startedAt = null,
      finishedAt = null,
      lastReport = null,
      lastError = null;

  final ConversationGraphBuildStatus status;
  final String? owner;
  final DateTime? startedAt;
  final DateTime? finishedAt;
  final ConversationGraphBuildReport? lastReport;
  final String? lastError;

  bool get isRunning => status == ConversationGraphBuildStatus.running;
}
