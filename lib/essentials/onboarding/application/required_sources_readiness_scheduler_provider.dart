import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../presence/domain/repositories/presence_schedule_repository.dart';
import '../../presence/domain/services/presence_scheduler.dart';
import '../../presence/domain/services/test_agent_resolver.dart';
import '../../presence/feature_level_providers.dart'
    show presenceScheduleRepositoryProvider;
import 'onboarding_test_agent_bindings.dart';
import 'real_contacts_source_readiness_test_agent_provider.dart';
import 'real_fda_settings_opening_authority_provider.dart';
import 'real_messages_source_history_sufficiency_test_agent_provider.dart';
import 'real_messages_source_readiness_test_agent_provider.dart';
import 'required_sources_readiness_schedule.dart';

part 'required_sources_readiness_scheduler_provider.g.dart';

/// Retired Presence laboratory composition for required-source readiness.
///
/// Production Onboarding no longer consumes this provider. The single active
/// prerequisite authority is `OnboardingJourneyCoordinator`; this composition
/// remains only for historical fixtures and developer experiments.
@Riverpod(keepAlive: true)
Future<PresenceScheduleRepository> requiredSourcesReadinessRepository(
  Ref ref,
) async {
  final messagesAgent = ref.watch(realMessagesSourceReadinessTestAgentProvider);
  final messagesAccessDeniedAgent = ref.watch(
    realMessagesSourceAccessDeniedTestAgentProvider,
  );
  final contactsAgent = await ref.watch(
    realContactsSourceReadinessTestAgentProvider.future,
  );
  final messagesHistoryAgent = ref.watch(
    realMessagesSourceHistorySufficiencyTestAgentProvider,
  );
  final fdaSettingsAuthority = ref.watch(
    realFdaSettingsOpeningAuthorityProvider,
  );
  final resolver = ImmutableTestAgentResolver(
    buildOnboardingTestAgentBindings(
      messagesSourceReadinessTestAgent: messagesAgent,
      messagesSourceAccessDeniedTestAgent: messagesAccessDeniedAgent,
      contactsSourceReadinessTestAgent: contactsAgent,
      messagesSourceHistorySufficiencyTestAgent: messagesHistoryAgent,
    ),
  );
  final repository = await ref.watch(
    presenceScheduleRepositoryProvider(resolver, fdaSettingsAuthority).future,
  );

  return repository;
}

/// Retired laboratory acceptance established by Schedule completion.
@Riverpod(keepAlive: true)
Stream<bool> requiredSourcesReadinessAccepted(Ref ref) async* {
  final repository = await ref.watch(
    requiredSourcesReadinessRepositoryProvider.future,
  );
  yield* repository.watchLatestRunCompletion(
    requiredSourcesReadinessScheduleId,
  );
}

/// Retired laboratory composition root for the required-sources Schedule.
@Riverpod(keepAlive: true)
Future<PresenceScheduler> requiredSourcesReadinessScheduler(Ref ref) async {
  final repository = await ref.watch(
    requiredSourcesReadinessRepositoryProvider.future,
  );
  final messagesAgent = ref.watch(realMessagesSourceReadinessTestAgentProvider);
  final messagesAccessDeniedAgent = ref.watch(
    realMessagesSourceAccessDeniedTestAgentProvider,
  );
  final contactsAgent = await ref.watch(
    realContactsSourceReadinessTestAgentProvider.future,
  );
  final messagesHistoryAgent = ref.watch(
    realMessagesSourceHistorySufficiencyTestAgentProvider,
  );
  final fdaSettingsAuthority = ref.watch(
    realFdaSettingsOpeningAuthorityProvider,
  );
  final resolver = ImmutableTestAgentResolver(
    buildOnboardingTestAgentBindings(
      messagesSourceReadinessTestAgent: messagesAgent,
      messagesSourceAccessDeniedTestAgent: messagesAccessDeniedAgent,
      contactsSourceReadinessTestAgent: contactsAgent,
      messagesSourceHistorySufficiencyTestAgent: messagesHistoryAgent,
    ),
  );

  await repository.installOrExtendDefinition(
    buildRequiredSourcesReadinessDefinition(
      testAgentResolver: resolver,
      fdaSettingsOpeningAuthority: fdaSettingsAuthority,
    ),
  );

  final scheduler = PresenceScheduler(
    repository: repository,
    scheduleDefinitionId: requiredSourcesReadinessScheduleId,
  );
  await scheduler.initialize();
  return scheduler;
}
