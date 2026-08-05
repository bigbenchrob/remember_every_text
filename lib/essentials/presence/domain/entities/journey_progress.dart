import 'journey.dart';
import 'step.dart';

class JourneyProgress {
  JourneyProgress(this.journey);

  final Journey journey;

  int _currentIndex = 0;

  Step? get currentStep {
    if (isDone) {
      return null;
    }
    return journey.steps[_currentIndex];
  }

  bool get isDone => _currentIndex >= journey.steps.length;

  void next() {
    if (isDone) {
      return;
    }
    _currentIndex += 1;
  }
}
