import 'choice_value.dart';
import 'step.dart';
import 'trip_definition_id.dart';

final class TripDefinition {
  TripDefinition({
    required this.id,
    required this.name,
    required List<Step> steps,
  }) : steps = List<Step>.unmodifiable(steps) {
    if (steps.isEmpty) {
      throw ArgumentError.value(steps, 'steps', 'A Trip requires a Step.');
    }
  }

  final TripDefinitionId id;
  final String name;
  final List<Step> steps;
}

typedef TripStepCompletion = ({
  bool tripCompleted,
  TripDefinitionId? routingResultTripDefinitionId,
});

/// One ordinary runtime Trip that sequences its definition's Steps.
final class Trip {
  Trip(this.definition);

  final TripDefinition definition;

  int _currentStepIndex = 0;
  bool _isComplete = false;

  Step? get currentStep {
    if (_isComplete) {
      return null;
    }
    return definition.steps[_currentStepIndex];
  }

  int get currentStepIndex => _currentStepIndex;

  bool get isComplete => _isComplete;

  Future<TripStepCompletion> completeCurrentStep() async {
    final step = currentStep;
    if (step == null) {
      throw StateError('Trip ${definition.id} is already complete.');
    }

    final routingResult = await step.complete();
    final isTerminal = _currentStepIndex == definition.steps.length - 1;
    if (!isTerminal) {
      _currentStepIndex += 1;
      return (tripCompleted: false, routingResultTripDefinitionId: null);
    }

    _isComplete = true;
    return (tripCompleted: true, routingResultTripDefinitionId: routingResult);
  }

  Future<TripStepCompletion> completeCurrentChoice(ChoiceValue value) async {
    final step = currentStep;
    if (step is! ChoiceStep) {
      throw StateError(
        'The current Step in Trip ${definition.id} is not a ChoiceStep.',
      );
    }
    if (_currentStepIndex != definition.steps.length - 1) {
      throw StateError(
        'ChoiceStep ${step.id} must be terminal in Trip ${definition.id}.',
      );
    }

    final routingResult = step.destinationFor(value);
    _isComplete = true;
    return (tripCompleted: true, routingResultTripDefinitionId: routingResult);
  }
}
