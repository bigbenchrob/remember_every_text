import '../../../../essentials/presence/domain/services/test_agent.dart';

/// Selects one development-owned Contacts source for each fresh evaluation.
final class DevelopmentContactsSourceReadinessTestAgent implements TestAgent {
  const DevelopmentContactsSourceReadinessTestAgent({
    required Future<TestAgent> Function() testAgentForCurrentMode,
  }) : _testAgentForCurrentMode = testAgentForCurrentMode;

  final Future<TestAgent> Function() _testAgentForCurrentMode;

  @override
  Future<bool> evaluate() async {
    final testAgent = await _testAgentForCurrentMode();
    return testAgent.evaluate();
  }
}
