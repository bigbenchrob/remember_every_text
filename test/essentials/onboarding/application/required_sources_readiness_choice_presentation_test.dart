import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:remember_this_text/essentials/onboarding/application/onboarding_test_agent_bindings.dart';
import 'package:remember_this_text/essentials/onboarding/application/required_sources_readiness_schedule.dart';
import 'package:remember_this_text/essentials/presence/application/presence_step_presentation.dart';
import 'package:remember_this_text/essentials/presence/domain/entities/choice_value.dart';
import 'package:remember_this_text/essentials/presence/domain/services/fda_settings_opening_authority.dart';
import 'package:remember_this_text/essentials/presence/domain/services/test_agent.dart';
import 'package:remember_this_text/essentials/presence/domain/services/test_agent_resolver.dart';
import 'package:remember_this_text/essentials/presence/presentation/presence_step_presenter.dart';

void main() {
  testWidgets('real Onboarding Choice renders through generic Presence', (
    tester,
  ) async {
    const agent = _ConstantTestAgent();
    final resolver = ImmutableTestAgentResolver(
      buildOnboardingTestAgentBindings(
        messagesSourceReadinessTestAgent: agent,
        messagesSourceAccessDeniedTestAgent: agent,
        contactsSourceReadinessTestAgent: agent,
        messagesSourceHistorySufficiencyTestAgent: agent,
      ),
    );
    final definition = buildRequiredSourcesReadinessDefinition(
      testAgentResolver: resolver,
      fdaSettingsOpeningAuthority: const _NoOpSettingsAuthority(),
    );
    final choice = definition.trips
        .singleWhere(
          (scheduledTrip) =>
              scheduledTrip.trip.id == guideSparseMessagesSourceHistoryTripId,
        )
        .trip
        .steps
        .last;
    ChoiceValue? selected;
    final presentation = PresenceStepPresentationProjector.project(
      step: choice,
      complete: () async {},
      issueChoiceSelection: () => (value) async {
        selected = value;
      },
    );

    await tester.pumpWidget(
      ProviderScope(
        child: MacosApp(
          home: Center(
            child: PresenceStepPresenter(
              presentation: presentation,
              specialistBuilder: (_) => const SizedBox.shrink(),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Re-check'), findsOneWidget);
    expect(find.text('Import Anyway'), findsOneWidget);
    await tester.tap(find.text('Import Anyway'));
    await tester.pump();
    expect(selected, ChoiceValue('import_anyway'));
  });
}

final class _ConstantTestAgent implements TestAgent {
  const _ConstantTestAgent();

  @override
  Future<bool> evaluate() async => true;
}

final class _NoOpSettingsAuthority implements FdaSettingsOpeningAuthority {
  const _NoOpSettingsAuthority();

  @override
  Future<void> openSettings() async {}
}
