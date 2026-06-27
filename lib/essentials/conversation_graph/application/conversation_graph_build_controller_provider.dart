import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../db/feature_level_providers/message_data_version_provider.dart';
import 'conversation_graph_build_report.dart';
import 'conversation_graph_build_service_provider.dart';
import 'conversation_graph_build_state.dart';

part 'conversation_graph_build_controller_provider.g.dart';

@Riverpod(keepAlive: true)
class ConversationGraphBuildController
    extends _$ConversationGraphBuildController {
  Future<ConversationGraphBuildReport>? _inFlight;

  @override
  ConversationGraphBuildState build() {
    return const ConversationGraphBuildState.idle();
  }

  Future<ConversationGraphBuildReport> runOnce({
    String owner = 'conversation-graph-build-controller',
  }) {
    final inFlight = _inFlight;
    if (inFlight != null) {
      return inFlight;
    }

    late final Future<ConversationGraphBuildReport> future;
    future = _runBuild(owner).whenComplete(() {
      if (identical(_inFlight, future)) {
        _inFlight = null;
      }
    });
    _inFlight = future;
    return future;
  }

  Future<ConversationGraphBuildReport> _runBuild(String owner) async {
    final startedAt = DateTime.now().toUtc();
    state = ConversationGraphBuildState(
      status: ConversationGraphBuildStatus.running,
      owner: owner,
      startedAt: startedAt,
    );

    try {
      final service = await ref.read(
        conversationGraphBuildServiceProvider.future,
      );
      final report = await service.runOnce();
      ref.read(messageDataVersionProvider.notifier).bump();
      state = ConversationGraphBuildState(
        status: ConversationGraphBuildStatus.succeeded,
        owner: owner,
        startedAt: startedAt,
        finishedAt: DateTime.now().toUtc(),
        lastReport: report,
      );
      return report;
    } catch (error) {
      state = ConversationGraphBuildState(
        status: ConversationGraphBuildStatus.failed,
        owner: owner,
        startedAt: startedAt,
        finishedAt: DateTime.now().toUtc(),
        lastError: error.toString(),
      );
      rethrow;
    }
  }
}
