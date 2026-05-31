import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../domain/message_evidence/message_evidence_scope.dart';

part 'current_visible_month_provider.g.dart';

/// Current visible month for a message evidence timeline scope.
///
/// The shared message evidence timeline publishes this value from its
/// full-scope skeleton. Sidebar heatmaps read it to stay coordinated without
/// owning message lookup or scroll semantics.
@riverpod
class CurrentVisibleMonthForScope extends _$CurrentVisibleMonthForScope {
  @override
  String? build({required MessageEvidenceScope scope}) {
    return null;
  }

  void setVisibleMonthKey(String? monthKey) {
    if (state == monthKey) {
      return;
    }

    state = monthKey;
  }
}
