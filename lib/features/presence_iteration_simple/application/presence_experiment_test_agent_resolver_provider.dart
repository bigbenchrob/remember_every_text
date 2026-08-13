import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../essentials/onboarding/application/onboarding_test_agent_bindings.dart';
import '../../../essentials/onboarding/feature_level_providers.dart'
    show
        realMessagesSourceHistorySufficiencyTestAgentProvider,
        realMessagesSourceReadinessTestAgentProvider;
import '../../../essentials/presence/domain/services/test_agent_resolver.dart';
import 'development_contacts_source_provider.dart';

part 'presence_experiment_test_agent_resolver_provider.g.dart';

/// Combines workflow-owner contributions at the current application boundary.
///
/// Presence receives only the completed resolver and does not discover Agents.
@Riverpod(keepAlive: true)
Future<TestAgentResolver> presenceExperimentTestAgentResolver(Ref ref) async {
  final messagesAgent = ref.watch(realMessagesSourceReadinessTestAgentProvider);
  final contactsAgent = await ref.watch(
    developmentContactsSourceReadinessTestAgentProvider.future,
  );
  final messagesHistoryAgent = ref.watch(
    realMessagesSourceHistorySufficiencyTestAgentProvider,
  );
  final onboardingBindings = buildOnboardingTestAgentBindings(
    messagesSourceReadinessTestAgent: messagesAgent,
    contactsSourceReadinessTestAgent: contactsAgent,
    messagesSourceHistorySufficiencyTestAgent: messagesHistoryAgent,
  );
  return ImmutableTestAgentResolver(<TestAgentBinding>[...onboardingBindings]);
}
