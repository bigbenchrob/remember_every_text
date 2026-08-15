import '../../presence/domain/services/test_agent.dart';
import 'full_disk_access.dart';
import 'messages_source_access_evaluation.dart';

/// Projects the current specialist observation into generic Boolean routing.
final class MessagesSourceAccessDeniedTestAgent implements TestAgent {
  const MessagesSourceAccessDeniedTestAgent({
    required MessagesSourceAccessEvaluation evaluation,
  }) : _evaluation = evaluation;

  final MessagesSourceAccessEvaluation _evaluation;

  @override
  Future<bool> evaluate() async {
    return _evaluation.latestOrEvaluateFresh() ==
        MessagesSourceAccessResult.accessDenied;
  }
}
