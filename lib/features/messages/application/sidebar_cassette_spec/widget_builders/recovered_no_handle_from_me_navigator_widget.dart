import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:macos_ui/macos_ui.dart';

import '../../../../../config/theme/spacing/app_spacing.dart';
import '../../../../../config/theme/theme_typography.dart';
import '../../../feature_level_providers.dart';

/// Sidebar cassette content for the no-handle/from-me recovered bucket.
class RecoveredNoHandleFromMeNavigatorWidget extends ConsumerWidget {
  const RecoveredNoHandleFromMeNavigatorWidget({
    required this.cassetteIndex,
    super.key,
  });

  final int cassetteIndex;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final typography = ref.watch(themeTypographyProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Experimental slice of recovered orphaned records that are mostly outgoing and no longer retain handle linkage. Useful for inspecting the large no-handle bucket separately from the rest of recovered messages.',
          style: typography.cassetteCardSubtitle,
        ),
        const SizedBox(height: AppSpacing.sm),
        PushButton(
          controlSize: ControlSize.small,
          onPressed: () {
            ref
                .read(recoveredMessageNavigationActionsProvider.notifier)
                .openNoHandleFromMe();
          },
          child: Text(
            'Open Recovered No-Handle Messages',
            style: typography.body.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}
