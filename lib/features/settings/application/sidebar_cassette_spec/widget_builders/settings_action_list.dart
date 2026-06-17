import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../../config/theme/colors/theme_colors.dart';
import '../../../../../config/theme/theme_typography.dart';
import '../../../../../essentials/sidebar/domain/sidebar_action_intent.dart';
import '../actions/settings_action_list_actions_provider.dart';

class SettingsActionList extends ConsumerWidget {
  const SettingsActionList({
    super.key,
    required this.actions,
    required this.cassetteIndex,
  });

  final List<SidebarActionDescriptor> actions;
  final int cassetteIndex;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final typography = ref.watch(themeTypographyProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var index = 0; index < actions.length; index++) ...[
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () async {
              final action = actions[index];

              await ref
                  .read(settingsActionListActionsProvider.notifier)
                  .selectAction(action: action, cassetteIndex: cassetteIndex);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Text(
                actions[index].label,
                style: typography.controlValue.copyWith(
                  color: _actionColor(colors: colors, action: actions[index]),
                ),
              ),
            ),
          ),
          if (index < actions.length - 1)
            SizedBox(
              height: 0.5,
              child: ColoredBox(color: colors.lines.borderSubtle),
            ),
        ],
      ],
    );
  }

  Color _actionColor({
    required ThemeColors colors,
    required SidebarActionDescriptor action,
  }) {
    return switch (action.tone) {
      SidebarActionTone.neutral => colors.content.textPrimary,
      SidebarActionTone.primary => colors.accents.primary,
      SidebarActionTone.destructive => colors.buttons.destructiveForeground,
    };
  }
}
