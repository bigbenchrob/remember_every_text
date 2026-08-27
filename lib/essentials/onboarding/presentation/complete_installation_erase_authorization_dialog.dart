import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../config/theme/colors/theme_colors.dart';
import '../../../config/theme/theme_typography.dart';

Future<bool> showCompleteInstallationEraseAuthorizationDialog(
  BuildContext context, {
  required Color barrierColor,
}) async {
  return await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        barrierColor: barrierColor,
        builder: (_) => const CompleteInstallationEraseAuthorizationDialog(),
      ) ??
      false;
}

class CompleteInstallationEraseAuthorizationDialog extends ConsumerWidget {
  const CompleteInstallationEraseAuthorizationDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final typography = ref.watch(themeTypographyProvider);
    return AlertDialog(
      title: const Text('Erase this MessageLens setup and start over?'),
      content: Text(
        'MessageLens will permanently delete all of its existing local data '
        'on this Mac, including imported databases, customizations, setup '
        'history, diagnostics, preferences, and any attachment copies archived '
        'by MessageLens. This cannot be undone.\n\n'
        'Your Apple Messages, Contacts, Historical Archive source folders, '
        'recovery donors, and other source data will not be changed.',
        style: typography.body.copyWith(color: colors.content.textSecondary),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Erase and Start Over'),
        ),
      ],
    );
  }
}
