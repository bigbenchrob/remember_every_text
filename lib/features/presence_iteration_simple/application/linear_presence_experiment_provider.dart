import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../essentials/onboarding/application/required_sources_readiness_schedule.dart';
import '../../../essentials/onboarding/feature_level_providers.dart'
    show realFdaSettingsOpeningAuthorityProvider;
import '../../../essentials/presence/domain/services/presence_scheduler.dart';
import '../../../essentials/presence/feature_level_providers.dart'
    show presenceScheduleRepositoryProvider;
import 'presence_experiment_test_agent_resolver_provider.dart';

part 'linear_presence_experiment_provider.g.dart';

@Riverpod(keepAlive: true)
Future<PresenceScheduler> linearPresenceExperiment(Ref ref) async {
  final fdaSettingsAuthority = ref.watch(
    realFdaSettingsOpeningAuthorityProvider,
  );
  final testAgentResolver = await ref.watch(
    presenceExperimentTestAgentResolverProvider.future,
  );
  final repository = await ref.watch(
    presenceScheduleRepositoryProvider(
      testAgentResolver,
      fdaSettingsAuthority,
    ).future,
  );
  if (!await repository.definitionExists(requiredSourcesReadinessScheduleId)) {
    await repository.insertDefinition(
      buildRequiredSourcesReadinessDefinition(
        testAgentResolver: testAgentResolver,
        fdaSettingsOpeningAuthority: fdaSettingsAuthority,
      ),
    );
  }

  final scheduler = PresenceScheduler(
    repository: repository,
    scheduleDefinitionId: requiredSourcesReadinessScheduleId,
  );
  await scheduler.initialize();
  return scheduler;
}
