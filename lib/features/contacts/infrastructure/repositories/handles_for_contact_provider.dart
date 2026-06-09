import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../essentials/conversation_graph/domain/identity_key_bridge.dart';
import '../../../../essentials/db/feature_level_providers.dart';
import '../../../../essentials/db/infrastructure/data_sources/local/conversation_graph/conversation_graph_database.dart';
import '../../../../essentials/db/infrastructure/data_sources/local/overlay/overlay_database.dart';

part 'handles_for_contact_provider.freezed.dart';
part 'handles_for_contact_provider.g.dart';

/// A handle linked to a contact, with its display value and link source.
@freezed
abstract class LinkedHandle with _$LinkedHandle {
  const factory LinkedHandle({
    required int handleId,
    required String displayValue,
    required String service,

    /// Whether this link came from an overlay override (manual link)
    /// rather than graph-projected AddressBook topology.
    required bool isOverrideLink,
  }) = _LinkedHandle;
}

/// Returns all handles linked to a contact, merging graph topology and overlay.
///
/// For graph contacts, handles come from `contact_to_handle`.
/// For virtual participants (id >= 1,000,000,000), handles come from
/// `handle_to_participant_overrides` in the overlay DB.
/// Overlay links for real participants are also included.
@riverpod
Future<List<LinkedHandle>> handlesForContact(
  Ref ref, {
  required int contactId,
}) async {
  final graphDb = await ref.watch(
    driftConversationGraphDatabaseProvider.future,
  );
  final overlayDb = await ref.watch(overlayDatabaseProvider.future);

  final results = <int, LinkedHandle>{};
  const virtualIdFloor = 1000000000;

  final graphHandles = await _readGraphHandlesForContact(
    graphDb: graphDb,
    contactId: contactId,
  );
  for (final handle in graphHandles) {
    results[handle.handleId] = handle;
  }

  // Overlay overrides — could point to real or virtual participant.
  final overrides = <HandleToParticipantOverride>[];
  if (contactId >= virtualIdFloor) {
    overrides.addAll(
      await overlayDb.getOverridesForVirtualParticipant(contactId),
    );
  } else {
    for (final candidateContactId in _overlayContactIds(contactId)) {
      overrides.addAll(
        await overlayDb.getOverridesForParticipant(candidateContactId),
      );
    }
  }

  for (final override in overrides) {
    final handle = await _readGraphHandleForOverlayLink(
      graphDb: graphDb,
      handleId: override.handleId,
    );
    if (handle != null) {
      results[handle.handleId] = handle.copyWith(isOverrideLink: true);
    }
  }

  final sorted = results.values.toList();
  sorted.sort((left, right) {
    return left.displayValue.compareTo(right.displayValue);
  });
  return sorted;
}

Future<List<LinkedHandle>> _readGraphHandlesForContact({
  required ConversationGraphDatabase graphDb,
  required int contactId,
}) async {
  final graphContactIds = contactOverlayKeyVariants(contactId);

  for (final graphContactId in graphContactIds) {
    final rows = await graphDb.selectRows(
      '''
      SELECT DISTINCT
        cth.handle_ss_id AS handle_id,
        COALESCE(ch.display_handle, h.id, cth.handle_value) AS display_value,
        COALESCE(ch.service, h.service, '') AS service
      FROM contact_to_handle cth
      LEFT JOIN canonical_handles ch
        ON ch.canonical_handle_ss_id = cth.handle_ss_id
      LEFT JOIN handles h ON h.ss_id = cth.handle_ss_id
      WHERE cth.contact_id = ?
      ORDER BY display_value ASC
      ''',
      <Object?>[graphContactId],
    );
    if (rows.isEmpty) {
      continue;
    }

    return [
      for (final row in rows)
        LinkedHandle(
          handleId: _readInt(row['handle_id']),
          displayValue: (row['display_value'] as String?)?.trim() ?? '',
          service: (row['service'] as String?)?.trim() ?? '',
          isOverrideLink: false,
        ),
    ];
  }

  return const <LinkedHandle>[];
}

Future<LinkedHandle?> _readGraphHandleForOverlayLink({
  required ConversationGraphDatabase graphDb,
  required int handleId,
}) async {
  final candidateIds = _graphHandleIdsForOverlayHandleId(handleId);
  if (candidateIds.isEmpty) {
    return null;
  }

  final placeholders = List.filled(candidateIds.length, '?').join(', ');
  final rows = await graphDb.selectRows(
    '''
    SELECT
      ch.canonical_handle_ss_id AS handle_id,
      ch.display_handle AS display_value,
      COALESCE(ch.service, '') AS service
    FROM canonical_handles ch
    WHERE ch.canonical_handle_ss_id IN ($placeholders)
    UNION
    SELECT
      COALESCE(ch.canonical_handle_ss_id, h.ss_id) AS handle_id,
      COALESCE(ch.display_handle, h.id) AS display_value,
      COALESCE(ch.service, h.service, '') AS service
    FROM handles h
    LEFT JOIN handle_aliases ha ON ha.handle_ss_id = h.ss_id
    LEFT JOIN canonical_handles ch
      ON ch.canonical_handle_ss_id = ha.canonical_handle_ss_id
    WHERE h.ss_id IN ($placeholders)
    LIMIT 1
    ''',
    <Object?>[...candidateIds, ...candidateIds],
  );
  if (rows.isEmpty) {
    return null;
  }

  final row = rows.single;
  return LinkedHandle(
    handleId: _readInt(row['handle_id']),
    displayValue: (row['display_value'] as String?)?.trim() ?? '',
    service: (row['service'] as String?)?.trim() ?? '',
    isOverrideLink: true,
  );
}

Set<int> _overlayContactIds(int contactId) {
  return contactOverlayKeyVariants(contactId);
}

Set<int> _graphHandleIdsForOverlayHandleId(int handleId) {
  return handleOverlayKeyVariants(handleId);
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
