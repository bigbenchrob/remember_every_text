import '../../../../essentials/db/infrastructure/data_sources/local/conversation_graph/conversation_graph_database.dart';
import '../../../../essentials/db/infrastructure/data_sources/local/overlay/overlay_database.dart';
import '../../application/read_models/handle_identity.dart';
import '../../application/read_models/stray_handle_summary.dart';
import '../../application/read_models/stray_handles_read_repository.dart';
import '../../domain/utilities/handle_normalizer.dart';

final class GraphStrayHandlesReadRepository
    implements StrayHandlesReadRepository {
  const GraphStrayHandlesReadRepository({
    required ConversationGraphDatabase graphDb,
    required OverlayDatabase overlayDb,
  }) : _graphDb = graphDb,
       _overlayDb = overlayDb;

  final ConversationGraphDatabase _graphDb;
  final OverlayDatabase _overlayDb;

  @override
  Future<List<StrayHandleSummary>> readActiveStrayHandles() {
    return _readGraphStrayHandles(includeDismissedOnly: false);
  }

  @override
  Future<List<StrayHandleSummary>> readDismissedStrayHandles() {
    return _readGraphStrayHandles(includeDismissedOnly: true);
  }

  Future<List<StrayHandleSummary>> _readGraphStrayHandles({
    required bool includeDismissedOnly,
  }) async {
    final allOverrides = await _overlayDb.getAllHandleOverrides();
    final linkedOverrideHandleIds = <int>{};
    final reviewedAtByHandle = <int, String>{};
    for (final override in allOverrides) {
      if (override.participantId != null ||
          override.virtualParticipantId != null) {
        linkedOverrideHandleIds.addAll(
          handleIdentityKeyVariants(override.handleId),
        );
      }
      if (override.reviewedAt != null) {
        for (final handleId in handleIdentityKeyVariants(override.handleId)) {
          reviewedAtByHandle[handleId] = override.reviewedAt!;
        }
      }
    }

    final dismissedHandles = await _overlayDb.getAllDismissedHandles();
    final visibilityOverrides = await _overlayDb.getAllHandleVisibilities();
    final visibilityByHandleId = <int, HandleVisibilityOverride>{};
    for (final override in visibilityOverrides) {
      visibilityByHandleId[override.handleId] = override;
    }

    final rows = await _graphDb.selectRows('''
    SELECT
      ch.canonical_handle_ss_id AS handle_id,
      ch.display_handle AS handle_value,
      COALESCE(ch.service, '') AS service_type,
      COUNT(DISTINCT m.ss_id) AS total_messages,
      MAX(m.date_utc) AS last_message_utc
    FROM canonical_handles ch
    JOIN messages m
      ON m.sender_canonical_handle_ss_id = ch.canonical_handle_ss_id
      OR EXISTS (
        SELECT 1
        FROM handle_aliases sender_alias
        WHERE sender_alias.handle_ss_id = m.sender_handle_ss_id
          AND sender_alias.canonical_handle_ss_id =
            ch.canonical_handle_ss_id
      )
    WHERE NOT EXISTS (
      SELECT 1
      FROM contact_to_handle contact_handle
      WHERE contact_handle.handle_ss_id = ch.canonical_handle_ss_id
    )
    GROUP BY ch.canonical_handle_ss_id
    HAVING COUNT(DISTINCT m.ss_id) > 0
    ORDER BY COUNT(DISTINCT m.ss_id) DESC, ch.display_handle ASC
    ''');

    final results = <StrayHandleSummary>[];
    for (final row in rows) {
      final handleId = _readInt(row['handle_id']);
      final visibility = overlayValueForHandleIdentity(
        visibilityByHandleId,
        handleId,
      );
      if (linkedOverrideHandleIds.contains(handleId) ||
          (visibility?.isBlacklisted ?? false)) {
        continue;
      }

      final handleValue = (row['handle_value'] as String?)?.trim();
      if (handleValue == null || handleValue.isEmpty) {
        continue;
      }

      final normalized = normalizeHandleIdentifier(handleValue);
      if (includeDismissedOnly != dismissedHandles.contains(normalized)) {
        continue;
      }

      final totalMessages = _readInt(row['total_messages']);
      final handleIsShortCode = isShortCode(handleValue);
      var junkScore = 0;
      if (handleIsShortCode) {
        junkScore += 3;
      }
      if (totalMessages == 1) {
        junkScore += 2;
      } else if (totalMessages <= 3) {
        junkScore += 1;
      }

      results.add(
        StrayHandleSummary(
          handleId: handleId,
          handleValue: handleValue,
          serviceType: (row['service_type'] as String?)?.trim() ?? '',
          totalMessages: totalMessages,
          reviewedAt: reviewedAtByHandle[handleId],
          lastMessageDate: _parseDate(row['last_message_utc'] as String?),
          junkScore: junkScore,
          isShortCode: handleIsShortCode,
        ),
      );
    }

    results.sort((a, b) => b.totalMessages.compareTo(a.totalMessages));
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

DateTime? _parseDate(String? value) {
  if (value == null || value.isEmpty) {
    return null;
  }
  return DateTime.tryParse(value)?.toLocal();
}
