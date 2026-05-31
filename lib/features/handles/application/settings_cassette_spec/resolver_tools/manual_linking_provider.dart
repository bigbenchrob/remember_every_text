import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../../../essentials/db/feature_level_providers.dart';
import '../../../../../../essentials/db/infrastructure/data_sources/local/conversation_graph/conversation_graph_database.dart';
import '../../../../../../essentials/db/infrastructure/data_sources/local/overlay/overlay_database.dart';
import '../../../../../../essentials/source_scoped_import/domain/known_sources.dart';
import '../../../../../../essentials/source_scoped_import/domain/source_scoped_row_key.dart';
import '../../../../contacts/domain/overlay_virtual_contact.dart';
import '../../../../contacts/infrastructure/repositories/participant_merge_utils.dart';
import '../../../../contacts/infrastructure/repositories/virtual_participants_provider.dart';

part 'manual_linking_provider.g.dart';

class UnlinkedHandle {
  const UnlinkedHandle({
    required this.id,
    required this.handleId,
    required this.service,
    required this.chatCount,
  });

  final int id;
  final String handleId;
  final String service;
  final int chatCount;
}

class AvailableParticipant {
  const AvailableParticipant({
    required this.id,
    required this.displayName,
    required this.handleCount,
  });

  final int id;
  final String displayName;
  final int handleCount;
}

/// Provider that finds handles not linked to any participant.
///
/// A handle is considered linked if it has a graph contact link OR an overlay
/// manual link (participant or virtual participant). Overlay visibility
/// overrides (blacklisted) are also applied here.
@riverpod
Future<List<UnlinkedHandle>> unlinkedHandles(Ref ref) async {
  final graphDb = await ref.watch(
    driftConversationGraphDatabaseProvider.future,
  );
  final overlayDb = await ref.watch(overlayDatabaseProvider.future);

  return _readGraphUnlinkedHandles(graphDb: graphDb, overlayDb: overlayDb);
}

