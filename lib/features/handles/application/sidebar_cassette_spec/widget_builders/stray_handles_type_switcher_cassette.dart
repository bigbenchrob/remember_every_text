import 'package:flutter/cupertino.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../../../config/theme/colors/theme_colors.dart';
import '../../../../../../config/theme/theme_typography.dart';
import '../../../../../../essentials/navigation/domain/sidebar_mode.dart';
import '../../../../../../essentials/sidebar/application/sidebar_action_dispatcher.dart';
import '../../../../../../essentials/sidebar/domain/sidebar_action_intent.dart';
import '../../../../../../essentials/sidebar/feature_level_providers.dart';
import '../../../domain/spec_classes/handles_cassette_spec.dart';

/// A segmented control for selecting which type of stray handles to review:
/// Phone numbers, Email addresses, or Business URNs.
///
/// This cassette sits between the menu selection and the mode switcher,
/// allowing the user to choose which handle type to triage.
class StrayHandlesTypeSwitcherCassette extends ConsumerWidget {
  const StrayHandlesTypeSwitcherCassette({
    required this.selectedFilter,
    required this.cassetteIndex,
    super.key,
  });

  final StrayHandleFilter selectedFilter;
  final int cassetteIndex;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final typography = ref.watch(themeTypographyProvider);
    final dispatcher = ref.read(sidebarActionDispatcherProvider.notifier);

    Future<void> handleFilterChange(StrayHandleFilter newFilter) async {
      await dispatcher.dispatch(
        intent: StrayHandleFilterChanged(filter: _mapFilter(newFilter)),
        context: SidebarActionDispatchContext(
          sidebarMode: SidebarMode.messages,
          cassetteIndex: cassetteIndex,
        ),
      );
    }

    // Spacing constants:
    // - 12pt from top dropdown (8pt here + 4pt from naked wrapper)
    // - 20pt to "Show:" below (12pt here + 4pt wrapper + 4pt mode switcher wrapper)
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 12),
      child: CupertinoSegmentedControl<StrayHandleFilter>(
        groupValue: selectedFilter,
        onValueChanged: handleFilterChange,
        padding: const EdgeInsets.all(2),
        // Use neutral gray for unselected border/separator
        unselectedColor: colors.surfaces.surface,
        borderColor: colors.lines.border,
        pressedColor: colors.surfaces.hover,
        children: {
          StrayHandleFilter.phones: _SegmentContent(
            label: 'Phone #',
            isSelected: selectedFilter == StrayHandleFilter.phones,
            colors: colors,
            typography: typography,
          ),
          StrayHandleFilter.emails: _SegmentContent(
            label: 'Email',
            isSelected: selectedFilter == StrayHandleFilter.emails,
            colors: colors,
            typography: typography,
          ),
          StrayHandleFilter.businessUrns: _SegmentContent(
            label: 'Business',
            isSelected: selectedFilter == StrayHandleFilter.businessUrns,
            colors: colors,
            typography: typography,
          ),
        },
      ),
    );
  }
}

SidebarStrayHandleFilter _mapFilter(StrayHandleFilter filter) {
  return switch (filter) {
    StrayHandleFilter.phones => SidebarStrayHandleFilter.phones,
    StrayHandleFilter.emails => SidebarStrayHandleFilter.emails,
    StrayHandleFilter.businessUrns => SidebarStrayHandleFilter.businessUrns,
  };
}

class _SegmentContent extends StatelessWidget {
  const _SegmentContent({
    required this.label,
    required this.isSelected,
    required this.colors,
    required this.typography,
  });

  final String label;
  final bool isSelected;
  final ThemeColors colors;
  final ThemeTypography typography;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Text(
        label,
        style: typography.caption.copyWith(
          // Selected segment has blue background, so use white text
          // Unselected uses secondary text color
          color: isSelected
              ? CupertinoColors.white
              : colors.content.textSecondary,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          fontSize: 12,
        ),
      ),
    );
  }
}
