import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../../essentials/sidebar/presentation/view_model/sidebar_cassette_card_view_model.dart';
import '../../../domain/spec_classes/handles_cassette_spec.dart';
import '../payloads/stray_handles_investigation_switcher_cassette_payload.dart';

part 'stray_handles_investigation_switcher_resolver.g.dart';

@riverpod
class StrayHandlesInvestigationSwitcherResolver
    extends _$StrayHandlesInvestigationSwitcherResolver {
  @override
  void build() {}

  Future<SidebarCassettePayload> resolve({
    required StrayHandleInvestigation selectedInvestigation,
    required int cassetteIndex,
  }) async {
    return StrayHandlesInvestigationSwitcherCassettePayload(
      selectedInvestigation: selectedInvestigation,
      cassetteIndex: cassetteIndex,
    );
  }
}
