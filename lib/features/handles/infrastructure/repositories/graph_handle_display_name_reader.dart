import '../../../../essentials/db/infrastructure/data_sources/local/conversation_graph/conversation_graph_database.dart';
import '../../../../essentials/db/infrastructure/data_sources/local/overlay/overlay_database.dart';
import '../../../contacts/feature_level_providers.dart'
    show DisplayIdentityResolver;
import '../../application/read_models/handle_display_name_reader.dart';

class GraphHandleDisplayNameReader implements HandleDisplayNameReader {
  const GraphHandleDisplayNameReader({
    required ConversationGraphDatabase graphDb,
    required OverlayDatabase overlayDb,
    required DisplayIdentityResolver displayIdentityResolver,
  }) : _graphDb = graphDb,
       _overlayDb = overlayDb,
       _displayIdentityResolver = displayIdentityResolver;

  final ConversationGraphDatabase _graphDb;
  final OverlayDatabase _overlayDb;
  final DisplayIdentityResolver _displayIdentityResolver;

  @override
  Future<String> readHandleDisplayName({required int handleId}) async {
    final override = await _overlayDb.getHandleOverride(handleId);
    if (override != null) {
      final virtualParticipantId = override.virtualParticipantId;
      if (virtualParticipantId != null) {
        final virtualParticipant = await _overlayDb.getVirtualParticipant(
          virtualParticipantId,
        );
        final displayName = virtualParticipant?.displayName.trim();
        if (displayName != null && displayName.isNotEmpty) {
          return displayName;
        }
      }

      final participantId = override.participantId;
      if (participantId != null) {
        final identity = _displayIdentityResolver.resolveContact(participantId);
        if (identity.isKnownContact) {
          return identity.primaryLabel;
        }
      }
    }

    final graphIdentity =
        _displayIdentityResolver.identitiesByHandleId[handleId];
    if (graphIdentity != null) {
      return graphIdentity.primaryLabel;
    }

    final graphRows = await _graphDb.selectRows(
      '''
      SELECT
        COALESCE(ch.display_handle, h.id) AS display_value
      FROM handles h
      LEFT JOIN handle_aliases ha ON ha.handle_ss_id = h.ss_id
      LEFT JOIN canonical_handles ch
        ON ch.canonical_handle_ss_id =
          COALESCE(ha.canonical_handle_ss_id, h.ss_id)
      WHERE h.ss_id = ?
         OR ch.canonical_handle_ss_id = ?
      LIMIT 1
      ''',
      <Object?>[handleId, handleId],
    );

    if (graphRows.isNotEmpty) {
      final displayValue = (graphRows.single['display_value'] as String?)
          ?.trim();
      if (displayValue != null && displayValue.isNotEmpty) {
        return displayValue;
      }
    }

    return 'Handle #$handleId';
  }
}
