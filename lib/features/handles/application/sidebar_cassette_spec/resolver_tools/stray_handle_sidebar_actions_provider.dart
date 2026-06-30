import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../../essentials/navigation/domain/sidebar_mode.dart';
import '../../../../../essentials/sidebar/application/sidebar_action_dispatcher.dart';
import '../../../../../essentials/sidebar/domain/sidebar_action_intent.dart';
import '../../../domain/spec_classes/handles_cassette_spec.dart';
import '../../../domain/utilities/handle_normalizer.dart';
import '../../read_models/stray_handle_summary.dart';

part 'stray_handle_sidebar_actions_provider.g.dart';

@riverpod
class StrayHandleSidebarActions extends _$StrayHandleSidebarActions {
  @override
  FutureOr<void> build() {}

  Future<void> openHandleLens({required int handleId}) async {
    await _dispatch(StrayHandleOpened(handleId: handleId));
  }

  Future<void> dismissHandle(StrayHandleSummary handle) async {
    await _dispatch(
      StrayHandleDismissed(
        normalizedHandle: normalizeHandleIdentifier(handle.handleValue),
      ),
    );
  }

  Future<void> restoreHandle(StrayHandleSummary handle) async {
    await _dispatch(
      StrayHandleRestored(
        normalizedHandle: normalizeHandleIdentifier(handle.handleValue),
      ),
    );
  }

  Future<void> changeMode(StrayHandleMode mode) async {
    await _dispatch(StrayHandleModeChanged(mode: _mapMode(mode)));
  }

  Future<void> changeFilter({
    required StrayHandleFilter filter,
    required int cassetteIndex,
  }) async {
    await ref
        .read(sidebarActionDispatcherProvider.notifier)
        .dispatch(
          intent: StrayHandleFilterChanged(filter: _mapFilter(filter)),
          context: SidebarActionDispatchContext(
            sidebarMode: SidebarMode.messages,
            cassetteIndex: cassetteIndex,
          ),
        );
  }

  Future<void> _dispatch(SidebarActionIntent intent) async {
    await ref
        .read(sidebarActionDispatcherProvider.notifier)
        .dispatch(
          intent: intent,
          context: const SidebarActionDispatchContext(
            sidebarMode: SidebarMode.messages,
          ),
        );
  }
}

SidebarStrayHandleMode _mapMode(StrayHandleMode mode) {
  return switch (mode) {
    StrayHandleMode.allStrays => SidebarStrayHandleMode.allStrays,
    StrayHandleMode.spamCandidates => SidebarStrayHandleMode.spamCandidates,
    StrayHandleMode.dismissed => SidebarStrayHandleMode.dismissed,
  };
}

SidebarStrayHandleFilter _mapFilter(StrayHandleFilter filter) {
  return switch (filter) {
    StrayHandleFilter.phones => SidebarStrayHandleFilter.phones,
    StrayHandleFilter.emails => SidebarStrayHandleFilter.emails,
    StrayHandleFilter.businessUrns => SidebarStrayHandleFilter.businessUrns,
  };
}
