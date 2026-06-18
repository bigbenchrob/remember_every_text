import '../../../../essentials/db/infrastructure/data_sources/local/overlay/overlay_database.dart';
import '../../../../essentials/source_scoped_import/domain/known_sources.dart';
import '../../../../essentials/source_scoped_import/domain/source_scoped_row_key.dart';
import '../../application/read_models/contact_summary_identity.dart';

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
        .add(canonicalHandleIdentityKeyForOverlay(override.handleId));
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
        .add(canonicalHandleIdentityKeyForOverlay(override.handleId));
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
        .add(canonicalHandleIdentityKeyForOverlay(override.handleId));
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
        .add(canonicalHandleIdentityKeyForOverlay(override.handleId));
  }

  return map;
}

Future<Map<int, ParticipantOverride>> participantOverridesById(
  OverlayDatabase db,
) async {
  final rows = await db.select(db.participantOverrides).get();
  return {for (final row in rows) row.participantId: row};
}

ParticipantOverride? participantOverrideForContactId({
  required Map<int, ParticipantOverride> participantOverrides,
  required int contactId,
}) {
  for (final key in contactIdentityKeyVariants(contactId)) {
    final value = participantOverrides[key];
    if (value != null) {
      return value;
    }
  }
  return null;
}

Set<int> handleIdentityKeyVariantsForGraphLookup(int handleId) {
  final ids = <int>{handleId};
  final graphHandleId = _graphHandleIdForRetainedHandleId(handleId);
  if (graphHandleId != null) {
    ids.add(graphHandleId);
  }
  final retainedHandleId = _retainedHandleIdForGraphHandleId(handleId);
  if (retainedHandleId != null) {
    ids.add(retainedHandleId);
  }
  return ids;
}

int canonicalHandleIdentityKeyForOverlay(int handleId) {
  return _graphHandleIdForRetainedHandleId(handleId) ?? handleId;
}

int canonicalContactIdentityKeyForOverlay(int contactId) {
  return canonicalContactIdentityKey(contactId);
}

bool isPlaceholderDisplayName(String value) {
  final trimmed = value.trim();
  if (trimmed.isEmpty) {
    return true;
  }
  return trimmed.toLowerCase() == 'unknown contact';
}

int? _graphHandleIdForRetainedHandleId(int handleId) {
  if (handleId <= 0 || handleId > SourceScopedRowKey.maxSourceRowId) {
    return null;
  }
  return SourceScopedRowKey.pack(
    sourceId: liveChatDbSourceId,
    sourceRowId: handleId,
  );
}

int? _retainedHandleIdForGraphHandleId(int handleId) {
  if (SourceScopedRowKey.unpackSourceId(handleId) != liveChatDbSourceId) {
    return null;
  }
  return SourceScopedRowKey.unpackSourceRowId(handleId);
}
