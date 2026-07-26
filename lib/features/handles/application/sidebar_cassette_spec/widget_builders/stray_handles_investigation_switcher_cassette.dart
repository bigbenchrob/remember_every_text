import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../../../config/theme/widgets/segmented/app_segmented_mode_control.dart';
import '../../../domain/spec_classes/handles_cassette_spec.dart';
import '../resolver_tools/stray_handle_sidebar_actions_provider.dart';

class StrayHandlesInvestigationSwitcherCassette extends ConsumerWidget {
  const StrayHandlesInvestigationSwitcherCassette({
    required this.selectedInvestigation,
    required this.cassetteIndex,
    super.key,
  });

  final StrayHandleInvestigation selectedInvestigation;
  final int cassetteIndex;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final actions = ref.read(strayHandleSidebarActionsProvider.notifier);

    return AppSegmentedModeControl<StrayHandleInvestigation>(
      options: StrayHandleInvestigation.values,
      selectedOption: selectedInvestigation,
      onSelected: (investigation) {
        actions.changeInvestigation(
          investigation: investigation,
          cassetteIndex: cassetteIndex,
        );
      },
      labelBuilder: (investigation) {
        return switch (investigation) {
          StrayHandleInvestigation.identifySources => 'Identify',
          StrayHandleInvestigation.numericSenderIds => 'Numeric IDs',
        };
      },
    );
  }
}
