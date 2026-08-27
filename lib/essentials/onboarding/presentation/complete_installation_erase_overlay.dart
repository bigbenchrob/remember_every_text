import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../config/theme/colors/theme_colors.dart';
import '../../../config/theme/theme_typography.dart';
import '../application/complete_installation_erase_action_provider.dart';
import '../domain/complete_installation_erase_presentation.dart';

class CompleteInstallationEraseOverlayHost extends ConsumerWidget {
  const CompleteInstallationEraseOverlayHost({super.key});

  static const surfaceKey = Key(
    'complete-installation-erase-operation-surface',
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final presentation = ref.watch(completeInstallationEraseActionProvider);
    if (!presentation.isVisible) {
      return const SizedBox.shrink();
    }
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final typography = ref.watch(themeTypographyProvider);
    final failed = presentation.phase == CompleteInstallationErasePhase.failed;
    return Positioned.fill(
      child: ColoredBox(
        key: surfaceKey,
        color: colors.surfaces.canvas,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Padding(
              padding: const EdgeInsets.all(48),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (failed)
                    Icon(
                      Icons.error_outline,
                      size: 44,
                      color: colors.status.error,
                    )
                  else
                    const SizedBox.square(
                      dimension: 40,
                      child: CircularProgressIndicator(strokeWidth: 3),
                    ),
                  const SizedBox(height: 24),
                  Text(
                    failed
                        ? "MessageLens couldn't erase this setup"
                        : 'Erasing this MessageLens setup',
                    style: typography.title1.copyWith(
                      color: colors.content.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    failed
                        ? presentation.failureSummary ??
                              'MessageLens stopped before it could verify a '
                                  'clean installation.'
                        : 'MessageLens is removing only data it owns. Your '
                              'Apple Messages, Contacts, and source folders '
                              'remain unchanged. The app will relaunch into '
                              'Onboarding.',
                    style: typography.body.copyWith(
                      color: colors.content.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (failed) ...[
                    const SizedBox(height: 28),
                    OutlinedButton(
                      onPressed: () {
                        ref
                            .read(
                              completeInstallationEraseActionProvider.notifier,
                            )
                            .dismissFailure(
                              occurrence: presentation.occurrence,
                            );
                      },
                      child: const Text('Return'),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
