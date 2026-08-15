import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:macos_ui/macos_ui.dart';

import '../../../../config/theme/colors/theme_colors.dart';
import '../../../../config/theme/theme_typography.dart';
import '../../../handles/domain/spec_classes/handles_cassette_spec.dart';
import '../view_model/handle_investigation_presentation.dart';
import '../widgets/message_evidence/message_evidence_header.dart';
import '../widgets/message_evidence/message_evidence_idle_view.dart';

/// Truthful center-panel presentation while Unknown Sources has no target.
class HandleInvestigationIdleView extends StatelessWidget {
  const HandleInvestigationIdleView({required this.investigation, super.key});

  final StrayHandleInvestigation investigation;

  @override
  Widget build(BuildContext context) {
    final presentation = handleInvestigationPresentation(investigation);

    return MacosScaffold(
      children: [
        ContentArea(
          builder: (context, scrollController) {
            return MessageEvidenceIdleView(
              headerData: MessageEvidenceHeaderModel(
                title: presentation.panelTitle,
              ),
              content: _HandleInvestigationOrientation(
                presentation: presentation,
              ),
              useFixedPanelFrame: true,
            );
          },
        ),
      ],
    );
  }
}

class _HandleInvestigationOrientation extends ConsumerWidget {
  const _HandleInvestigationOrientation({required this.presentation});

  final HandleInvestigationPresentation presentation;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final typography = ref.watch(themeTypographyProvider);

    return Align(
      alignment: Alignment.topLeft,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(32, 20, 32, 32),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 620),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(presentation.idleExplanation, style: typography.body),
              const SizedBox(height: 12),
              Text(
                presentation.idleGuidance,
                style: typography.callout.copyWith(
                  color: colors.content.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
