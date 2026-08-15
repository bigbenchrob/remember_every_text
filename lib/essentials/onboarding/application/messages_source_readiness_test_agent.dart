import '../../presence/domain/services/test_agent.dart';
import 'full_disk_access.dart';
import 'messages_source_access_evaluation.dart';

/// Establishes whether MessageLens can truthfully read its Messages source.
final class MessagesSourceReadinessTestAgent implements TestAgent {
  const MessagesSourceReadinessTestAgent({
    required MessagesSourceAccessEvaluation evaluation,
  }) : _evaluation = evaluation;

  final MessagesSourceAccessEvaluation _evaluation;

  @override
  Future<bool> evaluate() async {
    return _evaluation.evaluateFresh() == MessagesSourceAccessResult.readable;
  }
}
