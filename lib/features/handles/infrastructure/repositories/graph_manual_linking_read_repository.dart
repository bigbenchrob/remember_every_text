import '../../../../essentials/conversation_graph/domain/identity_key_bridge.dart';
import '../../../../essentials/db/infrastructure/data_sources/local/conversation_graph/conversation_graph_database.dart';
import '../../../../essentials/db/infrastructure/data_sources/local/overlay/overlay_database.dart';
import '../../../contacts/feature_level_providers.dart'
    show DisplayIdentityResolver, OverlayVirtualContact;
import '../../application/settings_cassette_spec/resolver_tools/manual_linking_read_repository.dart';

class GraphManualLinkingReadRepository implements ManualLinkingReadRepository {
  const GraphManualLinkingReadRepository({
    required ConversationGraphDatabase graphDb,
    required OverlayDatabase overlayDb,
    required List<OverlayVirtualContact> virtualContacts,
    required DisplayIdentityResolver displayIdentityResolver,
  }) : _graphDb = graphDb,
       _overlayDb = overlayDb,
       _virtualContacts = virtualContacts,
       _displayIdentityResolver = displayIdentityResolver;

  final ConversationGraphDatabase _graphDb;
  final OverlayDatabase _overlayDb;
  final List<OverlayVirtualContact> _virtualContacts;
  final DisplayIdentityResolver _displayIdentityResolver;

  @override
  Future<List<UnlinkedHandle>> readUnlinkedHandles() async {
    final visibilityOverrides = await _overlayDb.getAllHandleVisibilities();
    final blacklistedHandleIds = <int>{
      for (final override in visibilityOverrides)
        if (override.isBlacklisted)
          ...handleOverlayKeyVariants(override.handleId),
    };

    final handleOverrides = await _overlayDb.getAllHandleOverrides();
    final overlayLinkedHandleIds = <int>{};
    for (final override in handleOverrides) {
      if (override.participantId != null ||
          override.virtualParticipantId != null) {
        overlayLinkedHandleIds.addAll(
          handleOverlayKeyVariants(override.handleId),
        );
      }
    }

    final rows = await _graphDb.selectRows('''
      SELECT
        ch.canonical_handle_ss_id AS handle_id,
        ch.display_handle AS display_handle,
        COALESCE(ch.service, '') AS service,
        COUNT(DISTINCT cth.chat_ss_id) AS chat_count
      FROM canonical_handles ch
      LEFT JOIN chat_to_handle cth
        ON cth.handle_ss_id = ch.canonical_handle_ss_id
        OR EXISTS (
          SELECT 1
          FROM handle_aliases handle_alias
          WHERE handle_alias.handle_ss_id = cth.handle_ss_id
            AND handle_alias.canonical_handle_ss_id =
              ch.canonical_handle_ss_id
        )
      WHERE NOT EXISTS (
        SELECT 1
        FROM contact_to_handle contact_handle
        WHERE contact_handle.handle_ss_id = ch.canonical_handle_ss_id
      )
      GROUP BY ch.canonical_handle_ss_id
      ORDER BY chat_count DESC, ch.display_handle ASC
      ''');

    final results = <UnlinkedHandle>[];
    for (final row in rows) {
      final handleId = _readInt(row['handle_id']);
      if (overlayLinkedHandleIds.contains(handleId)) {
        continue;
      }

      if (blacklistedHandleIds.contains(handleId)) {
        continue;
      }

      final displayHandle = (row['display_handle'] as String?)?.trim();
      if (displayHandle == null || displayHandle.isEmpty) {
        continue;
      }

      results.add(
        UnlinkedHandle(
          id: handleId,
          handleId: displayHandle,
          service: (row['service'] as String?)?.trim() ?? '',
          chatCount: _readInt(row['chat_count']),
        ),
      );
    }

    results.sort((a, b) {
      final chatComparison = b.chatCount.compareTo(a.chatCount);
      if (chatComparison != 0) {
        return chatComparison;
      }
      return a.handleId.compareTo(b.handleId);
    });

    return results;
  }

  @override
  Future<List<AvailableParticipant>> readAvailableParticipants() async {
    final graphResults = await _readGraphAvailableParticipants();
    final results = [...graphResults];
    results.addAll(
      _virtualAvailableParticipants(
        virtualContacts: _virtualContacts,
        overlayCountByVirtualParticipant:
            await _overlayHandleCountsByVirtualParticipant(),
      ),
    );
    results.sort((a, b) => a.displayName.compareTo(b.displayName));

    return results;
  }

  Future<List<AvailableParticipant>> _readGraphAvailableParticipants() async {
    final overlayCountByParticipant = await _overlayHandleCountsByParticipant();

    final rows = await _graphDb.selectRows('''
      SELECT
        c.contact_id AS contact_id,
        c.display_name AS display_name,
        COUNT(DISTINCT cth.handle_ss_id) AS handle_count
      FROM contacts c
      LEFT JOIN contact_to_handle cth ON cth.contact_id = c.contact_id
      WHERE c.display_name IS NOT NULL
        AND c.display_name != ''
        AND c.display_name != 'Unknown Contact'
      GROUP BY c.contact_id
      ORDER BY c.display_name ASC
      ''');

    final results = <AvailableParticipant>[];
    for (final row in rows) {
      final contactId = _readInt(row['contact_id']);
      final importedName = (row['display_name'] as String?)?.trim();
      if (importedName == null ||
          importedName.isEmpty ||
          _isPlaceholderDisplayName(importedName)) {
        continue;
      }

      final identity = _displayIdentityResolver.resolveContact(contactId);
      final retainedOverlayContactId =
          retainedOverlayContactIdForGraphContactId(contactId);

      results.add(
        AvailableParticipant(
          id: contactId,
          displayName: identity.isKnownContact
              ? identity.primaryLabel
              : importedName,
          handleCount:
              _readInt(row['handle_count']) +
              (overlayCountByParticipant[contactId] ?? 0) +
              (retainedOverlayContactId == null
                  ? 0
                  : (overlayCountByParticipant[retainedOverlayContactId] ?? 0)),
        ),
      );
    }

    results.sort((a, b) => a.displayName.compareTo(b.displayName));
    return results;
  }

