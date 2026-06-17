import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../../essentials/navigation/domain/sidebar_mode.dart';
import '../../../../../essentials/sidebar/application/sidebar_action_dispatcher.dart';
import '../../../../../essentials/sidebar/domain/sidebar_action_intent.dart';

part 'message_heatmap_navigation_actions_provider.g.dart';

@riverpod
class MessageHeatmapNavigationActions
    extends _$MessageHeatmapNavigationActions {
  @override
  FutureOr<void> build() {}

  Future<void> focusMonth({DateTime? monthAnchor, int? contactId}) async {
    await _dispatch(
      HeatMapMonthFocused(contactId: contactId, monthAnchor: monthAnchor),
    );
  }

  Future<void> selectContactProjection({
    required int contactId,
    required SidebarContactProjection projection,
  }) async {
    await _dispatch(
      ContactProjectionChanged(contactId: contactId, projection: projection),
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
