import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'contact_timeline_provider.dart';
import 'global_messages_heatmap_provider.dart';

part 'message_heatmap_refresh_actions_provider.g.dart';

@riverpod
class MessageHeatmapRefreshActions extends _$MessageHeatmapRefreshActions {
  @override
  FutureOr<void> build() {}

  void refreshGlobalHeatmap() {
    ref.invalidate(globalMessagesHeatmapProvider);
  }

  void refreshContactTimeline({
    required int contactId,
    required int? filterHandleId,
  }) {
    ref.invalidate(
      contactTimelineProvider(
        contactId: contactId,
        filterHandleId: filterHandleId,
      ),
    );
  }
}
