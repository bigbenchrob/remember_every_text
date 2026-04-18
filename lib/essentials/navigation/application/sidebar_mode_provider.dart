import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../sidebar/application/cassette_rack_state_provider.dart';
import '../domain/sidebar_mode.dart';

part 'sidebar_mode_provider.g.dart';

/// Controls the active sidebar mode (Messages vs Settings).
@riverpod
class ActiveSidebarMode extends _$ActiveSidebarMode {
  @override
  SidebarMode build() {
    return SidebarMode.messages;
  }

  void setMode(SidebarMode mode) {
    final previousMode = state;
    if (previousMode == mode) {
      return;
    }

    if (previousMode == SidebarMode.settings) {
      ref
          .read(cassetteRackStateProvider(SidebarMode.settings).notifier)
          .resetToInitial();
    }

    state = mode;
  }
}
