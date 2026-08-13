import '../../presence/domain/services/test_agent.dart';
import '../../presence/domain/services/test_agent_resolver.dart';
import 'onboarding_test_agent_ids.dart';

/// Contributes Onboarding-owned Agents without constructing the app resolver.
List<TestAgentBinding> buildOnboardingTestAgentBindings({
  required TestAgent messagesSourceReadinessTestAgent,
  required TestAgent contactsSourceReadinessTestAgent,
  required TestAgent messagesSourceHistorySufficiencyTestAgent,
}) {
  return List<TestAgentBinding>.unmodifiable(<TestAgentBinding>[
    TestAgentBinding(
      id: messagesSourceReadableTestAgentId,
      agent: messagesSourceReadinessTestAgent,
    ),
    TestAgentBinding(
      id: contactsSourceReadableTestAgentId,
      agent: contactsSourceReadinessTestAgent,
    ),
    TestAgentBinding(
      id: messagesSourceHistorySufficientTestAgentId,
      agent: messagesSourceHistorySufficiencyTestAgent,
    ),
  ]);
}
