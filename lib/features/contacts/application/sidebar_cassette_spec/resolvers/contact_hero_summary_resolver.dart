import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../../essentials/sidebar/presentation/view_model/sidebar_cassette_card_view_model.dart';
import '../payloads/contact_hero_summary_cassette_payload.dart';

part 'contact_hero_summary_resolver.g.dart';

/// Resolves a contact hero summary cassette.
///
/// This resolver produces an inert payload for displaying detailed contact
/// information.
///
/// ## Contract (from 00-cross-surface-spec-system.md)
///
/// - Receives explicit parameters (not specs)
/// - Returns `Future<SidebarCassettePayload>`
/// - Returns inert semantic payload only
@riverpod
class ContactHeroSummaryResolver extends _$ContactHeroSummaryResolver {
  @override
  void build() {
    // Stateless resolver
  }

  /// Resolve the contact hero summary cassette.
  Future<SidebarCassettePayload> resolve({
    required int contactId,
    required int cassetteIndex,
  }) async {
    return ContactHeroSummaryCassettePayload(
      contactId: contactId,
      cassetteIndex: cassetteIndex,
    );
  }
}
