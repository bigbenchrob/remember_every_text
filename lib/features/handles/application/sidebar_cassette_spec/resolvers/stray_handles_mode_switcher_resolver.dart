import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../../essentials/sidebar/presentation/view_model/sidebar_cassette_card_view_model.dart';
import '../../../domain/spec_classes/handles_cassette_spec.dart';
import '../payloads/stray_handles_mode_switcher_cassette_payload.dart';

part 'stray_handles_mode_switcher_resolver.g.dart';

/// Resolver for the stray handles mode switcher cassette.
///
/// Receives explicit parameters (not specs) and produces an inert payload.
@riverpod
class StrayHandlesModeSwitcherResolver
    extends _$StrayHandlesModeSwitcherResolver {
  @override
  void build() {
    // Stateless resolver
  }

  /// Resolve filter and current mode into a sidebar cassette payload.
  Future<SidebarCassettePayload> resolve({
    required StrayHandleInvestigation investigation,
    required StrayHandleFilter? filter,
    required StrayHandleReviewMode mode,
  }) async {
    return StrayHandlesModeSwitcherCassettePayload(
      investigation: investigation,
      filter: filter,
      mode: mode,
    );
  }
}
