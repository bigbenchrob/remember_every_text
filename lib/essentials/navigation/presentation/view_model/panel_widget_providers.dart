import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../application/panels_view_state_provider.dart';
import '../../domain/navigation_constants.dart';
import './panel_coordinator_provider.dart';

part 'panel_widget_providers.g.dart';

/// Widget provider for left panel
@riverpod
Widget leftPanelWidget(Ref ref) {
  // Watch both the coordinator and the state to trigger rebuilds
  ref.watch(panelsViewStateProvider);
  return ref
      .read(panelCoordinatorProvider.notifier)
      .buildPanelWidget(WindowPanel.left);
}

/// Widget provider for center panel
@riverpod
Widget centerPanelWidget(Ref ref) {
  // Watch both the coordinator and the state to trigger rebuilds
  ref.watch(panelsViewStateProvider);
  return ref
      .read(panelCoordinatorProvider.notifier)
      .buildPanelWidget(WindowPanel.center);
}

/// Widget provider for right panel
@riverpod
Widget rightPanelWidget(Ref ref) {
  // Watch both the coordinator and the state to trigger rebuilds
  ref.watch(panelsViewStateProvider);
  return ref
      .read(panelCoordinatorProvider.notifier)
      .buildPanelWidget(WindowPanel.right);
}
