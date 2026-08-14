import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:macos_ui/macos_ui.dart';

import '../../../config/theme/theme_typography.dart';
import '../application/presence_step_presentation.dart';
import '../domain/entities/choice_value.dart';
import 'presence_presentation_tokens.dart';

class PresenceStepPresenter extends ConsumerStatefulWidget {
  const PresenceStepPresenter({
    required this.presentation,
    required this.specialistBuilder,
    super.key,
  });

  final PresenceStepPresentation presentation;
  final WidgetBuilder specialistBuilder;

  @override
  ConsumerState<PresenceStepPresenter> createState() =>
      _PresenceStepPresenterState();
}

class _PresenceStepPresenterState extends ConsumerState<PresenceStepPresenter> {
  bool _isSubmitting = false;
  Object? _submissionError;

  Future<void> _complete(PresenceStepCompletion complete) async {
    await _submit(complete);
  }

  Future<void> _select(
    Future<void> Function(ChoiceValue value) select,
    ChoiceValue value,
  ) async {
    await _submit(() => select(value));
  }

  Future<void> _submit(Future<void> Function() operation) async {
    if (_isSubmitting) {
      return;
    }
    setState(() {
      _isSubmitting = true;
      _submissionError = null;
    });
    try {
      await operation();
    } catch (error) {
      if (mounted) {
        setState(() {
          _submissionError = error;
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final typography = ref.watch(themeTypographyProvider);
    final content = switch (widget.presentation) {
      TellStepPresentation(:final text, :final complete) =>
        _CompletionStepContent(
          text: text,
          buttonLabel: 'Complete Step',
          isSubmitting: _isSubmitting,
          complete: () => _complete(complete),
        ),
      TestStepPresentation(:final label, :final complete) =>
        _CompletionStepContent(
          text: label,
          buttonLabel: 'Complete Step',
          isSubmitting: _isSubmitting,
          complete: () => _complete(complete),
        ),
      FixedDestinationStepPresentation(:final label, :final complete) =>
        _CompletionStepContent(
          text: label,
          buttonLabel: 'Complete Step',
          isSubmitting: _isSubmitting,
          complete: () => _complete(complete),
        ),
      ChoiceStepPresentation(:final items, :final select) => _ChoiceStepContent(
        items: items,
        isSubmitting: _isSubmitting,
        select: (value) => _select(select, value),
      ),
      SpecialistStepPresentation() => widget.specialistBuilder(context),
    };

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        content,
        if (_submissionError case final error?) ...<Widget>[
          const SizedBox(height: 16),
          Text(
            'Step did not complete: $error',
            style: typography.caption,
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}

class _CompletionStepContent extends ConsumerWidget {
  const _CompletionStepContent({
    required this.text,
    required this.buttonLabel,
    required this.isSubmitting,
    required this.complete,
  });

  final String text;
  final String buttonLabel;
  final bool isSubmitting;
  final Future<void> Function() complete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final typography = ref.watch(themeTypographyProvider);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          text,
          style: PresencePresentationTokens.primaryTellStyle(typography),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        PushButton(
          controlSize: ControlSize.regular,
          onPressed: isSubmitting ? null : complete,
          child: Text(isSubmitting ? 'Checkpointing...' : buttonLabel),
        ),
      ],
    );
  }
}

class _ChoiceStepContent extends StatelessWidget {
  const _ChoiceStepContent({
    required this.items,
    required this.isSubmitting,
    required this.select,
  });

  final List<ChoicePresentationItem> items;
  final bool isSubmitting;
  final Future<void> Function(ChoiceValue value) select;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 12,
      runSpacing: 12,
      children: <Widget>[
        for (final item in items)
          PushButton(
            key: ValueKey<String>('presence-choice-${item.value.value}'),
            controlSize: ControlSize.regular,
            onPressed: isSubmitting ? null : () => select(item.value),
            child: Text(item.label),
          ),
      ],
    );
  }
}
