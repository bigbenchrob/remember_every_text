import '../../../../essentials/conversation_graph/application/contacts/contact_projector.dart';
import '../../../../essentials/conversation_graph/domain/identity_key_bridge.dart';
import '../../../../essentials/db/infrastructure/data_sources/local/conversation_graph/conversation_graph_database.dart';
import '../../../../essentials/db/infrastructure/data_sources/local/overlay/overlay_database.dart';
import '../../application/display_identity/display_identity.dart';
import '../../application/display_identity/display_identity_repository.dart';
import 'participant_merge_utils.dart';

class SqliteDisplayIdentityRepository implements DisplayIdentityRepository {
  const SqliteDisplayIdentityRepository({
    required this.graphDatabase,
    required this.overlayDatabase,
  });

  final ConversationGraphDatabase graphDatabase;
  final OverlayDatabase overlayDatabase;

  @override
  Future<DisplayIdentityResolver> readResolver() async {
    final participantOverrides = await participantOverridesById(
      overlayDatabase,
    );
    final identities = <String, ParticipantDisplayIdentity>{};
    final identitiesByHandleId = <int, ParticipantDisplayIdentity>{};
    final identitiesByContactId = <int, ParticipantDisplayIdentity>{};

    final graphContactRows = await graphDatabase.selectRows('''
      SELECT
        c.contact_id AS contact_id,
        c.display_name AS contact_display_name,
        cth.handle_ss_id AS handle_ss_id,
        h.id AS handle_value,
        cth.handle_value AS contact_handle_value
      FROM contacts c
      JOIN contact_to_handle cth ON cth.contact_id = c.contact_id
      JOIN handles h ON h.ss_id = cth.handle_ss_id
      ORDER BY c.display_name ASC, h.id ASC
      ''');

    for (final row in graphContactRows) {
      final contactId = _readNullableInt(row['contact_id']);
      final displayName = (row['contact_display_name'] as String?)?.trim();
      final handleSsId = _readNullableInt(row['handle_ss_id']);
      final handleValue = (row['handle_value'] as String?)?.trim();
      final contactHandleValue = (row['contact_handle_value'] as String?)
          ?.trim();
      if (contactId == null ||
          displayName == null ||
          displayName.isEmpty ||
          handleValue == null ||
          handleValue.isEmpty) {
        continue;
      }

      final override = participantOverrideForGraphContactId(
        participantOverrides: participantOverrides,
        contactId: contactId,
      );
      final overrideLabel = override?.displayNameOverride?.trim();
      final identity = ParticipantDisplayIdentity(
        primaryLabel: preferredParticipantPrimaryLabel(
          displayNameOverride: overrideLabel,
          participantDisplayName: displayName,
        ),
        source: overrideLabel != null && overrideLabel.isNotEmpty
            ? DisplayIdentitySource.userOverride
            : DisplayIdentitySource.graphContact,
        isKnownContact: true,
        contactId: contactId,
      );
      _putIdentity(identities, handleValue, identity);
      identitiesByContactId.putIfAbsent(contactId, () => identity);
      final legacyContactId = legacyContactIdForGraphContactId(contactId);
      if (legacyContactId != null) {
        identitiesByContactId.putIfAbsent(legacyContactId, () => identity);
      }
      if (handleSsId != null) {
        identitiesByHandleId.putIfAbsent(handleSsId, () => identity);
      }
      if (contactHandleValue != null && contactHandleValue.isNotEmpty) {
        _putIdentity(identities, contactHandleValue, identity);
      }
    }

    await _addAliasHandleIds(identitiesByHandleId);

    return DisplayIdentityResolver(
      identitiesByHandleKey: identities,
      identitiesByHandleId: identitiesByHandleId,
      identitiesByContactId: identitiesByContactId,
    );
  }

  Future<void> _addAliasHandleIds(
    Map<int, ParticipantDisplayIdentity> identitiesByHandleId,
  ) async {
    if (identitiesByHandleId.isEmpty) {
      return;
    }

    final rows = await graphDatabase.selectRows('''
      SELECT
        handle_ss_id,
        canonical_handle_ss_id
      FROM handle_aliases
      ORDER BY handle_ss_id ASC
      ''');
    for (final row in rows) {
      final handleId = _readNullableInt(row['handle_ss_id']);
      final canonicalHandleId = _readNullableInt(row['canonical_handle_ss_id']);
      if (handleId == null || canonicalHandleId == null) {
        continue;
      }
      final identity = identitiesByHandleId[canonicalHandleId];
      if (identity != null) {
        identitiesByHandleId.putIfAbsent(handleId, () => identity);
      }
    }
  }
}

ParticipantOverride? participantOverrideForGraphContactId({
  required Map<int, ParticipantOverride> participantOverrides,
  required int contactId,
}) {
  return overlayValueForContactId(participantOverrides, contactId);
}

void _putIdentity(
  Map<String, ParticipantDisplayIdentity> identities,
  String handle,
  ParticipantDisplayIdentity identity,
) {
  for (final key in contactHandleKeys(handle)) {
    identities.putIfAbsent(key, () => identity);
  }
}

int? _readNullableInt(Object? value) {
  if (value is int) {
    return value;
  }
  if (value is double) {
    return value.round();
  }
  return null;
}
