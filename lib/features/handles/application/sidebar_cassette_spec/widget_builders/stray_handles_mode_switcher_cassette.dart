import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../../../config/theme/colors/theme_colors.dart'
    show DropdownMenu, themeColorsProvider;
import '../../../../../../config/theme/theme_typography.dart';
import '../../../../../../config/theme/widgets/theme_widgets.dart';
import '../../../domain/spec_classes/handles_cassette_spec.dart';
import '../../state/stray_handle_mode_provider.dart';

/// Shared app dropdown for filtering stray handles by mode.
///
/// This cassette reads and writes to [strayHandleModeSettingProvider], which
/// the list cassette watches to determine which handles to display.
///
/// Visually quieter than the primary segmented control, acting as a
/// secondary filter rather than primary navigation.
class StrayHandlesModeSwitcherCassette extends ConsumerWidget {
  const StrayHandlesModeSwitcherCassette({required this.filter, super.key});

  final StrayHandleFilter filter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final typography = ref.watch(themeTypographyProvider);
    final currentMode = ref.watch(strayHandleModeSettingProvider);

    // Spacing constants:
    // - 20pt from segmented control above (contributes with type switcher bottom)
    // - 6pt between "Show:" label and popup (horizontal)
    // - 24pt to section header below (16pt here + 4pt wrapper + 4pt from review card)
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: AppThemeWidgets.dropdownMenu<StrayHandleMode>(
        options: StrayHandleMode.values,
        selectedOption: currentMode,
        onSelected: (mode) {
          ref.read(strayHandleModeSettingProvider.notifier).setMode(mode);
        },
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

String _modeLabel(StrayHandleMode mode) {
  return switch (mode) {
    StrayHandleMode.allStrays => 'All',
    StrayHandleMode.spamCandidates => 'Spam',
    StrayHandleMode.dismissed => 'Dismissed',
  };
}
