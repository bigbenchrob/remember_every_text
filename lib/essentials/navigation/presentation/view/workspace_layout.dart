import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../config/theme/widgets/content_plane.dart';
import '../../../../config/theme/widgets/layout/cross_column_track_plan.dart';
import '../../../../config/theme/widgets/sidebar_plane.dart';
import '../../../../features/sidebar_utilities/domain/sidebar_utilities_constants.dart';
import '../../../sidebar/application/sidebar_flow_state_provider.dart';
import '../../application/panel_widget_providers.dart';
import '../../domain/sidebar_mode.dart';
import 'sidebar_parked_overlay.dart';

class WorkspaceLayout extends ConsumerWidget {
  const WorkspaceLayout({super.key, required this.mode});

  final SidebarMode mode;

  static const double _navigationColumnWidth = 320;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isParked = ref.watch(isSidebarParkedProvider(mode));
    final useSearchTrackPlan =
        mode == SidebarMode.messages &&
        ref.watch(sidebarFlowProvider).topMenuChoice ==
            TopChatMenuChoice.searchAllMessages;

    final workspace = Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SidebarPlane(
          width: _navigationColumnWidth,
          child: isParked
              ? SidebarParkedOverlay(mode: mode)
              : LeftPanelHost(mode: mode),
        ),
        Expanded(
          child: ContentPlane(child: CenterPanelHost(mode: mode)),
        ),
      ],
    );

    if (!useSearchTrackPlan) {
      return workspace;
    }

    return ResolvedTrackPlanScope(plan: searchPageTrackPlan, child: workspace);
  }
}
