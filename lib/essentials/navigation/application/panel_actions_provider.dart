import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/navigation_constants.dart';
import '../feature_level_providers.dart';
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
}
