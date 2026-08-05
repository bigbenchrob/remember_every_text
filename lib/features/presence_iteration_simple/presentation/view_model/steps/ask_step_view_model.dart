import '../../../../../essentials/presence/domain/entities/step.dart';

class AskStepViewModel {
  const AskStepViewModel(this.step);

  final AskStep step;

  String get question => step.question;
}
