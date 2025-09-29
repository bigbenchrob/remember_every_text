// panel_switcher.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/entities/features/chats_spec.dart';
import '../domain/entities/view_spec.dart';
import '../domain/navigation_constants.dart';

part 'panels_view_state_provider.g.dart';

@riverpod
class PanelsViewState extends _$PanelsViewState {
  /// Map from WindowPanel -> current ViewSpec to render.
  @override
  Map<WindowPanel, ViewSpec?> build() => {
    WindowPanel.left: const ViewSpec.chats(ChatsSpec.recent(limit: 5)),
    WindowPanel.center: null,
    WindowPanel.right: null,
  };

  void show({required WindowPanel panel, required ViewSpec spec}) {
    state = {...state, panel: spec};
  }

  void clear(WindowPanel panel) {
    state = {...state, panel: null};
  }
}

// /// Convenience family to watch a single panel.
// @riverpod
// ViewSpec? panelViewFor(PanelViewForRef ref, WindowPanel panel) {
//   return ref.watch(panelViewsNotifierProvider)[panel];
// }
