import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../config/theme/colors/theme_colors.dart';
import '../../../config/theme/theme_typography.dart';
import '../application/legacy_tester_install_deletion_action_provider.dart';
import '../application/legacy_tester_install_deletion_presentation_provider.dart';
import '../domain/legacy_tester_install_deletion_presentation.dart';

final class LegacyTesterInstallDetectedView extends ConsumerWidget {
  const LegacyTesterInstallDetectedView({required this.onQuit, super.key});

  static const deleteButtonKey = Key('legacy-tester-delete-button');
  static const cancelButtonKey = Key('legacy-tester-cancel-button');
  static const retryButtonKey = Key('legacy-tester-retry-button');
  static const operationSurfaceKey = Key(
    'legacy-tester-deletion-operation-surface',
  );

  final VoidCallback onQuit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final presentation = ref.watch(
      legacyTesterInstallDeletionPresentationControllerProvider,
    );
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final typography = ref.watch(themeTypographyProvider);

    final content = switch (presentation.phase) {
      LegacyTesterInstallDeletionPhase.awaitingAuthorization => (
        icon: Icons.history_toggle_off,
        title: 'This is data from an older MessageLens test version',
        body:
            'This version of MessageLens needs to start with a clean setup. '
            'I can remove the old MessageLens data on this Mac and start '
            'again.',
        safety: 'Your Apple Messages and Contacts will not be changed.',
      ),
      LegacyTesterInstallDeletionPhase.cancelled => (
        icon: Icons.info_outline,
        title: 'No data was changed',
        body:
            'MessageLens cannot continue while the older test setup remains '
            'in place.',
        safety: 'You can quit MessageLens and decide later.',
      ),
      LegacyTesterInstallDeletionPhase.preparing ||
      LegacyTesterInstallDeletionPhase.deleting => (
        icon: null,
        title: 'Removing the old MessageLens test setup',
        body:
            'MessageLens is removing only data created by the older test '
            'version.',
        safety:
            'Your Apple Messages, Contacts, and source folders remain '
            'unchanged.',
      ),
      LegacyTesterInstallDeletionPhase.handingOff => (
        icon: null,
        title: 'Starting Onboarding',
        body: 'The clean MessageLens setup has been verified.',
        safety: 'MessageLens is relaunching now.',
      ),
      LegacyTesterInstallDeletionPhase.failed => (
        icon: Icons.error_outline,
        title: "MessageLens couldn't remove the old test setup",
        body:
            presentation.failure?.summary ??
            'MessageLens stopped before it could verify a clean setup.',
        safety:
            'Your Apple Messages, Contacts, and source folders were not '
            'targeted.',
      ),
    };
    final isBusy = switch (presentation.phase) {
      LegacyTesterInstallDeletionPhase.preparing ||
      LegacyTesterInstallDeletionPhase.deleting ||
      LegacyTesterInstallDeletionPhase.handingOff => true,
      _ => false,
    };

    return ColoredBox(
      key: operationSurfaceKey,
      color: colors.surfaces.canvas,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 620),
          child: Padding(
            padding: const EdgeInsets.all(48),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isBusy)
                  const SizedBox.square(
                    dimension: 40,
                    child: CircularProgressIndicator(strokeWidth: 3),
                  )
                else
                  Icon(
                    content.icon,
                    size: 44,
                    color:
                        presentation.phase ==
                            LegacyTesterInstallDeletionPhase.failed
                        ? colors.status.error
                        : colors.content.textSecondary,
                  ),
                const SizedBox(height: 24),
                Text(
                  content.title,
                  style: typography.title1.copyWith(
                    color: colors.content.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  content.body,
                  style: typography.body.copyWith(
                    color: colors.content.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  content.safety,
                  style: typography.body.copyWith(
                    color: colors.content.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (presentation.phase ==
                    LegacyTesterInstallDeletionPhase.awaitingAuthorization) ...[
                  const SizedBox(height: 28),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    alignment: WrapAlignment.center,
                    children: [
                      OutlinedButton(
                        key: cancelButtonKey,
                        onPressed: () {
                          ref
                              .read(legacyTesterInstallDeletionActionProvider)
                              .cancel();
                        },
                        child: const Text('Cancel'),
                      ),
                      FilledButton(
                        key: deleteButtonKey,
                        onPressed: () async {
                          await ref
                              .read(legacyTesterInstallDeletionActionProvider)
                              .confirmDeletion();
                        },
                        child: const Text('Delete Old Data and Continue'),
                      ),
                    ],
                  ),
                ],
                if (presentation.phase ==
                    LegacyTesterInstallDeletionPhase.cancelled) ...[
                  const SizedBox(height: 28),
                  OutlinedButton(
                    onPressed: onQuit,
                    child: const Text('Quit MessageLens'),
                  ),
                ],
                if (presentation.phase ==
                    LegacyTesterInstallDeletionPhase.failed) ...[
                  const SizedBox(height: 28),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    alignment: WrapAlignment.center,
                    children: [
                      if (presentation.failure?.canRetry == true)
                        FilledButton(
                          key: retryButtonKey,
                          onPressed: () async {
                            await ref
                                .read(legacyTesterInstallDeletionActionProvider)
                                .retry(occurrence: presentation.occurrence);
                          },
                          child: const Text('Try Again'),
                        ),
                      OutlinedButton(
                        onPressed: onQuit,
                        child: const Text('Quit MessageLens'),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
