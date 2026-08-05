import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../../config/theme/theme_typography.dart';
import '../../presence_presentation_tokens.dart';
import '../../view_model/steps/tell_step_view_model.dart';

class TellStepView extends ConsumerStatefulWidget {
  const TellStepView({
    required this.viewModel,
    required this.onFinished,
    super.key,
  });

  final TellStepViewModel viewModel;
  final VoidCallback onFinished;

  @override
  ConsumerState<TellStepView> createState() => _TellStepViewState();
}

class _TellStepViewState extends ConsumerState<TellStepView> {
  static const _fadeDuration = Duration(seconds: 1);
  static const _pauseDuration = Duration(milliseconds: 500);

  double _opacity = 0;
  bool _isTransitioning = true;
  bool _hasFinished = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _opacity = 1;
      });
    });
  }

  void _startFinishing() {
    if (_isTransitioning || _hasFinished) {
      return;
    }
    setState(() {
      _isTransitioning = true;
      _opacity = 0;
    });
  }

  Future<void> _handleFadeEnd() async {
    if (!_isTransitioning || _hasFinished) {
      return;
    }

    if (_opacity == 1) {
      setState(() {
        _isTransitioning = false;
      });
      if (widget.viewModel.advancesAutomatically) {
        // The Tell owns this duration; the view only executes its lifecycle.
        await Future<void>.delayed(widget.viewModel.holdDuration);
        if (!mounted || _isTransitioning || _hasFinished || _opacity != 1) {
          return;
        }
        _startFinishing();
      }
      return;
    }

    await Future<void>.delayed(_pauseDuration);
    if (!mounted || !_isTransitioning || _hasFinished || _opacity != 0) {
      return;
    }

    _hasFinished = true;
    widget.onFinished();
  }

  @override
  Widget build(BuildContext context) {
    final typography = ref.watch(themeTypographyProvider);

    return AnimatedOpacity(
      duration: _fadeDuration,
      opacity: _opacity,
      onEnd: _handleFadeEnd,
      child: _TellParagraphs(
        text: widget.viewModel.text,
        typography: typography,
      ),
    );
  }
}

class _TellParagraphs extends StatelessWidget {
  const _TellParagraphs({required this.text, required this.typography});

  final String text;
  final ThemeTypography typography;

  @override
  Widget build(BuildContext context) {
    // Provisional rendering heuristic for the current onboarding copy only.
    final paragraphs = text.split('\n\n');

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        for (var index = 0; index < paragraphs.length; index += 1) ...<Widget>[
          if (index > 0)
            const SizedBox(height: PresencePresentationTokens.paragraphSpacing),
          _buildParagraph(paragraphs[index], index),
        ],
      ],
    );
  }

  Widget _buildParagraph(String paragraph, int index) {
    final isQuotation =
        paragraph.startsWith('\u201c') && paragraph.endsWith('\u201d');
    final text = Text(
      paragraph,
      textAlign: isQuotation ? TextAlign.start : TextAlign.center,
      style: isQuotation
          ? PresencePresentationTokens.quotationStyle(typography)
          : index == 0
          ? PresencePresentationTokens.primaryTellStyle(typography)
          : PresencePresentationTokens.supportingParagraphStyle(typography),
    );

    if (!isQuotation) {
      return text;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: PresencePresentationTokens.quotationInset,
      ),
      child: text,
    );
  }
}
