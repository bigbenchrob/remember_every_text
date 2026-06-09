import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../../../essentials/conversation_graph/domain/identity_key_bridge.dart';
import '../../../../../../essentials/db/feature_level_providers.dart';
import '../../../../../../essentials/db/infrastructure/data_sources/local/conversation_graph/conversation_graph_database.dart';
import '../../../../../../essentials/db/infrastructure/data_sources/local/overlay/overlay_database.dart';

part 'spam_management_provider.g.dart';

enum SpamFilterStatus { all, blacklisted, visible }

class SpamHandleInfo {
  const SpamHandleInfo({
    required this.id,
    required this.handleId,
    required this.service,
    required this.isBlacklisted,
    required this.isVisible,
    required this.chatCount,
  });

  final int id;
  final String handleId;
  final String service;
  final bool isBlacklisted;
  final bool isVisible;
  final int chatCount;
}

/// Provider for managing spam/blacklisted handles
@riverpod
Future<List<SpamHandleInfo>> spamHandles(Ref ref) async {
  final graphDb = await ref.watch(
    driftConversationGraphDatabaseProvider.future,
  );
  final overlayDb = await ref.watch(overlayDatabaseProvider.future);

  return _readGraphSpamHandles(graphDb: graphDb, overlayDb: overlayDb);
}

Future<List<SpamHandleInfo>> _readGraphSpamHandles({
  required ConversationGraphDatabase graphDb,
  required OverlayDatabase overlayDb,
}) async {
  final visibilityOverrides = await overlayDb.getAllHandleVisibilities();
  final overrideMap = <int, HandleVisibilityOverride>{};
  for (final override in visibilityOverrides) {
    for (final handleId in _graphHandleIdsForOverlayId(override.handleId)) {
      overrideMap[handleId] = override;
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

/// Provider for spam management operations
@riverpod
class SpamManagement extends _$SpamManagement {
  @override
  Future<void> build() async {
    // No initial state needed
  }

  /// Block a handle (mark as blacklisted)
  Future<void> blockHandle(int handleId) async {
    final overlayDb = await ref.watch(overlayDatabaseProvider.future);
    await overlayDb.setHandleVisibility(
      handleId,
      isVisible: false,
      isBlacklisted: true,
    );

    // Refresh the spam handles list
    ref.invalidate(spamHandlesProvider);
  }

  /// Unblock a handle (remove from blacklist)
  Future<void> unblockHandle(int handleId) async {
    final overlayDb = await ref.watch(overlayDatabaseProvider.future);
    await overlayDb.deleteHandleVisibility(handleId);

    // Refresh the spam handles list
    ref.invalidate(spamHandlesProvider);
  }

  /// Get statistics about spam filtering
  Future<SpamStats> getSpamStats() async {
    final handles = await ref.watch(spamHandlesProvider.future);

    final totalHandles = handles.length;
    final blacklistedHandles = handles.where((h) => h.isBlacklisted).length;
    final visibleHandles = handles.where((h) => h.isVisible).length;

    return SpamStats(
      totalHandles: totalHandles,
      blacklistedHandles: blacklistedHandles,
      visibleHandles: visibleHandles,
    );
  }
}

class SpamStats {
  const SpamStats({
    required this.totalHandles,
    required this.blacklistedHandles,
    required this.visibleHandles,
  });

  final int totalHandles;
  final int blacklistedHandles;
  final int visibleHandles;

  double get blacklistPercentage =>
      totalHandles > 0 ? (blacklistedHandles / totalHandles) * 100 : 0.0;
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

Set<int> _graphHandleIdsForOverlayId(int handleId) {
  return handleOverlayKeyVariants(handleId);
}
