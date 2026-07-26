import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../../essentials/sidebar/presentation/view_model/sidebar_cassette_card_view_model.dart';
import '../../../domain/spec_classes/handles_cassette_spec.dart';
import '../payloads/stray_handles_review_cassette_payload.dart';

part 'stray_handles_review_resolver.g.dart';

/// Resolver for the unified stray handles review list cassette.
///
/// Receives explicit parameters (not specs) and produces an inert payload.
@riverpod
class StrayHandlesReviewResolver extends _$StrayHandlesReviewResolver {
  @override
  void build() {
    // Stateless resolver
  }

  /// Resolve filter and mode into a sidebar cassette payload.
  Future<SidebarCassettePayload> resolve({
    required StrayHandleInvestigation investigation,
    required StrayHandleFilter? filter,
    required StrayHandleReviewMode mode,
  }) async {
    return StrayHandlesReviewCassettePayload(
      investigation: investigation,
      filter: filter,
      mode: mode,
      role: SidebarCassetteRole.contextPrimary,
      placementMode: SidebarBodyPlacementMode.inset,
      contentAlignment: SidebarBodyContentAlignment.fill,
      title: '',
      layoutStyle: SidebarCardLayoutStyle.controlAligned,
      shouldExpand: true,
    );
  }
}
