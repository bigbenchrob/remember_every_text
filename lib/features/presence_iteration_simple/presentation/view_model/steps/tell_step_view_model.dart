import '../../../../../essentials/presence/domain/entities/step.dart';

class TellStepViewModel {
  const TellStepViewModel(this.step);

  final TellStep step;

  String get text => step.text;

  bool get advancesAutomatically => step.advancesAutomatically;

  Duration get holdDuration => step.holdDuration;
}
