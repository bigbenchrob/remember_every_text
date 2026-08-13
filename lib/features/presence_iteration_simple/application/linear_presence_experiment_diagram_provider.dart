import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../essentials/onboarding/application/required_sources_readiness_schedule.dart';
import '../../../essentials/onboarding/feature_level_providers.dart'
    show realFdaSettingsOpeningAuthorityProvider;
import '../../../essentials/presence/feature_level_providers.dart'
    show presenceScheduleRepositoryProvider;
import '../infrastructure/development/schedule_mermaid_document.dart';
import '../infrastructure/development/schedule_mermaid_renderer.dart';
import 'linear_presence_experiment_provider.dart';
import 'presence_experiment_test_agent_resolver_provider.dart';

part 'linear_presence_experiment_diagram_provider.g.dart';

@riverpod
Future<ScheduleMermaidDocument> linearPresenceExperimentDiagram(Ref ref) async {
  await ref.watch(linearPresenceExperimentProvider.future);
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
  final definition = await repository.loadDefinition(
    requiredSourcesReadinessScheduleId,
  );
  return const ScheduleMermaidRenderer().render(definition);
}
