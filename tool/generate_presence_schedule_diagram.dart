import 'dart:io';

import 'package:drift/native.dart';
import 'package:remember_this_text/essentials/onboarding/application/onboarding_test_agent_bindings.dart';
import 'package:remember_this_text/essentials/onboarding/application/required_sources_readiness_schedule.dart';
import 'package:remember_this_text/essentials/presence/domain/services/fda_settings_opening_authority.dart';
import 'package:remember_this_text/essentials/presence/domain/services/test_agent.dart';
import 'package:remember_this_text/essentials/presence/domain/services/test_agent_resolver.dart';
import 'package:remember_this_text/essentials/presence/infrastructure/data_sources/local/presence_database.dart';
import 'package:remember_this_text/essentials/presence/infrastructure/repositories/drift_presence_schedule_repository.dart';
import 'package:remember_this_text/features/presence_iteration_simple/infrastructure/development/schedule_mermaid_renderer.dart';

const String _outputPath =
    '_AGENT_INSTRUCTIONS/agent-per-project/45-NEW-FEATURE-ADDITION/'
    '21-PRESENCE-ITERATION-SIMPLE/03-SCHEDULE-TRIP-EXPERIMENT/generated/'
    'required_sources_readiness_onboarding_experiment.md';

Future<void> main() async {
  final database = PresenceDatabase(NativeDatabase.memory());
  try {
    const messagesAgent = _DiagramOnlyTestAgent('Messages source');
    const contactsAgent = _DiagramOnlyTestAgent('Contacts source');
    const settingsAuthority = _DiagramOnlyFdaSettingsOpeningAuthority();
    final testAgentResolver = ImmutableTestAgentResolver(
      buildOnboardingTestAgentBindings(
        messagesSourceReadinessTestAgent: messagesAgent,
        contactsSourceReadinessTestAgent: contactsAgent,
        messagesSourceHistorySufficiencyTestAgent: messagesAgent,
      ),
    );
    final repository = DriftPresenceScheduleRepository(
      database: database,
      testAgentResolver: testAgentResolver,
      fdaSettingsOpeningAuthority: settingsAuthority,
    );
    final fixture = buildRequiredSourcesReadinessDefinition(
      testAgentResolver: testAgentResolver,
      fdaSettingsOpeningAuthority: settingsAuthority,
    );
    await repository.insertDefinition(fixture);
    final persisted = await repository.loadDefinition(fixture.id);
    final document = const ScheduleMermaidRenderer().render(persisted);
    final output = File(_outputPath);
    await output.parent.create(recursive: true);
    await output.writeAsString(document.markdown);
    stdout.writeln('Generated ${output.path}');
  } finally {
    await database.close();
  }
}

final class _DiagramOnlyTestAgent implements TestAgent {
  const _DiagramOnlyTestAgent(this.sourceName);

  final String sourceName;

  @override
  Future<bool> evaluate() {
    return Future<bool>.error(
      StateError('Schedule diagram generation must not test $sourceName.'),
    );
  }
}

final class _DiagramOnlyFdaSettingsOpeningAuthority
    implements FdaSettingsOpeningAuthority {
  const _DiagramOnlyFdaSettingsOpeningAuthority();

  @override
  Future<void> openSettings() {
    return Future<void>.error(
      StateError('Schedule diagram generation must not open System Settings.'),
    );
  }
}
