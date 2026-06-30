import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../../essentials/navigation/domain/sidebar_mode.dart';
import '../../../../../essentials/sidebar/presentation/view_model/sidebar_cassette_card_view_model.dart';
import '../../../domain/sidebar_utilities_constants.dart';
import '../payloads/top_chat_menu_cassette_payload.dart';

part 'top_chat_menu_resolver.g.dart';

/// Top Chat Menu Resolver
///
/// This resolver implements the cross-surface spec system contract:
///
/// - Receives explicit parameters (NOT a spec)
/// - Returns `Future<SidebarCassettePayload>`
/// - Owns all decision-making for this cassette
///
/// The resolver MUST NOT:
/// - Accept a spec object
/// - Read a spec from shared state
/// - Return widgets, builders, or partial results
///
/// See: _AGENT_INSTRUCTIONS/agent-per-project/90-CROSS-SURFACE-SPEC-SYSTEMS/00-cross-surface-spec-system.md
@riverpod
class TopChatMenuResolver extends _$TopChatMenuResolver {
  @override
  void build() {
    // Stateless resolver; called by the sidebar utility coordinator.
  }

  /// Resolve the top chat menu cassette.
  ///
  /// Parameters are explicit and fully-decided - no spec interpretation here.
  Future<SidebarCassettePayload> resolve({
    required TopChatMenuChoice currentChoice,
    required int cassetteIndex,
    required SidebarMode sidebarMode,
  }) async {
    return TopChatMenuCassettePayload(
      currentChoice: currentChoice,
      cassetteIndex: cassetteIndex,
      sidebarMode: sidebarMode,
    );
  }
}
