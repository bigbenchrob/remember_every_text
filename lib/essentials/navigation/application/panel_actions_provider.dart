import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../logging/feature_level_providers.dart' show appLoggerProvider;
import '../domain/entities/panel_stack.dart';
import '../domain/entities/view_spec.dart';
import '../domain/navigation_constants.dart';
import '../domain/sidebar_mode.dart';
import 'panels_view_state_provider.dart';
import 'sidebar_mode_provider.dart';

part 'panel_actions_provider.g.dart';

@riverpod
class PanelActions extends _$PanelActions {
  @override
  void build() {
    // Stateless navigation action boundary.
  }

  void closeActiveRightPanel() {
    final mode = ref.read(activeSidebarModeProvider);
    ref
        .read(panelsViewStateProvider(mode).notifier)
        .clear(panel: WindowPanel.right);
  }

  void showRightPanel({required SidebarMode mode, required ViewSpec spec}) {
    ref
        .read(panelsViewStateProvider(mode).notifier)
        .show(panel: WindowPanel.right, spec: spec);
  }

  void activateTab({
    required SidebarMode mode,
    required WindowPanel panel,
    required int index,
  }) {
    ref
        .read(panelsViewStateProvider(mode).notifier)
        .activate(panel: panel, index: index);
  }

  void closeTab({
    required SidebarMode mode,
    required WindowPanel panel,
    required int index,
  }) {
    ref
        .read(panelsViewStateProvider(mode).notifier)
        .closeAt(panel: panel, index: index);
  }

  void cancelParkedCenterOperation({required SidebarMode mode}) {
    ref
        .read(panelsViewStateProvider(mode).notifier)
        .clear(panel: WindowPanel.center);
  }

  void recordPanelStackBuilt({
    required WindowPanel panel,
    required PanelStack stack,
  }) {
    ref
        .read(appLoggerProvider.notifier)
        .debug(
          'Panel stack surface build',
          source: 'PanelStackSurface',
          context: {
            'panel': panel.name,
            'isEmpty': stack.isEmpty,
            'activeIndex': stack.activeIndex,
            'pageCount': stack.pages.length,
            'activeSpec': '${stack.activePage?.spec}',
          },
        );
  }
}
