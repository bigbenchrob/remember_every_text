import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../../../config/theme/colors/theme_colors.dart'
    show DropdownMenu, themeColorsProvider;
import '../../../../../../config/theme/theme_typography.dart';
import '../../../../../../config/theme/widgets/theme_widgets.dart';
import '../../../domain/spec_classes/handles_cassette_spec.dart';
import '../resolver_tools/stray_handle_sidebar_actions_provider.dart';

/// Shared app dropdown for filtering stray handles by mode.
///
/// This cassette reads and writes through the shared source-review mode state,
/// the list cassette watches to determine which handles to display.
///
/// Visually quieter than the primary segmented control, acting as a
/// secondary filter rather than primary navigation.
class StrayHandlesModeSwitcherCassette extends ConsumerWidget {
  const StrayHandlesModeSwitcherCassette({required this.mode, super.key});

  final StrayHandleReviewMode mode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final typography = ref.watch(themeTypographyProvider);
    final actions = ref.read(strayHandleSidebarActionsProvider.notifier);

    // Outer section spacing is owned by sidebar sectioning.
    // This widget keeps only its internal control composition so the filter
    // section stays compact while the stack separates it from adjacent sections.
    return Padding(
      padding: EdgeInsets.zero,
      child: AppThemeWidgets.dropdownMenu<StrayHandleReviewMode>(
        options: StrayHandleReviewMode.values,
        selectedOption: mode,
        onSelected: actions.changeMode,
        optionLabelBuilder: _modeLabel,
        leadingLabel: 'Show:',
        outerPadding: EdgeInsets.zero,
        panelMargin: const EdgeInsets.only(top: 4.0),
        triggerPadding: const EdgeInsets.only(
          left: 12.0,
          right: 16.0,
          top: 10.0,
          bottom: 10.0,
        ),
        expandToWidth: false,
        selectedValueStyle: typography.controlValue,
        chevronColor: colors.dropdownMenu(DropdownMenu.chevronIcon),
        chevronBackgroundColor: colors.dropdownMenu(DropdownMenu.chevronBg),
        leadingLabelStyle: typography.callout.copyWith(
          color: colors.content.textTertiary,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}

String _modeLabel(StrayHandleReviewMode mode) {
  return switch (mode) {
    StrayHandleReviewMode.active => 'Active',
    StrayHandleReviewMode.dismissed => 'Dismissed',
  };
}
