import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../essentials/sidebar/feature_level_providers.dart'
    show sidebarFlowProvider;
import 'current_search_investigation_provider.dart';

part 'global_messages_investigation_actions_provider.g.dart';

/// Owns explicit transitions between global-message Search investigations.
@riverpod
class GlobalMessagesInvestigationActions
    extends _$GlobalMessagesInvestigationActions {
  @override
  void build() {
    // Stateless action boundary.
  }

  void browseMonth(DateTime? monthAnchor) {
    ref.read(currentSearchInvestigationProvider.notifier).advance();
    ref.read(sidebarFlowProvider.notifier).showGlobalTimelineAt(monthAnchor);
  }
}
