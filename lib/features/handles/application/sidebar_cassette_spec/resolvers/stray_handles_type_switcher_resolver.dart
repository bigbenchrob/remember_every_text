import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../../essentials/sidebar/presentation/view_model/sidebar_cassette_card_view_model.dart';
import '../../../domain/spec_classes/handles_cassette_spec.dart';
import '../payloads/stray_handles_type_switcher_cassette_payload.dart';

part 'stray_handles_type_switcher_resolver.g.dart';

/// Resolver for the stray handles type switcher cassette.
///
/// Receives explicit parameters (not specs) and produces an inert payload.
@riverpod
class StrayHandlesTypeSwitcherResolver
    extends _$StrayHandlesTypeSwitcherResolver {
  @override
  void build() {
    // Stateless resolver
  }

  /// Resolve selected filter and cassette index into a sidebar cassette payload.
  Future<SidebarCassettePayload> resolve({
    required StrayHandleFilter selectedFilter,
    required int cassetteIndex,
  }) async {
    return StrayHandlesTypeSwitcherCassettePayload(
      selectedFilter: selectedFilter,
      cassetteIndex: cassetteIndex,
    );
  }
}
