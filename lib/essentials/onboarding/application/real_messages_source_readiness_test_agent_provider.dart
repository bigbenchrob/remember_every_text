import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'full_disk_access_provider.dart';
import 'messages_source_access_denied_test_agent.dart';
import 'messages_source_access_evaluation.dart';
import 'messages_source_readiness_test_agent.dart';

part 'real_messages_source_readiness_test_agent_provider.g.dart';

@Riverpod(keepAlive: true)
MessagesSourceAccessEvaluation realMessagesSourceAccessEvaluation(Ref ref) {
  return MessagesSourceAccessEvaluation(
    fullDiskAccess: ref.watch(fullDiskAccessProvider),
  );
}

@Riverpod(keepAlive: true)
MessagesSourceReadinessTestAgent realMessagesSourceReadinessTestAgent(Ref ref) {
  return MessagesSourceReadinessTestAgent(
    evaluation: ref.watch(realMessagesSourceAccessEvaluationProvider),
  );
}

@Riverpod(keepAlive: true)
MessagesSourceAccessDeniedTestAgent realMessagesSourceAccessDeniedTestAgent(
  Ref ref,
) {
  return MessagesSourceAccessDeniedTestAgent(
    evaluation: ref.watch(realMessagesSourceAccessEvaluationProvider),
  );
}
