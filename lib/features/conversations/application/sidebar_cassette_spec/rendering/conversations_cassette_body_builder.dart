import 'package:flutter/widgets.dart';

import '../../../../../essentials/sidebar/presentation/view_model/sidebar_cassette_card_view_model.dart';
import '../payloads/conversation_signatures_cassette_payload.dart';
import '../widget_builders/conversation_signatures_widget.dart';

/// Builds feature-owned sidebar cassette bodies from inert Conversation payloads.
Widget buildPlacementGovernedCassetteBody({
  required PlacementGovernedSidebarCassettePayload payload,
}) {
  return switch (payload) {
    ConversationSignaturesCassettePayload() =>
      const ConversationSignaturesWidget(),
    PlacementGovernedSidebarCassettePayload() => throw UnsupportedError(
      'Unhandled conversations cassette payload type: ${payload.runtimeType}',
    ),
  };
}
