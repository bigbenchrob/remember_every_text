import 'package:flutter/widgets.dart';
import 'package:macos_ui/macos_ui.dart';

import '../../view_model/steps/ask_step_view_model.dart';

class AskStepView extends StatefulWidget {
  const AskStepView({
    required this.viewModel,
    required this.onAnswered,
    super.key,
  });

  final AskStepViewModel viewModel;
  final ValueChanged<String> onAnswered;

  @override
  State<AskStepView> createState() => _AskStepViewState();
}

class _AskStepViewState extends State<AskStepView> {
  final TextEditingController _answerController = TextEditingController();
  bool _hasSubmitted = false;

  bool get _canSubmit {
    return !_hasSubmitted && _answerController.text.trim().isNotEmpty;
  }

  @override
  void initState() {
    super.initState();
    _answerController.addListener(_handleDraftChanged);
  }

  @override
  void dispose() {
    _answerController
      ..removeListener(_handleDraftChanged)
      ..dispose();
    super.dispose();
  }

  void _handleDraftChanged() {
    setState(() {});
  }

  void _submit() {
    if (!_canSubmit) {
      return;
    }

    final answer = _answerController.text.trim();
    setState(() {
      _hasSubmitted = true;
    });
    widget.onAnswered(answer);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(widget.viewModel.question),
        MacosTextField(
          controller: _answerController,
          enabled: !_hasSubmitted,
          onSubmitted: (_) => _submit(),
        ),
        PushButton(
          controlSize: ControlSize.regular,
          onPressed: _canSubmit ? _submit : null,
          child: const Text('Continue'),
        ),
      ],
    );
  }
}
