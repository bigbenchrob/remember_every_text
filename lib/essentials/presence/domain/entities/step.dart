import 'package:freezed_annotation/freezed_annotation.dart';

part 'step.freezed.dart';

@freezed
sealed class Step with _$Step {
  const factory Step.tell({
    required int id,
    required String text,
    required bool advancesAutomatically,
    required Duration holdDuration,
  }) = TellStep;

  const factory Step.ask({required int id, required String question}) = AskStep;
}
