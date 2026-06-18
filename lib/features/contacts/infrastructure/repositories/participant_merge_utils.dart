import '../../../../essentials/conversation_graph/application/identity/retained_overlay_identity_bridge.dart';
import '../../../../essentials/db/infrastructure/data_sources/local/overlay/overlay_database.dart';

Future<Map<int, int>> overlayHandleCountsByParticipant(
  OverlayDatabase db,
) async {
  final overrides = await db.getAllHandleOverrides();
  final handlesByParticipant = <int, Set<int>>{};
  for (final override in overrides) {
    final participantId = override.participantId;
    if (participantId == null) {
      continue;
    }
    handlesByParticipant
        .putIfAbsent(participantId, () => <int>{})
        .add(canonicalHandleOverlayKey(override.handleId));
  }

  return {
    for (final entry in handlesByParticipant.entries)
      entry.key: entry.value.length,
  };
}

/// Handle counts grouped by virtual_participant_id (overlay overrides only).
Future<Map<int, int>> overlayHandleCountsByVirtualParticipant(
  OverlayDatabase db,
) async {
  final overrides = await db.getAllHandleOverrides();
  final handlesByVirtualParticipant = <int, Set<int>>{};
  for (final override in overrides) {
    final vpId = override.virtualParticipantId;
    if (vpId == null) {
      continue;
    }
    handlesByVirtualParticipant
        .putIfAbsent(vpId, () => <int>{})
        .add(canonicalHandleOverlayKey(override.handleId));
  }

  return {
    for (final entry in handlesByVirtualParticipant.entries)
      entry.key: entry.value.length,
  };
}

/// Map of participantId → Set<handleId> from overlay overrides
/// (real participants only, not virtual).
Future<Map<int, Set<int>>> overlayHandleIdsByParticipant(
  OverlayDatabase db,
) async {
  final overrides = await db.getAllHandleOverrides();
  final map = <int, Set<int>>{};

  for (final override in overrides) {
    final pid = override.participantId;
    if (pid == null) {
      continue;
    }
    map
        .putIfAbsent(pid, () => <int>{})
        .add(canonicalHandleOverlayKey(override.handleId));
  }

  return map;
}

/// Map of virtualParticipantId → Set<handleId> from overlay overrides.
Future<Map<int, Set<int>>> overlayHandleIdsByVirtualParticipant(
  OverlayDatabase db,
) async {
  final overrides = await db.getAllHandleOverrides();
  final map = <int, Set<int>>{};

  for (final override in overrides) {
    final vpId = override.virtualParticipantId;
    if (vpId == null) {
      continue;
    }
    map
        .putIfAbsent(vpId, () => <int>{})
        .add(canonicalHandleOverlayKey(override.handleId));
  }

  return map;
}

Future<Map<int, ParticipantOverride>> participantOverridesById(
  OverlayDatabase db,
) async {
  final rows = await db.select(db.participantOverrides).get();
  return {for (final row in rows) row.participantId: row};
}

bool isPlaceholderDisplayName(String value) {
  final trimmed = value.trim();
  if (trimmed.isEmpty) {
    return true;
  }
  return trimmed.toLowerCase() == 'unknown contact';
}
