import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../essentials/onboarding/application/required_sources_readiness_schedule.dart';
import '../../../essentials/onboarding/feature_level_providers.dart'
    show realFdaSettingsOpeningAuthorityProvider;
import '../../../essentials/presence/feature_level_providers.dart'
    show presenceScheduleRepositoryProvider;
import '../infrastructure/development/schedule_topology_projector.dart';
import 'linear_presence_experiment_provider.dart';
import 'presence_experiment_test_agent_resolver_provider.dart';
import 'presence_run_visualization.dart';
import 'presence_run_visualization_builder.dart';

part 'linear_presence_experiment_visualization_provider.g.dart';

@riverpod
class LinearPresenceExperimentVisualization
    extends _$LinearPresenceExperimentVisualization {
  @override
  Future<PresenceRunVisualization> build(int scheduleRunId) async {
    await ref.watch(linearPresenceExperimentProvider.future);
    return _load(scheduleRunId);
  }

  Future<void> refresh() async {
    state = const AsyncLoading<PresenceRunVisualization>().copyWithPrevious(
      state,
    );
    state = AsyncData<PresenceRunVisualization>(await _load(scheduleRunId));
  }

  Future<PresenceRunVisualization> _load(int runId) async {
    final fdaSettingsAuthority = ref.read(
      realFdaSettingsOpeningAuthorityProvider,
    );
    final testAgentResolver = await ref.read(
      presenceExperimentTestAgentResolverProvider.future,
    );
    final repository = await ref.read(
      presenceScheduleRepositoryProvider(
        testAgentResolver,
        fdaSettingsAuthority,
      ).future,
    );
    final definition = await repository.loadDefinition(
      requiredSourcesReadinessScheduleId,
    );
    final run = await repository.loadRun(runId);
    final trace = await repository.loadExecutionTrace(runId);
    final topology = const ScheduleTopologyProjector().project(definition);
    return const PresenceRunVisualizationBuilder().build(
      topology: topology,
      run: run,
      trace: trace,
    );
  }
}
