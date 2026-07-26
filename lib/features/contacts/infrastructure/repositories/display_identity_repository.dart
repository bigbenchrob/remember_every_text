import '../../../../essentials/conversation_graph/application/contacts/contact_handle_keys.dart';
import '../../../../essentials/db/infrastructure/data_sources/local/conversation_graph/conversation_graph_database.dart';
import '../../../../essentials/db/infrastructure/data_sources/local/overlay/overlay_database.dart';
import '../../application/display_identity/display_identity.dart';
import '../../application/display_identity/display_identity_repository.dart';
import '../../application/read_models/contact_summary_identity.dart';
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

    await _addSelfHandleIdentities(
      identitiesByHandleKey: identities,
      identitiesByHandleId: identitiesByHandleId,
    );

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

      final override = participantOverrideForContactId(
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
      _putContactIdentity(identitiesByContactId, contactId, identity);
      if (handleSsId != null) {
        identitiesByHandleId.putIfAbsent(handleSsId, () => identity);
      }
      if (contactHandleValue != null && contactHandleValue.isNotEmpty) {
        _putIdentity(identities, contactHandleValue, identity);
      }
    }

    await _addContactIdentities(
      participantOverrides: participantOverrides,
      identitiesByContactId: identitiesByContactId,
    );
    await _addAliasHandleIdentities(
      identitiesByHandleKey: identities,
      identitiesByHandleId: identitiesByHandleId,
    );
    _promoteSelfContactIdentities(
      graphContactRows: graphContactRows,
      identitiesByHandleId: identitiesByHandleId,
      identitiesByContactId: identitiesByContactId,
    );

    return DisplayIdentityResolver(
      identitiesByHandleKey: identities,
      identitiesByHandleId: identitiesByHandleId,
      identitiesByContactId: identitiesByContactId,
    );
  }

  Future<void> _addSelfHandleIdentities({
    required Map<String, ParticipantDisplayIdentity> identitiesByHandleKey,
    required Map<int, ParticipantDisplayIdentity> identitiesByHandleId,
  }) async {
    final rows = await graphDatabase.selectRows('''
      SELECT
        h.ss_id AS handle_ss_id,
        h.id AS handle_value,
        COALESCE(ha.canonical_handle_ss_id, h.ss_id)
          AS canonical_handle_ss_id,
        ch.display_handle AS canonical_handle_value
      FROM handles h
      LEFT JOIN handle_aliases ha ON ha.handle_ss_id = h.ss_id
      LEFT JOIN canonical_handles ch
        ON ch.canonical_handle_ss_id =
          COALESCE(ha.canonical_handle_ss_id, h.ss_id)
      WHERE h.is_me = 1
      ORDER BY h.ss_id ASC
      ''');

    for (final row in rows) {
      const identity = ParticipantDisplayIdentity(
        primaryLabel: selfParticipantDisplayLabel,
        source: DisplayIdentitySource.localAccount,
        isKnownContact: true,
      );
      final handleId = _readNullableInt(row['handle_ss_id']);
      final canonicalHandleId = _readNullableInt(row['canonical_handle_ss_id']);
      final handleValue = (row['handle_value'] as String?)?.trim();
      final canonicalHandleValue = (row['canonical_handle_value'] as String?)
          ?.trim();

      if (handleId != null) {
        identitiesByHandleId[handleId] = identity;
      }
      if (canonicalHandleId != null) {
        identitiesByHandleId[canonicalHandleId] = identity;
      }
      if (handleValue != null && handleValue.isNotEmpty) {
        _putIdentity(identitiesByHandleKey, handleValue, identity);
      }
      if (canonicalHandleValue != null && canonicalHandleValue.isNotEmpty) {
        _putIdentity(identitiesByHandleKey, canonicalHandleValue, identity);
      }
    }
  }

  Future<void> _addContactIdentities({
    required Map<int, ParticipantOverride> participantOverrides,
    required Map<int, ParticipantDisplayIdentity> identitiesByContactId,
  }) async {
    final contactRows = await graphDatabase.selectRows('''
      SELECT
        contact_id,
        display_name
      FROM contacts
      ORDER BY display_name ASC
      ''');

    for (final row in contactRows) {
      final contactId = _readNullableInt(row['contact_id']);
      final displayName = (row['display_name'] as String?)?.trim();
      if (contactId == null ||
          displayName == null ||
          displayName.isEmpty ||
          isPlaceholderDisplayName(displayName)) {
        continue;
      }

      final override = participantOverrideForContactId(
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

      _putContactIdentity(identitiesByContactId, contactId, identity);
    }
  }

  Future<void> _addAliasHandleIdentities({
    required Map<String, ParticipantDisplayIdentity> identitiesByHandleKey,
    required Map<int, ParticipantDisplayIdentity> identitiesByHandleId,
  }) async {
    if (identitiesByHandleId.isEmpty) {
      return;
    }

    final rows = await graphDatabase.selectRows('''
      SELECT
        ha.handle_ss_id,
        ha.canonical_handle_ss_id,
        h.id AS handle_value
      FROM handle_aliases ha
      LEFT JOIN handles h ON h.ss_id = ha.handle_ss_id
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
        final handleValue = (row['handle_value'] as String?)?.trim();
        if (handleValue != null && handleValue.isNotEmpty) {
          _putIdentity(identitiesByHandleKey, handleValue, identity);
        }
      }
    }
  }

  void _promoteSelfContactIdentities({
    required List<Map<String, Object?>> graphContactRows,
    required Map<int, ParticipantDisplayIdentity> identitiesByHandleId,
    required Map<int, ParticipantDisplayIdentity> identitiesByContactId,
  }) {
    for (final row in graphContactRows) {
      final contactId = _readNullableInt(row['contact_id']);
      final handleId = _readNullableInt(row['handle_ss_id']);
      if (contactId == null ||
          handleId == null ||
          identitiesByHandleId[handleId]?.isSelf != true) {
        continue;
      }

      final identity = ParticipantDisplayIdentity(
        primaryLabel: selfParticipantDisplayLabel,
        source: DisplayIdentitySource.localAccount,
        isKnownContact: true,
        contactId: contactId,
      );
      for (final key in contactIdentityKeyVariants(contactId)) {
        identitiesByContactId[key] = identity;
      }
    }
  }
}

void _putContactIdentity(
  Map<int, ParticipantDisplayIdentity> identitiesByContactId,
  int contactId,
  ParticipantDisplayIdentity identity,
) {
  for (final key in contactIdentityKeyVariants(contactId)) {
    identitiesByContactId.putIfAbsent(key, () => identity);
  }
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
