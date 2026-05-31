import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../essentials/db/feature_level_providers.dart';
import '../../../../essentials/db/infrastructure/data_sources/local/conversation_graph/conversation_graph_database.dart';
import '../../../../essentials/db/infrastructure/data_sources/local/overlay/overlay_database.dart';
import '../../domain/overlay_virtual_contact.dart';
import '../../domain/participant_origin.dart';
import 'contacts_list_repository.dart';
import 'participant_merge_utils.dart';
import 'virtual_participants_provider.dart';

part 'contact_profile_provider.g.dart';

class ContactProfileSummary {
  const ContactProfileSummary({
    required this.contactId,
    required this.displayName,
    required this.origin,
  });

  final int contactId;
  final String displayName;
  final ParticipantOrigin origin;
}

@riverpod
Future<ContactProfileSummary?> contactProfile(
  ContactProfileRef ref, {
  required int contactId,
}) async {
  final graphDb = await ref.watch(
    driftConversationGraphDatabaseProvider.future,
  );
  final overlayDb = await ref.watch(overlayDatabaseProvider.future);

  final graphSummary = await _readGraphContactProfile(
    graphDb: graphDb,
    overlayDb: overlayDb,
    contactId: contactId,
  );
  if (graphSummary != null) {
    return graphSummary;
  }

  final virtualContacts = await ref.watch(virtualParticipantsProvider.future);
  OverlayVirtualContact? virtual;
  for (final candidate in virtualContacts) {
    if (candidate.id == contactId) {
      virtual = candidate;
      break;
    }
  }

  if (virtual != null) {
    return ContactProfileSummary(
      contactId: contactId,
      displayName: virtual.displayName,
      origin: ParticipantOrigin.overlayVirtual,
    );
  }

  return null;
}

Future<ContactProfileSummary?> _readGraphContactProfile({
  required ConversationGraphDatabase graphDb,
  required OverlayDatabase overlayDb,
  required int contactId,
}) async {
  final graphContactIds = <int>{contactId};
  graphContactIds.addAll(
    await _candidateGraphContactIds(graphDb: graphDb, contactId: contactId),
  );

  for (final graphContactId in graphContactIds) {
    final rows = await graphDb.selectRows(
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

    final overrides = await participantOverridesById(overlayDb);
    final directOverride = overrides[graphContactId];
    final legacyOverride = _overlayOverrideForEquivalentContactId(
      overrides,
      graphContactId,
    );
    final overrideLabel =
        directOverride?.displayNameOverride?.trim() ??
        legacyOverride?.displayNameOverride?.trim();

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

Future<List<int>> _candidateGraphContactIds({
  required ConversationGraphDatabase graphDb,
  required int contactId,
}) async {
  final rows = await graphDb.selectRows('''
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
