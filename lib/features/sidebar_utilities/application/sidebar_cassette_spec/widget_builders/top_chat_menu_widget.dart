import 'package:flutter/cupertino.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../../config/theme/colors/theme_colors.dart'
    show DropdownMenu, themeColorsProvider;
import '../../../../../config/theme/spacing/app_spacing.dart';
import '../../../../../config/theme/theme_typography.dart';
import '../../../../../config/theme/widgets/theme_widgets.dart';
import '../../../../../essentials/db/feature_level_providers/conversation_graph_readiness_provider.dart';
import '../../../../../essentials/navigation/domain/sidebar_mode.dart';
import '../../../domain/sidebar_utilities_constants.dart';
import '../resolver_tools/sidebar_top_menu_actions_provider.dart';

/// Top Chat Menu Widget Builder
///
/// A dumb widget that:
/// - Receives fully-decided inputs (no specs)
/// - Assembles the dropdown menu UI
/// - On user interaction, constructs a new spec and updates the rack
///
/// This widget MAY call ref.watch() for theme/styling providers.
/// This widget MAY construct specs as OUTPUT when responding to user interaction.
/// This widget MUST NOT interpret specs to decide what to render.
///
/// See: _AGENT_INSTRUCTIONS/agent-per-project/90-CROSS-SURFACE-SPEC-SYSTEMS/00-cross-surface-spec-system.md
class TopChatMenuWidget extends ConsumerWidget {
  /// The currently selected menu choice.
  final TopChatMenuChoice currentChoice;

  /// The index of this cassette in the rack.
  /// Used to update the rack without holding specs in state.
  final int cassetteIndex;

  /// The sidebar mode (messages/settings).
  final SidebarMode sidebarMode;

  const TopChatMenuWidget({
    super.key,
    required this.currentChoice,
    required this.cassetteIndex,
    required this.sidebarMode,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const choices = TopChatMenuChoice.values;

    // Theme providers - watch state for brightness rebuilds, read notifier for API
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final typography = ref.watch(themeTypographyProvider);

    // When contacts is selected but the graph is empty (e.g. first launch
    // before projection finishes), show a prompt instead of the choice label.
    final isPopulated = ref.watch(conversationGraphPopulatedProvider);
    final showPrompt =
        currentChoice == TopChatMenuChoice.contacts && !isPopulated;

    Future<void> handleSelectionChange(TopChatMenuChoice newChoice) async {
      await ref
          .read(sidebarTopMenuActionsProvider.notifier)
          .selectMessageMenuChoice(
            choice: newChoice,
            sidebarMode: sidebarMode,
            cassetteIndex: cassetteIndex,
          );
    }

    return AppThemeWidgets.dropdownMenu<TopChatMenuChoice>(
      options: choices,
      selectedOption: currentChoice,
      onSelected: handleSelectionChange,
      itemBuilder: (context, choice, {required isSelected}) {
        final isSecondaryChoice = _isSecondaryTopMenuChoice(choice);
        final sectionHeader =
            choice == TopChatMenuChoice.recoveredUnlinkedMessages
            ? Padding(
                padding: const EdgeInsets.fromLTRB(12, AppSpacing.lg, 12, 4),
                child: Text(
                  'Recovered',
                  style: typography.caption.copyWith(
                    color: colors.content.textTertiary.withValues(alpha: 0.82),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              )
            : null;
        final itemTextColor = isSelected
            ? colors.dropdownMenu(DropdownMenu.selectedText)
            : isSecondaryChoice
            ? colors.content.textSecondary.withValues(alpha: 0.88)
            : colors.content.textPrimary;
        final itemLeftInset = isSecondaryChoice ? 16.0 : 12.0;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (sectionHeader != null) sectionHeader,
            DecoratedBox(
              decoration: BoxDecoration(
                color: isSelected
                    ? colors.dropdownMenu(DropdownMenu.selectedBg)
                    : null,
              ),
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  itemLeftInset,
                  sectionHeader == null ? 10 : 8,
                  12,
                  10,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        choice.label,
                        style: typography.callout.copyWith(
                          color: itemTextColor,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                      ),
                    ),
                    if (isSelected)
                      Icon(
                        CupertinoIcons.check_mark,
                        size: 14,
                        color: colors.dropdownMenu(DropdownMenu.checkmark),
                      ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
      optionLabelBuilder: (choice) {
        if (showPrompt && choice == TopChatMenuChoice.contacts) {
          return 'Show messages from:';
        }
        return choice.label;
      },
      // Naked card wrapper provides 12px horizontal margin
      outerPadding: EdgeInsets.zero,
      // Match card internal padding: 12px left for text alignment
      triggerPadding: const EdgeInsets.only(
        left: 12.0,
        right: 16.0,
        top: 10.0,
        bottom: 10.0,
      ),
      // Typography tokens for control header hierarchy:
      // - controlValue for selected option (confident, primary)
      // - Brand-tinted chevron background for intentional feel
      selectedValueStyle: typography.controlValue,
      chevronColor: colors.dropdownMenu(DropdownMenu.chevronIcon),
      chevronBackgroundColor: colors.dropdownMenu(DropdownMenu.chevronBg),
    );
  }
}

bool _isSecondaryTopMenuChoice(TopChatMenuChoice choice) {
  return choice == TopChatMenuChoice.recoveredUnlinkedMessages ||
      choice == TopChatMenuChoice.recoveredNoHandleFromMeMessages;
}
