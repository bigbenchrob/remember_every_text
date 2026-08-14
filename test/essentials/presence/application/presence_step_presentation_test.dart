import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/presence/application/presence_step_presentation.dart';
import 'package:remember_this_text/essentials/presence/domain/entities/choice_option.dart';
import 'package:remember_this_text/essentials/presence/domain/entities/choice_value.dart';
import 'package:remember_this_text/essentials/presence/domain/entities/step.dart';
import 'package:remember_this_text/essentials/presence/domain/entities/test_agent_id.dart';
import 'package:remember_this_text/essentials/presence/domain/entities/trip_definition_id.dart';
import 'package:remember_this_text/essentials/presence/domain/services/fda_settings_opening_authority.dart';
import 'package:remember_this_text/essentials/presence/domain/services/test_agent.dart';

void main() {
  PresenceStepPresentation project(Step step) {
    return PresenceStepPresentationProjector.project(
      step: step,
      complete: () async {},
      issueChoiceSelection: () => (value) async {},
    );
  }

  test('projects Tell without exposing Step identity', () {
    final presentation = project(
      const TellStep(id: 1, name: 'tell', text: 'Hello'),
    );

    expect(presentation, isA<TellStepPresentation>());
    expect((presentation as TellStepPresentation).text, 'Hello');
  });

  test('projects Test and Fixed Destination as distinct generic shapes', () {
    final testPresentation = project(
      TestStep(
        id: 2,
        name: 'test_source',
        testAgentId: TestAgentId('generic.test'),
        testAgent: const _TrueTestAgent(),
        trueDestinationTripDefinitionId: const TripDefinitionId(12),
        falseDestinationTripDefinitionId: const TripDefinitionId(15),
      ),
    );
    final fixedPresentation = project(
      const FixedDestinationStep(
        id: 3,
        name: 'continue',
        destinationTripDefinitionId: TripDefinitionId(19),
      ),
    );

    expect(testPresentation, isA<TestStepPresentation>());
    expect(fixedPresentation, isA<FixedDestinationStepPresentation>());
  });

  test('projects Choice in persisted order without destinations', () {
    final presentation =
        project(
              ChoiceStep(
                id: 4,
                name: 'choose_color',
                options: <ChoiceOption>[
                  ChoiceOption(
                    value: ChoiceValue('blue'),
                    label: 'Blue',
                    destinationTripDefinitionId: const TripDefinitionId(12),
                  ),
                  ChoiceOption(
                    value: ChoiceValue('pink'),
                    label: 'Pink',
                    destinationTripDefinitionId: const TripDefinitionId(15),
                  ),
                  ChoiceOption(
                    value: ChoiceValue('purple'),
                    label: 'Purple',
                    destinationTripDefinitionId: const TripDefinitionId(19),
                  ),
                ],
              ),
            )
            as ChoiceStepPresentation;

    expect(
      presentation.items.map((item) => (item.label, item.value.value)),
      orderedEquals(<(String, String)>[
        ('Blue', 'blue'),
        ('Pink', 'pink'),
        ('Purple', 'purple'),
      ]),
    );
  });

  test('projects Open FDA Settings to the explicit specialist boundary', () {
    final presentation = project(
      const OpenFdaSettingsStep(
        id: 5,
        name: 'open_settings',
        settingsOpeningAuthority: _NoOpFdaSettingsAuthority(),
      ),
    );

    expect(presentation, isA<SpecialistStepPresentation>());
  });
}

final class _TrueTestAgent implements TestAgent {
  const _TrueTestAgent();

  @override
  Future<bool> evaluate() async => true;
}

final class _NoOpFdaSettingsAuthority implements FdaSettingsOpeningAuthority {
  const _NoOpFdaSettingsAuthority();

  @override
  Future<void> openSettings() async {}
}
