import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../../essentials/sidebar/presentation/view_model/sidebar_cassette_card_view_model.dart';
import '../../../domain/spec_classes/handles_cassette_spec.dart';
import '../widget_builders/stray_handles_review_cassette.dart';

part 'stray_handles_review_resolver.g.dart';

/// Resolver for the unified stray handles review list cassette.
///
/// Receives explicit parameters (not specs) and produces a view model.
/// Widget construction is inline here since it's simple.
@riverpod
class StrayHandlesReviewResolver extends _$StrayHandlesReviewResolver {
  @override
  void build() {
    // Stateless resolver
  }

  /// Resolve filter and mode into a sidebar cassette view model.
  Future<SidebarCassetteCardViewModel> resolve({
    required StrayHandleFilter filter,
    required StrayHandleMode mode,
  }) async {
    return SidebarCassetteCardViewModel.featureComplex(
      role: SidebarCassetteRole.contextPrimary,
      placementMode: SidebarBodyPlacementMode.inset,
      contentAlignment: SidebarBodyContentAlignment.fill,
      title: '',
      layoutStyle: SidebarCardLayoutStyle.controlAligned,
      shouldExpand: true,
      child: StrayHandlesReviewCassette(filter: filter, mode: mode),
    );
  }
}
