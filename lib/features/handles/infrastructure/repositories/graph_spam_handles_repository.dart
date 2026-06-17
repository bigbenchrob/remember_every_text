import '../../../../essentials/conversation_graph/application/identity/retained_overlay_identity_bridge.dart';
import '../../../../essentials/db/infrastructure/data_sources/local/conversation_graph/conversation_graph_database.dart';
import '../../application/settings_cassette_spec/resolver_tools/handle_visibility_store.dart';
import '../../application/settings_cassette_spec/resolver_tools/spam_handles_repository.dart';

final class GraphSpamHandlesRepository implements SpamHandlesRepository {
  const GraphSpamHandlesRepository({
    required this.graphDatabase,
    required this.visibilityStore,
  });

  final ConversationGraphDatabase graphDatabase;
  final HandleVisibilityStore visibilityStore;

  @override
  Future<List<SpamHandleInfo>> readSpamHandles() async {
    final visibilityOverrides = await visibilityStore.readAll();
    final overrideMap = <int, HandleVisibilityIntent>{};
    for (final override in visibilityOverrides) {
      for (final handleId in handleOverlayKeyVariants(override.handleId)) {
        overrideMap[handleId] = override;
      }
    }

    final rows = await graphDatabase.selectRows('''
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
      GROUP BY ch.canonical_handle_ss_id
      ORDER BY ch.display_handle ASC
      ''');

    final results = <SpamHandleInfo>[];
    for (final row in rows) {
      final handleId = _readInt(row['handle_id']);
      final displayHandle = (row['display_handle'] as String?)?.trim();
      if (displayHandle == null || displayHandle.isEmpty) {
        continue;
      }

      final overlay = overrideMap[handleId];
      results.add(
        SpamHandleInfo(
          id: handleId,
          handleId: displayHandle,
          service: (row['service'] as String?)?.trim() ?? '',
          isBlacklisted: overlay?.isBlacklisted ?? false,
          isVisible: overlay?.isVisible ?? true,
          chatCount: _readInt(row['chat_count']),
        ),
      );
    }

    results.sort((a, b) {
      if (a.isBlacklisted != b.isBlacklisted) {
        return a.isBlacklisted ? -1 : 1;
      }
      return a.handleId.compareTo(b.handleId);
    });

    return results;
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
