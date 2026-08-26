import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../config/theme/widgets/content_plane.dart';
import '../../../../config/theme/widgets/sidebar_plane.dart';
import '../../application/panel_widget_providers.dart';
import '../../domain/sidebar_mode.dart';
import 'sidebar_parked_overlay.dart';

abstract final class WorkspaceLayout {
  static const double navigationColumnWidth = 320;
}

/// The normal application navigation surface hosted by [MacosWindow.sidebar].
class WorkspaceSidebar extends ConsumerWidget {
  const WorkspaceSidebar({super.key, required this.mode});

  final SidebarMode mode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isParked = ref.watch(isSidebarParkedProvider(mode));
    return SidebarPlane(
      showDivider: false,
      child: isParked
          ? SidebarParkedOverlay(mode: mode)
          : LeftPanelHost(mode: mode),
    );
  }
}

/// The primary content surface that continues independently of the sidebar.
class WorkspaceContent extends ConsumerWidget {
  const WorkspaceContent({super.key, required this.mode});

  final SidebarMode mode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ContentPlane(child: CenterPanelHost(mode: mode));
  }
}
