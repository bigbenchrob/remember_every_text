import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../../essentials/sidebar/presentation/view_model/sidebar_cassette_card_view_model.dart';
import '../payloads/contact_chooser_cassette_payload.dart';
import '../resolver_tools/contact_chooser_snapshot_provider.dart';

part 'contact_chooser_resolver.g.dart';

/// Resolves a contact chooser cassette.
///
/// This resolver determines the correct content for the contact chooser
/// cassette by:
/// 1. Fetching contact count from the repository
/// 2. Using [determinePickerMode] to decide flat vs grouped display
/// 3. Returning an inert payload that the render edge maps to feature widgets
///
/// ## Contract (from 00-cross-surface-spec-system.md)
///
/// - Receives explicit parameters (not specs)
/// - Returns `Future<SidebarCassettePayload>`
/// - Determines which picker variant should render
/// - Owns all decision-making for this cassette
///
/// Resolvers MUST NOT:
/// - Accept a spec object
/// - Read a spec from shared state
/// - Return widgets, builders, or partial results
@riverpod
class ContactChooserResolver extends _$ContactChooserResolver {
  @override
  void build() {
    // Stateless resolver
  }

  /// Resolve the contact chooser cassette.
  ///
  /// Returns the current chooser snapshot state as an inert payload.
  ///
  /// The shared sidebar layer resolves cassettes independently, so chooser
  /// readiness changes propagate through the shared payload path without
  /// requiring a feature-local render-edge upgrade.
  Future<SidebarCassettePayload> resolve({
    required int? chosenContactId,
    required int cassetteIndex,
    required ContactChooserSnapshot snapshot,
  }) async {
    return ContactChooserCassettePayload(
      loadState: snapshot.loadState,
      pickerMode: snapshot.pickerMode,
      pickerFilterMode: snapshot.pickerFilterMode,
      filteredSections: snapshot.filteredSections,
      chosenContactId: chosenContactId,
      cassetteIndex: cassetteIndex,
      role: SidebarCassetteRole.contextPrimary,
      placementMode: SidebarBodyPlacementMode.fullWidth,
      title: '',
      shouldExpand: true,
    );
  }
}
