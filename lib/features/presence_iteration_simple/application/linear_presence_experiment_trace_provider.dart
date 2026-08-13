import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../essentials/onboarding/feature_level_providers.dart'
    show realFdaSettingsOpeningAuthorityProvider;
import '../../../essentials/presence/domain/entities/execution_trace_event.dart';
import '../../../essentials/presence/feature_level_providers.dart'
    show presenceScheduleRepositoryProvider;
import 'linear_presence_experiment_provider.dart';
import 'presence_experiment_test_agent_resolver_provider.dart';

part 'linear_presence_experiment_trace_provider.g.dart';

@riverpod
class LinearPresenceExperimentTrace extends _$LinearPresenceExperimentTrace {
  @override
  Future<List<ExecutionTraceEvent>> build(int scheduleRunId) async {
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
    return repository.loadExecutionTrace(scheduleRunId);
  }

  Future<void> refresh() async {
    state = const AsyncLoading<List<ExecutionTraceEvent>>().copyWithPrevious(
      state,
    );
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
    state = AsyncData<List<ExecutionTraceEvent>>(
      await repository.loadExecutionTrace(scheduleRunId),
    );
  }
}
