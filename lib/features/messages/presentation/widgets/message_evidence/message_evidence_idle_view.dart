import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../../config/theme/colors/theme_colors.dart';
import 'message_evidence_header.dart';

/// Canonical message-evidence frame for an active scope with no selected target.
class MessageEvidenceIdleView extends ConsumerWidget {
  const MessageEvidenceIdleView({
    required this.headerData,
    this.content,
    this.useFixedPanelFrame = false,
    super.key,
  });

  final MessageEvidenceHeaderModel headerData;
  final Widget? content;
  final bool useFixedPanelFrame;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    return ColoredBox(
      color: colors.messagePanels.coolPanelSurface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MessageEvidenceHeader(
            data: headerData,
            useFixedPanelFrame: useFixedPanelFrame,
          ),
          Expanded(child: content ?? const SizedBox()),
        ],
      ),
    );
  }
}
