import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../../essentials/sidebar/presentation/view_model/sidebar_cassette_card_view_model.dart';
import '../payloads/messages_heatmap_cassette_payload.dart';

part 'heatmap_resolver.g.dart';

/// Resolves a messages heatmap cassette.
///
/// This resolver returns an inert payload for the calendar heatmap cassette.
///
/// ## Contract (from 00-cross-surface-spec-system.md)
///
/// - Receives explicit parameters (not specs)
/// - Returns `Future<SidebarCassettePayload>`
/// - Owns all decision-making for this cassette
/// - Does NOT construct widgets itself
@riverpod
class HeatmapResolver extends _$HeatmapResolver {
  @override
  void build() {
    // Stateless resolver
  }

  /// Resolve the messages heatmap cassette.
  Future<SidebarCassettePayload> resolve({
    required int? contactId,
    required int cassetteIndex,
  }) async {
    return MessagesHeatmapCassettePayload(
      contactId: contactId,
      role: SidebarCassetteRole.contextPrimary,
      layoutAnchor: contactId == null
          ? SidebarCassetteLayoutAnchor.preferredContentStart
          : SidebarCassetteLayoutAnchor.none,
      placementMode: SidebarBodyPlacementMode.inset,
      contentAlignment: SidebarBodyContentAlignment.loose,
      title: '',
      footerText: contactId == null ? _globalSearchHeatmapGuidance : null,
      shouldExpand: false,
    );
  }
}

const _globalSearchHeatmapGuidance =
    'Messages are shown at right, listed by date. Click a month in the '
    'heatmap to jump to that part of the archive. Enter search terms in the '
    'message list header.';
