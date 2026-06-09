import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../essentials/conversation_graph/domain/identity_key_bridge.dart';
import '../../../../essentials/db/feature_level_providers.dart';
import '../../../../essentials/db/infrastructure/data_sources/local/conversation_graph/conversation_graph_database.dart';
import '../../../../essentials/db/infrastructure/data_sources/local/overlay/overlay_database.dart';
import '../../domain/utilities/handle_normalizer.dart';

part 'stray_handles_provider.freezed.dart';
part 'stray_handles_provider.g.dart';

/// A handle that has no graph contact link and no linked overlay override.
@freezed
abstract class StrayHandleSummary with _$StrayHandleSummary {
  const factory StrayHandleSummary({
    required int handleId,
    required String handleValue,
    required String serviceType,
    required int totalMessages,

    /// ISO 8601 timestamp of when the user last reviewed this handle, or null
    /// if never reviewed.
    String? reviewedAt,
    DateTime? lastMessageDate,

    /// Heuristic score indicating likelihood of junk/spam (higher = more likely).
    /// Used to filter candidates for Spam/One-off mode.
    @Default(0) int junkScore,

    /// Whether this handle is a short code (3-8 digits, no country code).
    @Default(false) bool isShortCode,
  }) = _StrayHandleSummary;
}

/// Returns all handles that are truly "stray": no graph contact link and no
/// linked override (participant or virtual participant) in the overlay DB.
///
/// Handles with an overlay row that has only `reviewed_at` set (both
/// participant IDs null) are still included — they are reviewed but unlinked.
///
/// **Excludes dismissed handles** — those are only visible in the Dismissed
/// escape hatch view via [dismissedHandlesProvider].
///
/// Sorted by total message count descending (most messages first).
@riverpod
Future<List<StrayHandleSummary>> strayHandles(Ref ref) async {
  final graphDb = await ref.watch(
    driftConversationGraphDatabaseProvider.future,
  );
  final overlayDb = await ref.watch(overlayDatabaseProvider.future);

  return _readGraphStrayHandles(
    graphDb: graphDb,
    overlayDb: overlayDb,
    includeDismissedOnly: false,
  );
}

Future<List<StrayHandleSummary>> _readGraphStrayHandles({
  required ConversationGraphDatabase graphDb,
  required OverlayDatabase overlayDb,
  required bool includeDismissedOnly,
}) async {
  final allOverrides = await overlayDb.getAllHandleOverrides();
  final linkedOverrideHandleIds = <int>{};
  final reviewedAtByHandle = <int, String>{};
  for (final override in allOverrides) {
    if (override.participantId != null ||
        override.virtualParticipantId != null) {
      linkedOverrideHandleIds.addAll(
        _graphHandleIdsForOverlayId(override.handleId),
      );
    }
    if (override.reviewedAt != null) {
      for (final handleId in _graphHandleIdsForOverlayId(override.handleId)) {
        reviewedAtByHandle[handleId] = override.reviewedAt!;
      }
    }
  }

  final dismissedHandles = await overlayDb.getAllDismissedHandles();
  final visibilityOverrides = await overlayDb.getAllHandleVisibilities();
  final blacklistedHandleIds = <int>{
    for (final override in visibilityOverrides)
      if (override.isBlacklisted)
        ..._graphHandleIdsForOverlayId(override.handleId),
  };

  final rows = await graphDb.selectRows('''
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
    if (linkedOverrideHandleIds.contains(handleId) ||
        blacklistedHandleIds.contains(handleId)) {
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

/// Returns only stray handles that match junk-like heuristics (junkScore >= 3).
///
/// Used for the "Spam / One-off" blitz-dismiss mode. Sorted by junk score
/// descending (most likely junk first).
@riverpod
Future<List<StrayHandleSummary>> spamCandidateHandles(Ref ref) async {
  final allStrays = await ref.watch(strayHandlesProvider.future);

  // Filter to handles with junkScore >= 3.
  final candidates = allStrays.where((h) => h.junkScore >= 3).toList();

  // Sort by junk score descending (most likely spam first).
  candidates.sort((a, b) => b.junkScore.compareTo(a.junkScore));

  return candidates;
}

/// Returns only dismissed handles for the escape hatch view.
///
/// Note: This returns metadata about dismissed handles by looking them up
/// in the graph database using their normalized values.
@riverpod
Future<List<StrayHandleSummary>> dismissedHandles(Ref ref) async {
  final graphDb = await ref.watch(
    driftConversationGraphDatabaseProvider.future,
  );
  final overlayDb = await ref.watch(overlayDatabaseProvider.future);

  return _readGraphStrayHandles(
    graphDb: graphDb,
    overlayDb: overlayDb,
    includeDismissedOnly: true,
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

DateTime? _parseDate(String? value) {
  if (value == null || value.isEmpty) {
    return null;
  }
  return DateTime.tryParse(value)?.toLocal();
}

Set<int> _graphHandleIdsForOverlayId(int handleId) {
  return handleOverlayKeyVariants(handleId);
}
