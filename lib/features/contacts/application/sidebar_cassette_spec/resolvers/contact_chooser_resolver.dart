import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../../essentials/sidebar/presentation/view_model/sidebar_cassette_card_view_model.dart';
import '../payloads/contact_chooser_cassette_payload.dart';

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
  /// Returns an inert payload immediately so startup/sidebar coordination does
  /// not wait on contact queries before rendering the already-known stack.
  ///
  /// Feature-owned data loading now happens at the render edge inside the
  /// chooser body, keeping the coordinator transport cheap and synchronous.
  Future<SidebarCassettePayload> resolve({
    required int? chosenContactId,
    required int cassetteIndex,
  }) async {
    return ContactChooserCassettePayload(
      chosenContactId: chosenContactId,
      cassetteIndex: cassetteIndex,
      role: SidebarCassetteRole.contextPrimary,
      placementMode: SidebarBodyPlacementMode.fullWidth,
      title: '',
      shouldExpand: true,
    );
  }
}
