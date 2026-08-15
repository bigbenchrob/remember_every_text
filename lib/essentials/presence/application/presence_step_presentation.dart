import '../domain/entities/choice_value.dart';
import '../domain/entities/step.dart';
import '../domain/services/presence_scheduler.dart';

typedef PresenceStepCompletion = Future<void> Function();

sealed class PresenceStepPresentation {
  const PresenceStepPresentation();
}

final class TellStepPresentation extends PresenceStepPresentation {
  const TellStepPresentation({required this.text, required this.complete});

  final String text;
  final PresenceStepCompletion complete;
}

final class TestStepPresentation extends PresenceStepPresentation {
  const TestStepPresentation({required this.label, required this.complete});

  final String label;
  final PresenceStepCompletion complete;
}

final class FixedDestinationStepPresentation extends PresenceStepPresentation {
  const FixedDestinationStepPresentation({
    required this.label,
    required this.complete,
  });

  final String label;
  final PresenceStepCompletion complete;
}

final class ChoiceStepPresentation extends PresenceStepPresentation {
  ChoiceStepPresentation({
    required List<ChoicePresentationItem> items,
    required this.select,
  }) : items = List<ChoicePresentationItem>.unmodifiable(items);

  final List<ChoicePresentationItem> items;
  final CurrentChoiceSelection select;
}

final class ChoicePresentationItem {
  const ChoicePresentationItem({required this.label, required this.value});

  final String label;
  final ChoiceValue value;
}

/// Marks a Step whose presentation still belongs to a specialist boundary.
final class SpecialistStepPresentation extends PresenceStepPresentation {
  const SpecialistStepPresentation();
}

/// Removes execution geometry before the current Step reaches Flutter.
abstract final class PresenceStepPresentationProjector {
  const PresenceStepPresentationProjector._();

  static PresenceStepPresentation project({
    required Step step,
    required PresenceStepCompletion complete,
    required CurrentChoiceSelection Function() issueChoiceSelection,
  }) {
    return switch (step) {
      TellStep(:final text) => TellStepPresentation(
        text: text,
        complete: complete,
      ),
      TestStep(:final name) => TestStepPresentation(
        label: name,
        complete: complete,
      ),
      FixedDestinationStep(:final name) => FixedDestinationStepPresentation(
        label: name,
        complete: complete,
      ),
      ChoiceStep(:final options) => ChoiceStepPresentation(
        items: options
            .map(
              (option) => ChoicePresentationItem(
                label: option.label,
                value: option.value,
              ),
            )
            .toList(growable: false),
        select: issueChoiceSelection(),
      ),
      OpenFdaSettingsStep() => const SpecialistStepPresentation(),
    };
  }
}
