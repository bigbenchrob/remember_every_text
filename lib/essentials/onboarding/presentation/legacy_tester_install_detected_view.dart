import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../config/theme/colors/theme_colors.dart';
import '../../../config/theme/theme_typography.dart';

/// Minimal recognition surface for the legacy tester inspection slice.
///
/// Authorization and deletion deliberately belong to a later reviewed slice.
final class LegacyTesterInstallDetectedView extends ConsumerWidget {
  const LegacyTesterInstallDetectedView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final typography = ref.watch(themeTypographyProvider);

    return ColoredBox(
      color: colors.surfaces.canvas,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 620),
          child: Padding(
            padding: const EdgeInsets.all(48),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.history_toggle_off,
                  size: 44,
                  color: colors.content.textSecondary,
                ),
                const SizedBox(height: 24),
                Text(
                  'MessageLens found an older tester setup',
                  style: typography.title1.copyWith(
                    color: colors.content.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'MessageLens recognized the pre-source-scoped tester '
                  'database generation. It has not opened, migrated, or '
                  'removed that data.',
                  style: typography.body.copyWith(
                    color: colors.content.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
