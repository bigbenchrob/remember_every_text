import '../../../../essentials/db/infrastructure/data_sources/local/conversation_graph/conversation_graph_database.dart';
import '../../../../essentials/db/infrastructure/data_sources/local/overlay/overlay_database.dart';
import '../../application/read_models/contact_summary_identity.dart';
import '../../application/read_models/handles_for_contact_reader.dart';
import '../../application/read_models/linked_handle.dart';
import 'participant_merge_utils.dart';

class GraphHandlesForContactReader implements HandlesForContactReader {
  const GraphHandlesForContactReader({
    required ConversationGraphDatabase graphDb,
    required OverlayDatabase overlayDb,
  }) : _graphDb = graphDb,
       _overlayDb = overlayDb;

  final ConversationGraphDatabase _graphDb;
  final OverlayDatabase _overlayDb;

  @override
  Future<List<LinkedHandle>> readHandlesForContact({
    required int contactId,
  }) async {
    final results = <int, LinkedHandle>{};
    const virtualIdFloor = 1000000000;

    final graphHandles = await _readGraphHandlesForContact(
      contactId: contactId,
    );
    for (final handle in graphHandles) {
      results[handle.handleId] = handle;
    }

    final overrides = <HandleToParticipantOverride>[];
    if (contactId >= virtualIdFloor) {
      overrides.addAll(
        await _overlayDb.getOverridesForVirtualParticipant(contactId),
      );
    } else {
      for (final candidateContactId in contactIdentityKeyVariants(contactId)) {
        overrides.addAll(
          await _overlayDb.getOverridesForParticipant(candidateContactId),
        );
      }
    }

    for (final override in overrides) {
      final handle = await _readGraphHandleForOverlayLink(
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
    required int contactId,
  }) async {
    final graphContactIds = contactIdentityKeyVariants(contactId);

    for (final graphContactId in graphContactIds) {
      final rows = await _graphDb.selectRows(
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
    required int handleId,
  }) async {
    final candidateIds = handleIdentityKeyVariantsForGraphLookup(handleId);
    if (candidateIds.isEmpty) {
      return null;
    }

    final placeholders = List.filled(candidateIds.length, '?').join(', ');
    final rows = await _graphDb.selectRows(
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