Future<List<UnlinkedHandle>> _readGraphUnlinkedHandles({
  required ConversationGraphDatabase graphDb,
  required OverlayDatabase overlayDb,
}) async {
  final visibilityOverrides = await overlayDb.getAllHandleVisibilities();
  final blacklistedHandleIds = <int>{
    for (final override in visibilityOverrides)
      if (override.isBlacklisted)
        ..._graphHandleIdsForOverlayId(override.handleId),
  };

  final handleOverrides = await overlayDb.getAllHandleOverrides();
  final overlayLinkedHandleIds = <int>{};
  for (final override in handleOverrides) {
    if (override.participantId != null ||
        override.virtualParticipantId != null) {
      overlayLinkedHandleIds.addAll(
        _graphHandleIdsForOverlayId(override.handleId),
      );
    }
  }

  final rows = await graphDb.selectRows('''
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

/// Provider that gets all available participants for linking.
///
/// Handle counts merge graph contact links with overlay manual links.
@riverpod
Future<List<AvailableParticipant>> availableParticipants(Ref ref) async {
  final graphDb = await ref.watch(
    driftConversationGraphDatabaseProvider.future,
  );
  final overlayDb = await ref.watch(overlayDatabaseProvider.future);
  final virtualContacts = await ref.watch(virtualParticipantsProvider.future);

  final graphResults = await _readGraphAvailableParticipants(
    graphDb: graphDb,
    overlayDb: overlayDb,
  );
  final results = [...graphResults];
  results.addAll(
    _virtualAvailableParticipants(
      virtualContacts: virtualContacts,
      overlayCountByVirtualParticipant:
          await overlayHandleCountsByVirtualParticipant(overlayDb),
    ),
  );
  results.sort((a, b) => a.displayName.compareTo(b.displayName));

  return results;
}

Future<List<AvailableParticipant>> _readGraphAvailableParticipants({
  required ConversationGraphDatabase graphDb,
  required OverlayDatabase overlayDb,
}) async {
  final overrides = await participantOverridesById(overlayDb);
  final overlayCountByParticipant = await overlayHandleCountsByParticipant(
    overlayDb,
  );

  final rows = await graphDb.selectRows('''
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
        isPlaceholderDisplayName(importedName)) {
      continue;
    }

    final legacyContactId = _legacyContactIdForGraphContactId(contactId);
    final overrideLabel =
        overrides[contactId]?.displayNameOverride?.trim() ??
        (legacyContactId == null
            ? null
            : overrides[legacyContactId]?.displayNameOverride?.trim());

    results.add(
      AvailableParticipant(
        id: contactId,
        displayName: overrideLabel != null && overrideLabel.isNotEmpty
            ? overrideLabel
            : importedName,
        handleCount:
            _readInt(row['handle_count']) +
            (overlayCountByParticipant[contactId] ?? 0) +
            (legacyContactId == null
                ? 0
                : (overlayCountByParticipant[legacyContactId] ?? 0)),
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

/// Provider for manual linking operations
@riverpod
class ManualLinking extends _$ManualLinking {
  @override
  Future<void> build() async {
    // No initial state needed
  }

  /// Link a handle to a participant manually.
  ///
  /// Writes only to the overlay DB. Read providers combine overlay links with
  /// graph AddressBook topology at read time.
  Future<void> linkHandleToParticipant({
    required int handleId,
    required int participantId,
  }) async {
    final overlayDb = await ref.watch(overlayDatabaseProvider.future);

    await overlayDb.setHandleOverride(handleId, participantId);

    ref.invalidate(unlinkedHandlesProvider);
    ref.invalidate(availableParticipantsProvider);
  }

  /// Unlink a handle from a participant.
  ///
  /// Removes the overlay override so the handle reverts to its graph-projected
  /// AddressBook default (linked or unlinked).
  Future<void> unlinkHandle(int handleId) async {
    final overlayDb = await ref.watch(overlayDatabaseProvider.future);

    await overlayDb.deleteHandleOverride(handleId);

    ref.invalidate(unlinkedHandlesProvider);
    ref.invalidate(availableParticipantsProvider);
  }

  /// Create a new participant for a handle (when no existing participant matches).
  ///
  /// The participant and handle link are both stored in overlay so user-created
  /// contact intent survives graph rebuilds.
  Future<void> createParticipantForHandle({
    required int handleId,
    required String displayName,
  }) async {
    final overlayDb = await ref.watch(overlayDatabaseProvider.future);

    final participant = await overlayDb.createVirtualParticipant(
      displayName: displayName,
    );

    // Store the link in overlay (survives re-imports).
    await overlayDb.setHandleVirtualParticipantOverride(
      handleId,
      participant.id,
    );

    ref.invalidate(unlinkedHandlesProvider);
    ref.invalidate(availableParticipantsProvider);
    ref.invalidate(virtualParticipantsProvider);
  }

  /// Get link information for a specific handle.
  ///
  /// Checks overlay first because manual links win, then graph topology.
  Future<HandleLinkInfo?> getHandleLinkInfo(int handleId) async {
    final graphDb = await ref.watch(
      driftConversationGraphDatabaseProvider.future,
    );
    final overlayDb = await ref.watch(overlayDatabaseProvider.future);

    // Check overlay first — manual links take precedence.
    final overlayRow = await overlayDb.getHandleOverride(handleId);
    if (overlayRow != null && overlayRow.participantId != null) {
      return _readGraphParticipantLinkInfo(
        graphDb: graphDb,
        overlayDb: overlayDb,
        participantId: overlayRow.participantId!,
        source: 'user_manual',
      );
    }

    if (overlayRow != null && overlayRow.virtualParticipantId != null) {
      final virtualContacts = await ref.watch(
        virtualParticipantsProvider.future,
      );
      for (final contact in virtualContacts) {
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

    return _readGraphHandleLinkInfo(
      graphDb: graphDb,
      overlayDb: overlayDb,
      handleId: handleId,
    );
  }
}

class HandleLinkInfo {
  const HandleLinkInfo({
    required this.participantId,
    required this.participantName,
    required this.confidence,
    required this.source,
  });

  final int participantId;
  final String participantName;
  final double confidence;
  final String source;

  bool get isManualLink => source == 'user_manual' || source == 'user_created';
}

Future<HandleLinkInfo?> _readGraphParticipantLinkInfo({
  required ConversationGraphDatabase graphDb,
  required OverlayDatabase overlayDb,
  required int participantId,
  required String source,
}) async {
  final candidateIds = _graphContactIdsForOverlayId(participantId);
  final placeholders = List.filled(candidateIds.length, '?').join(', ');
  final rows = await graphDb.selectRows(
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
      isPlaceholderDisplayName(displayName)) {
    return null;
  }

  final overrides = await participantOverridesById(overlayDb);
  final legacyContactId = _legacyContactIdForGraphContactId(participantId);
  final overrideLabel =
      overrides[participantId]?.displayNameOverride?.trim() ??
      (legacyContactId == null
          ? null
          : overrides[legacyContactId]?.displayNameOverride?.trim());

  return HandleLinkInfo(
    participantId: participantId,
    participantName: overrideLabel != null && overrideLabel.isNotEmpty
        ? overrideLabel
        : displayName,
    confidence: 1.0,
    source: source,
  );
}

Future<HandleLinkInfo?> _readGraphHandleLinkInfo({
  required ConversationGraphDatabase graphDb,
  required OverlayDatabase overlayDb,
  required int handleId,
}) async {
  final candidateIds = _graphHandleIdsForOverlayId(handleId);
  final placeholders = List.filled(candidateIds.length, '?').join(', ');
  final graphRows = await graphDb.selectRows(
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
      isPlaceholderDisplayName(displayName)) {
    return null;
  }

  return _readGraphParticipantLinkInfo(
    graphDb: graphDb,
    overlayDb: overlayDb,
    participantId: _readInt(graphRow['participant_id']),
    source: 'graph_contact',
  );
}

int? _legacyContactIdForGraphContactId(int contactId) {
  if (SourceScopedRowKey.unpackSourceId(contactId) != liveAddressBookSourceId) {
    return null;
  }
  return SourceScopedRowKey.unpackSourceRowId(contactId);
}

Set<int> _graphContactIdsForOverlayId(int contactId) {
  final ids = <int>{contactId};
  final packed = _graphContactIdForLegacyId(contactId);
  if (packed != null) {
    ids.add(packed);
  }
  return ids;
}

int? _graphContactIdForLegacyId(int contactId) {
  if (contactId <= 0 || contactId > SourceScopedRowKey.maxSourceRowId) {
    return null;
  }
  return SourceScopedRowKey.pack(
    sourceId: liveAddressBookSourceId,
    sourceRowId: contactId,
  );
}

Set<int> _graphHandleIdsForOverlayId(int handleId) {
  final ids = <int>{handleId};
  final packed = _graphHandleIdForLegacyId(handleId);
  if (packed != null) {
    ids.add(packed);
  }
  return ids;
}

int? _graphHandleIdForLegacyId(int handleId) {
  if (handleId <= 0 || handleId > SourceScopedRowKey.maxSourceRowId) {
    return null;
  }
  return SourceScopedRowKey.pack(
    sourceId: liveChatDbSourceId,
    sourceRowId: handleId,
  );
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
