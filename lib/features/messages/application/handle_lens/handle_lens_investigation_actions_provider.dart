import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../essentials/sidebar/feature_level_providers.dart'
    show sidebarFlowProvider;
import '../../../handles/feature_level_providers.dart'
    show handleSourceReviewActionsProvider;

part 'handle_lens_investigation_actions_provider.g.dart';

/// Coordinates Messages-owned handle-lens investigation transitions.
///
/// Handles owns dismissal meaning and persistence. This boundary advances the
/// navigation investigation only after Handles confirms that dismissal
/// succeeded. Center-panel visibility then follows from compatibility.
@riverpod
class HandleLensInvestigationActions extends _$HandleLensInvestigationActions {
  @override
  void build() {
    // Stateless action boundary.
  }

  Future<String?> dismissCurrentSource({required int handleId}) async {
    final failureMessage = await ref
        .read(handleSourceReviewActionsProvider.notifier)
        .dismissSource(handleId: handleId);
    if (failureMessage != null) {
      return failureMessage;
    }

    final flowState = ref.read(sidebarFlowProvider);
    if (flowState.effectiveSelectedHandleEvidenceId == handleId) {
      ref.read(sidebarFlowProvider.notifier).beginNewStrayHandleInvestigation();
    }
    return null;
  }
}
