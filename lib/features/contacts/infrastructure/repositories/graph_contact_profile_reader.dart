import '../../../../essentials/db/infrastructure/data_sources/local/conversation_graph/conversation_graph_database.dart';
import '../../../../essentials/db/infrastructure/data_sources/local/overlay/overlay_database.dart';
import '../../../handles/application/read_models/handle_identity.dart';
import '../../application/display_identity/display_identity.dart';
import '../../application/read_models/contact_profile_reader.dart';
import '../../application/read_models/contact_profile_summary.dart';
import '../../application/read_models/contact_summary_identity.dart';
import '../../domain/overlay_virtual_contact.dart';
import '../../domain/participant_origin.dart';
import 'participant_merge_utils.dart';

class GraphContactProfileReader implements ContactProfileReader {
  const GraphContactProfileReader({
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
  Future<ContactProfileSummary?> readContactProfile({
    required int contactId,
    required Iterable<OverlayVirtualContact> virtualContacts,
  }) async {
    final graphSummary = await _readGraphContactProfile(contactId: contactId);
    if (graphSummary != null) {
      return graphSummary;
    }

    for (final virtualContact in virtualContacts) {
      if (virtualContact.id == contactId) {
        final overrides = await _overlayDb.getOverridesForVirtualParticipant(
          contactId,
        );
        final isSelf = overrides.any((override) {
          return handleIdentityKeyVariants(override.handleId).any((
            candidateId,
          ) {
            return _displayIdentityResolver
                    .identitiesByHandleId[candidateId]
                    ?.isSelf ==
                true;
          });
        });
        return ContactProfileSummary(
          contactId: contactId,
          displayName: isSelf
              ? selfParticipantDisplayLabel
              : virtualContact.displayName,
          origin: ParticipantOrigin.overlayVirtual,
        );
      }
    }

    return null;
  }

  Future<ContactProfileSummary?> _readGraphContactProfile({
    required int contactId,
  }) async {
    final graphContactIds = <int>{contactId};
    graphContactIds.addAll(await _candidateGraphContactIds(contactId));

    for (final graphContactId in graphContactIds) {
      final rows = await _graphDb.selectRows(
        '''
        SELECT contact_id, display_name
        FROM contacts
        WHERE contact_id = ?
        LIMIT 1
        ''',
        <Object?>[graphContactId],
      );
      if (rows.isEmpty) {
        continue;
      }

      final row = rows.single;
      final displayName = (row['display_name'] as String?)?.trim();
      if (displayName == null ||
          displayName.isEmpty ||
          isPlaceholderDisplayName(displayName)) {
        continue;
      }

      final overrides = await participantOverridesById(_overlayDb);
      final override = participantOverrideForContactId(
        participantOverrides: overrides,
        contactId: graphContactId,
      );
      final overrideLabel = override?.displayNameOverride?.trim();

      return ContactProfileSummary(
        contactId: graphContactId,
        displayName: _displayIdentityResolver
            .resolveContact(graphContactId)
            .primaryLabel,
        origin: overrideLabel != null && overrideLabel.isNotEmpty
            ? ParticipantOrigin.overlayOverride
            : ParticipantOrigin.working,
      );
    }

    return null;
  }

  Future<List<int>> _candidateGraphContactIds(int contactId) async {
    final rows = await _graphDb.selectRows('''
      SELECT contact_id
      FROM contacts
      ORDER BY contact_id ASC
      ''');
    return [
      for (final row in rows)
        if (row['contact_id'] case final int id)
          if (contactIdentityIdsMatch(id, contactId)) id,
    ];
  }
}
