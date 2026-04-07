import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../../essentials/sidebar/presentation/view_model/sidebar_cassette_card_view_model.dart';
import '../payloads/contact_selection_control_cassette_payload.dart';

part 'contact_selection_control_resolver.g.dart';

/// Resolves the "back to picker" selection control.
///
/// The selection control is **navigation, not content and not identity**.
/// It uses a canonical navigation payload — a full-bleed type
/// purpose-built for "back to previous state" navigation affordances.
/// No card chrome, no shadow, no contact name.
///
/// ## Contract (from 00-cross-surface-spec-system.md)
///
/// - Receives explicit parameters (not specs)
/// - Returns `Future<SidebarCassettePayload>`
/// - Returns inert semantic payload only
@riverpod
class ContactSelectionControlResolver
    extends _$ContactSelectionControlResolver {
  @override
  void build() {
    // Stateless resolver
  }

  /// Resolve the contact selection control cassette.
  Future<SidebarCassettePayload> resolve({
    required int contactId,
    required int cassetteIndex,
  }) async {
    return ContactSelectionControlCassettePayload(
      contactId: contactId,
      cassetteIndex: cassetteIndex,
    );
  }
}
