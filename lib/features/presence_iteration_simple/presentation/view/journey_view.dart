import 'package:flutter/widgets.dart';

import '../../../../essentials/presence/domain/entities/journey.dart';
import '../../../../essentials/presence/domain/entities/journey_progress.dart';
import '../../../../essentials/presence/domain/entities/step.dart';
import '../presence_presentation_tokens.dart';
import '../view_model/steps/ask_step_view_model.dart';
import '../view_model/steps/tell_step_view_model.dart';
import 'steps/ask_step_view.dart';
import 'steps/tell_step_view.dart';

class JourneyView extends StatefulWidget {
  const JourneyView({required this.journey, required this.onAnswer, super.key});

  final Journey journey;
  final ValueChanged<String> onAnswer;

  @override
  State<JourneyView> createState() => _JourneyViewState();
}

class _JourneyViewState extends State<JourneyView> {
  late JourneyProgress _progress;

  @override
  void initState() {
    super.initState();
    _progress = JourneyProgress(widget.journey);
  }

  void _advance() {
    setState(_progress.next);
  }

  void _handleAnswer(String answer) {
    widget.onAnswer(answer);
    setState(_progress.next);
  }

  Widget _buildStep(Step step) {
    return switch (step) {
      TellStep() => TellStepView(
        key: ValueKey<int>(step.id),
        viewModel: TellStepViewModel(step),
        onFinished: _advance,
      ),
      AskStep() => AskStepView(
        key: ValueKey<int>(step.id),
        viewModel: AskStepViewModel(step),
        onAnswered: _handleAnswer,
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final currentStep = _progress.currentStep;

    return Padding(
      padding: const EdgeInsets.all(PresencePresentationTokens.pageMargin),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: PresencePresentationTokens.maximumReadableWidth,
          ),
          child: currentStep == null
              ? const Text('Done')
              : _buildStep(currentStep),
        ),
      ),
    );
  }
}
