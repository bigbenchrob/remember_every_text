import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../../config/theme/colors/theme_colors.dart';
import '../../../../../config/theme/theme_typography.dart';

class MessageEvidenceBadgeStrip extends StatelessWidget {
  const MessageEvidenceBadgeStrip({required this.labels, super.key});

  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    final visibleLabels = labels
        .where((label) => label.trim().isNotEmpty)
        .toList(growable: false);
    if (visibleLabels.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 5, bottom: 6),
      child: Wrap(
        spacing: 6,
        runSpacing: 6,
        children: [
          for (final label in visibleLabels) MessageEvidenceBadge(label: label),
        ],
      ),
    );
  }
}

class MessageEvidenceBadge extends ConsumerWidget {
  const MessageEvidenceBadge({required this.label, super.key});

  final String label;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final typography = ref.watch(themeTypographyProvider);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surfaces.control,
        border: Border.all(color: colors.lines.borderSubtle),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        child: Text(label, style: typography.caption),
      ),
    );
  }
}
