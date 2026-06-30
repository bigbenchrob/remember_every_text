import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../chat_summaries/chat_summary_provider.dart';
import '../conversation_graph_build_controller_provider.dart';
import '../health/graph_health_provider.dart';
import 'conversation_graph_status_log_writer_provider.dart';
import 'conversation_graph_status_provider.dart';

part 'conversation_graph_status_sheet_actions_provider.g.dart';

@riverpod
class ConversationGraphStatusSheetActions
    extends _$ConversationGraphStatusSheetActions {
  @override
  FutureOr<void> build() {}

  void refreshPrimaryStatus() {
    ref.invalidate(conversationGraphStatusProvider);
    ref.invalidate(graphHealthReportProvider);
  }

  void refreshStatusOnly() {
    ref.invalidate(conversationGraphStatusProvider);
  }

  Future<void> runManualBuild() async {
    final before = await ref.read(conversationGraphStatusProvider.future);
    try {
      final buildReport = await ref
          .read(conversationGraphBuildControllerProvider.notifier)
          .runOnce(owner: 'source-scoped-dev-panel');
      refreshAfterBuild();
      final after = await ref.read(conversationGraphStatusProvider.future);
      await ref
          .read(conversationGraphStatusLogWriterProvider)
          .writeRun(before: before, after: after, buildReport: buildReport);
    } catch (error, stackTrace) {
      await ref
          .read(conversationGraphStatusLogWriterProvider)
          .writeRun(before: before, error: error, stackTrace: stackTrace);
      rethrow;
    }
  }

  void refreshAfterBuild() {
    ref.invalidate(conversationGraphStatusProvider);
    ref.invalidate(graphHealthReportProvider);
    ref.invalidate(chatSummariesProvider);
    ref.invalidate(chatSummarySanityCountsProvider);
  }
}
