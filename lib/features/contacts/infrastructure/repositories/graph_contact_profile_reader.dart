import '../../../../essentials/conversation_graph/domain/identity_key_bridge.dart';
import '../../../../essentials/db/infrastructure/data_sources/local/conversation_graph/conversation_graph_database.dart';
import '../../../../essentials/db/infrastructure/data_sources/local/overlay/overlay_database.dart';
import '../../application/read_models/contact_profile_reader.dart';
import '../../application/read_models/contact_profile_summary.dart';
import '../../domain/overlay_virtual_contact.dart';
import '../../domain/participant_origin.dart';
import 'participant_merge_utils.dart';

class GraphContactProfileReader implements ContactProfileReader {
  const GraphContactProfileReader({
    required ConversationGraphDatabase graphDb,
    required OverlayDatabase overlayDb,
  }) : _graphDb = graphDb,
       _overlayDb = overlayDb;

  final ConversationGraphDatabase _graphDb;
  final OverlayDatabase _overlayDb;

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
        return ContactProfileSummary(
          contactId: contactId,
          displayName: virtualContact.displayName,
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
      final directOverride = overrides[graphContactId];
      final retainedKeyOverride = _overlayOverrideForEquivalentContactId(
        overrides,
        graphContactId,
      );
      final overrideLabel =
          directOverride?.displayNameOverride?.trim() ??
          retainedKeyOverride?.displayNameOverride?.trim();

      return ContactProfileSummary(
        contactId: graphContactId,
        displayName: overrideLabel != null && overrideLabel.isNotEmpty
            ? overrideLabel
            : displayName,
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
          if (contactIdsRepresentSamePerson(id, contactId)) id,
    ];
  }
}

ParticipantOverride? _overlayOverrideForEquivalentContactId(
  Map<int, ParticipantOverride> overrides,
  int contactId,
) {
  for (final entry in overrides.entries) {
    if (contactIdsRepresentSamePerson(entry.key, contactId)) {
      return entry.value;
    }
  }
  return null;
}