  List<AvailableParticipant> _virtualAvailableParticipants({
    required List<OverlayVirtualContact> virtualContacts,
    required Map<int, int> overlayCountByVirtualParticipant,
  }) {
    return [
      for (final contact in virtualContacts)
        AvailableParticipant(
          id: contact.id,
          displayName: contact.displayName,
          handleCount: overlayCountByVirtualParticipant[contact.id] ?? 0,
        ),
    ];
  }

  @override
  Future<HandleLinkInfo?> readHandleLinkInfo(int handleId) async {
    final overlayRow = await _overlayDb.getHandleOverride(handleId);
    if (overlayRow != null && overlayRow.participantId != null) {
      return _readGraphParticipantLinkInfo(
        participantId: overlayRow.participantId!,
        source: 'user_manual',
      );
    }

    if (overlayRow != null && overlayRow.virtualParticipantId != null) {
      for (final contact in _virtualContacts) {
        if (contact.id == overlayRow.virtualParticipantId) {
          return HandleLinkInfo(
            participantId: contact.id,
            participantName: contact.displayName,
            confidence: 1.0,
            source: 'user_created',
          );
        }
      }
    }

    return _readGraphHandleLinkInfo(handleId);
  }

  Future<HandleLinkInfo?> _readGraphParticipantLinkInfo({
    required int participantId,
    required String source,
  }) async {
    final identity = _displayIdentityResolver.resolveContact(participantId);
    if (identity.isKnownContact) {
      return HandleLinkInfo(
        participantId: participantId,
        participantName: identity.primaryLabel,
        confidence: 1.0,
        source: source,
      );
    }

    final candidateIds = contactOverlayKeyVariants(participantId);
    final placeholders = List.filled(candidateIds.length, '?').join(', ');
    final rows = await _graphDb.selectRows(
      '''
      SELECT contact_id, display_name
      FROM contacts
      WHERE contact_id IN ($placeholders)
      LIMIT 1
      ''',
      <Object?>[...candidateIds],
    );
    if (rows.isEmpty) {
      return null;
    }

    final row = rows.single;
    final displayName = (row['display_name'] as String?)?.trim();
    if (displayName == null ||
        displayName.isEmpty ||
        _isPlaceholderDisplayName(displayName)) {
      return null;
    }

    return HandleLinkInfo(
      participantId: participantId,
      participantName: displayName,
      confidence: 1.0,
      source: source,
    );
  }

  Future<HandleLinkInfo?> _readGraphHandleLinkInfo(int handleId) async {
    final candidateIds = handleOverlayKeyVariants(handleId);
    final placeholders = List.filled(candidateIds.length, '?').join(', ');
    final graphRows = await _graphDb.selectRows(
      '''
      SELECT c.contact_id AS participant_id, c.display_name AS display_name
      FROM contact_to_handle cth
      JOIN contacts c ON c.contact_id = cth.contact_id
      WHERE cth.handle_ss_id IN ($placeholders)
      LIMIT 1
      ''',
      <Object?>[...candidateIds],
    );
    if (graphRows.isEmpty) {
      return null;
    }

    final graphRow = graphRows.single;
    final displayName = (graphRow['display_name'] as String?)?.trim();
    if (displayName == null ||
        displayName.isEmpty ||
        _isPlaceholderDisplayName(displayName)) {
      return null;
    }

    return _readGraphParticipantLinkInfo(
      participantId: _readInt(graphRow['participant_id']),
      source: 'graph_contact',
    );
  }

  Future<Map<int, int>> _overlayHandleCountsByParticipant() async {
    final overrides = await _overlayDb.getAllHandleOverrides();
    final counts = <int, int>{};
    for (final override in overrides) {
      final participantId = override.participantId;
      if (participantId == null) {
        continue;
      }
      counts[participantId] = (counts[participantId] ?? 0) + 1;
    }
    return counts;
  }

  Future<Map<int, int>> _overlayHandleCountsByVirtualParticipant() async {
    final overrides = await _overlayDb.getAllHandleOverrides();
    final counts = <int, int>{};
    for (final override in overrides) {
      final virtualParticipantId = override.virtualParticipantId;
      if (virtualParticipantId == null) {
        continue;
      }
      counts[virtualParticipantId] = (counts[virtualParticipantId] ?? 0) + 1;
    }
    return counts;
  }
}

int _readInt(Object? value) {
  if (value is int) {
    return value;
  }
  if (value is BigInt) {
    return value.toInt();
  }
  if (value is num) {
    return value.toInt();
  }
  return int.parse(value.toString());
}

bool _isPlaceholderDisplayName(String value) {
  final trimmed = value.trim();
  if (trimmed.isEmpty) {
    return true;
  }
  return trimmed.toLowerCase() == 'unknown contact';
}
