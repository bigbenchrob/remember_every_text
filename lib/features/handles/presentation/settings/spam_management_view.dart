import 'package:flutter/cupertino.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../config/theme/colors/theme_colors.dart';
import '../../../../config/theme/theme_typography.dart';

/// Placeholder for the future handle visibility management surface.
class SpamManagementView extends ConsumerWidget {
  const SpamManagementView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final typography = ref.watch(themeTypographyProvider);

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            CupertinoIcons.wrench,
            size: 48,
            color: colors.content.textTertiary,
          ),
          const SizedBox(height: 16),
          Text(
            'Spam Management',
            style: typography.title3,
          ),
          const SizedBox(height: 8),
          Text(
            'Handle visibility controls are not part of the current graph migration surface.',
            style: typography.callout.copyWith(
              color: colors.content.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Future work: handle filtering, blocking/unblocking, and visibility statistics.',
            style: typography.caption.copyWith(
              color: colors.content.textTertiary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
