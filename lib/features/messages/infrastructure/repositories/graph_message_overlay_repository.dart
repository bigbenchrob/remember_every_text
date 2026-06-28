import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../../core/util/message_tag_normalizer.dart';
import '../../../../essentials/db/infrastructure/data_sources/local/conversation_graph/conversation_graph_database.dart';
import '../../../../essentials/db/infrastructure/data_sources/local/overlay/overlay_database.dart';
import '../../application/message_evidence/message_evidence_identity.dart';
import '../../application/user_metadata/message_overlay_repository.dart';
import '../../domain/entities/message_overlay_state.dart';

/// Reads and writes graph-keyed message user intent.
///
/// Identity resolution here is intentionally semantic: callers ask what user
/// intent belongs to the graph message the user is looking at, not which
/// compatibility row owns that fact. New writes go to graph-native overlay tables
/// keyed by `message_ss_id`; rowid-keyed/GUID-keyed tables are read only as
/// compatibility fallbacks.
class GraphMessageOverlayRepository implements MessageOverlayRepository {
  const GraphMessageOverlayRepository({
    required ConversationGraphDatabase graphDatabase,
    required OverlayDatabase overlayDatabase,
  }) : _graphDatabase = graphDatabase,
       _overlayDatabase = overlayDatabase;

  final ConversationGraphDatabase _graphDatabase;
  final OverlayDatabase _overlayDatabase;

  @override
  Future<MessageOverlayState> readForMessage(int messageSsId) async {
    final identity = await _readGraphIdentity(messageSsId);
    final graphOverlay = await _readGraphOverlay(messageSsId);
    final graphTags = await _readGraphTags(messageSsId);

    var state =
        graphOverlay ??
        MessageOverlayState.empty(
          messageSsId: messageSsId,
        ).copyWith(tags: graphTags);

    if (graphOverlay == null) {
      final rowidAnnotation = await _readRowidAnnotation(identity);
      if (rowidAnnotation != null) {
        state = _applyRowidAnnotation(state, rowidAnnotation);
      }
    } else if (graphTags.isNotEmpty) {
      state = graphOverlay.copyWith(tags: graphTags);
    }

    final guid = identity.guid;
    if (guid == null || guid.isEmpty) {
      return state;
    }

    final guidOccurrenceCount = await _readGuidOccurrenceCount(guid);
    if (guidOccurrenceCount != 1) {
      final guidKeyedIntentExists = await _guidKeyedIntentExists(guid);
      if (!guidKeyedIntentExists) {
        return state;
      }
      return state.copyWith(skippedGuidFallbackBecauseAmbiguous: true);
    }

    final guidState = await _readGuidKeyedState(messageSsId, guid);
    if (!guidState.hasUserIntent) {
      return state;
    }

    return state.copyWith(
      isSaved: graphOverlay?.isSaved ?? guidState.isSaved,
      tags: _mergeTags(state.tags, guidState.tags),
      usedGuidFallback: true,
    );
  }

  @override
  Future<void> setSaved({required int messageSsId, required bool isSaved}) {
    return _upsertGraphOverlay(messageSsId: messageSsId, isSaved: isSaved);
  }

  @override
  Future<bool> toggleSaved(int messageSsId) async {
    final current = await readForMessage(messageSsId);
    final nextValue = !current.isSaved;
    await setSaved(messageSsId: messageSsId, isSaved: nextValue);
    return nextValue;
  }

  @override
  Future<void> setStarred({required int messageSsId, required bool isStarred}) {
    return _upsertGraphOverlay(messageSsId: messageSsId, isStarred: isStarred);
  }

  @override
  Future<void> setArchived({
    required int messageSsId,
    required bool isArchived,
  }) {
    return _upsertGraphOverlay(
      messageSsId: messageSsId,
      isArchived: isArchived,
    );
  }

  Future<void> setNotes({required int messageSsId, required String? notes}) {
    final trimmed = notes?.trim();
    return _upsertGraphOverlay(
      messageSsId: messageSsId,
      userNotes: trimmed == null || trimmed.isEmpty ? null : trimmed,
      userNotesPresent: true,
    );
  }

  Future<void> setPriority({required int messageSsId, required int? priority}) {
    if (priority != null && (priority < 1 || priority > 5)) {
      throw ArgumentError('Priority must be between 1 and 5');
    }
    return _upsertGraphOverlay(
      messageSsId: messageSsId,
      priority: priority,
      priorityPresent: true,
    );
  }

  Future<void> setReminder({
    required int messageSsId,
    required DateTime? remindAt,
  }) {
    return _upsertGraphOverlay(
      messageSsId: messageSsId,
      remindAtUtc: remindAt?.toUtc().toIso8601String(),
      remindAtPresent: true,
    );
  }

  @override
  Future<void> addTags({
    required int messageSsId,
    required Iterable<String> tags,
  }) async {
    final now = DateTime.now().toUtc().toIso8601String();
    final uniqueTags = <String, String>{};
    for (final rawTag in tags) {
      final display = normalizeMessageTagDisplay(rawTag);
      final normalized = normalizeMessageTagValue(rawTag);
      if (display.isEmpty || normalized.isEmpty) {
        continue;
      }
      uniqueTags.putIfAbsent(normalized, () => display);
    }

    for (final entry in uniqueTags.entries) {
      await _overlayDatabase.customStatement(
        '''
        INSERT INTO message_intent_tags (
          message_ss_id,
          tag_display,
          tag_normalized,
          created_at_utc,
          updated_at_utc
        ) VALUES (?, ?, ?, ?, ?)
        ON CONFLICT(message_ss_id, tag_normalized) DO UPDATE SET
          tag_display = excluded.tag_display,
          updated_at_utc = excluded.updated_at_utc
        ''',
        <Object?>[messageSsId, entry.value, entry.key, now, now],
      );
    }
  }

  @override
  Future<void> removeTag({required int messageSsId, required String tag}) {
    final normalized = normalizeMessageTagValue(tag);
    if (normalized.isEmpty) {
      return Future<void>.value();
    }
    return _overlayDatabase.customStatement(
      '''
      DELETE FROM message_intent_tags
      WHERE message_ss_id = ?
        AND tag_normalized = ?
      ''',
      <Object?>[messageSsId, normalized],
    );
  }

  Future<_GraphMessageIdentity> _readGraphIdentity(int messageSsId) async {
    final rows = await _graphDatabase
        .customSelect(
          '''
      SELECT ss_id, guid
      FROM messages
      WHERE ss_id = ?
      ''',
          variables: <Variable>[Variable<int>(messageSsId)],
        )
        .get();

    return _GraphMessageIdentity(
      messageSsId: messageSsId,
      rowidKeyedOverlayMessageRowId: liveMessageRowIdForEvidenceId(messageSsId),
      guid: rows.isEmpty ? null : _readNullableString(rows.single.data['guid']),
    );
  }

  Future<int> _readGuidOccurrenceCount(String guid) async {
    final rows = await _graphDatabase
        .customSelect(
          '''
      SELECT COUNT(*) AS message_count
      FROM messages
      WHERE guid = ?
      ''',
          variables: <Variable>[Variable<String>(guid)],
        )
        .get();

    return _readInt(rows.single.data['message_count']);
  }

  Future<MessageOverlayState?> _readGraphOverlay(int messageSsId) async {
    final rows = await _overlayDatabase
        .customSelect(
          '''
      SELECT
        is_saved,
        is_starred,
        is_archived,
        user_notes,
        priority,
        remind_at
      FROM message_intent_overlays
      WHERE message_ss_id = ?
      ''',
          variables: <Variable>[Variable<int>(messageSsId)],
        )
        .get();

    if (rows.isEmpty) {
      return null;
    }

    final row = rows.single.data;
    return MessageOverlayState(
      messageSsId: messageSsId,
      isSaved: _readBool(row['is_saved']),
      isStarred: _readBool(row['is_starred']),
      isArchived: _readBool(row['is_archived']),
      tags: const <String>[],
      userNotes: _readNullableString(row['user_notes']),
      priority: _readNullableInt(row['priority']),
      remindAtUtc: _readNullableString(row['remind_at']),
      hasGraphNativeOverlay: true,
    );
  }

  Future<List<String>> _readGraphTags(int messageSsId) async {
    final rows = await _overlayDatabase
        .customSelect(
          '''
      SELECT tag_display
      FROM message_intent_tags
      WHERE message_ss_id = ?
      ORDER BY tag_display ASC
      ''',
          variables: <Variable>[Variable<int>(messageSsId)],
        )
        .get();

    return [
      for (final row in rows)
        if (_readNullableString(row.data['tag_display']) case final tag?) tag,
    ];
  }

  Future<MessageAnnotation?> _readRowidAnnotation(
    _GraphMessageIdentity identity,
  ) {
    final rowidKeyedOverlayMessageRowId =
        identity.rowidKeyedOverlayMessageRowId;
    if (rowidKeyedOverlayMessageRowId == null) {
      return Future<MessageAnnotation?>.value();
    }
    return _overlayDatabase.getMessageAnnotation(rowidKeyedOverlayMessageRowId);
  }

  MessageOverlayState _applyRowidAnnotation(
    MessageOverlayState state,
    MessageAnnotation annotation,
  ) {
    return state.copyWith(
      isStarred: annotation.isStarred,
      isArchived: annotation.isArchived,
      tags: _mergeTags(state.tags, _parseRowidAnnotationTags(annotation.tags)),
      userNotes: annotation.userNotes,
      priority: annotation.priority,
      remindAtUtc: annotation.remindAt,
      usedRowidAnnotationFallback: true,
    );
  }

  Future<bool> _guidKeyedIntentExists(String guid) async {
    final saved = await _overlayDatabase.getMessageUserFlag(guid);
    if (saved != null) {
      return true;
    }
    final tags = await _overlayDatabase.getMessageUserTags(guid);
    return tags.isNotEmpty;
  }

  Future<MessageOverlayState> _readGuidKeyedState(
    int messageSsId,
    String guid,
  ) async {
    final saved = await _overlayDatabase.getMessageUserFlag(guid);
    final tags = await _overlayDatabase.getMessageUserTags(guid);
    return MessageOverlayState(
      messageSsId: messageSsId,
      isSaved: saved?.isSaved ?? false,
      isStarred: false,
      isArchived: false,
      tags: tags.map((tag) => tag.tagDisplay).toList(growable: false),
    );
  }

  Future<void> _upsertGraphOverlay({
    required int messageSsId,
    bool? isSaved,
    bool? isStarred,
    bool? isArchived,
    String? userNotes,
    int? priority,
    String? remindAtUtc,
    bool userNotesPresent = false,
    bool priorityPresent = false,
    bool remindAtPresent = false,
  }) async {
    final now = DateTime.now().toUtc().toIso8601String();
    final existing = await _readGraphOverlay(messageSsId);
    final nextIsSaved = isSaved ?? existing?.isSaved ?? false;
    final nextIsStarred = isStarred ?? existing?.isStarred ?? false;
    final nextIsArchived = isArchived ?? existing?.isArchived ?? false;
    final nextUserNotes = userNotesPresent ? userNotes : existing?.userNotes;
    final nextPriority = priorityPresent ? priority : existing?.priority;
    final nextRemindAt = remindAtPresent ? remindAtUtc : existing?.remindAtUtc;

    await _overlayDatabase.customStatement(
      '''
      INSERT INTO message_intent_overlays (
        message_ss_id,
        is_saved,
        is_starred,
        is_archived,
        user_notes,
        priority,
        remind_at,
        created_at_utc,
        updated_at_utc
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
      ON CONFLICT(message_ss_id) DO UPDATE SET
        is_saved = excluded.is_saved,
        is_starred = excluded.is_starred,
        is_archived = excluded.is_archived,
        user_notes = excluded.user_notes,
        priority = excluded.priority,
        remind_at = excluded.remind_at,
        updated_at_utc = excluded.updated_at_utc
      ''',
      <Object?>[
        messageSsId,
        _boolInt(nextIsSaved),
        _boolInt(nextIsStarred),
        _boolInt(nextIsArchived),
        nextUserNotes,
        nextPriority,
        nextRemindAt,
        now,
        now,
      ],
    );
  }

  static List<String> _parseRowidAnnotationTags(String? tagsJson) {
    final raw = tagsJson?.trim();
    if (raw == null || raw.isEmpty) {
      return const <String>[];
    }
    final Object? decoded;
    try {
      decoded = jsonDecode(raw);
    } on FormatException {
      return const <String>[];
    }
    if (decoded is! List) {
      return const <String>[];
    }
    return [
      for (final tag in decoded)
        if (tag is String && tag.trim().isNotEmpty) tag.trim(),
    ];
  }

  static List<String> _mergeTags(List<String> first, List<String> second) {
    final tagsByNormalized = <String, String>{};
    for (final tag in [...first, ...second]) {
      final normalized = normalizeMessageTagValue(tag);
      if (normalized.isEmpty) {
        continue;
      }
      tagsByNormalized.putIfAbsent(normalized, () => tag);
    }
    final tags = tagsByNormalized.values.toList(growable: false);
    tags.sort((left, right) {
      return left.toLowerCase().compareTo(right.toLowerCase());
    });
    return tags;
  }

  static int _boolInt(bool value) {
    return value ? 1 : 0;
  }

  static bool _readBool(Object? value) {
    return value == true || value == 1;
  }

  static int _readInt(Object? value) {
    if (value is int) {
      return value;
    }
    if (value is BigInt) {
      return value.toInt();
    }
    if (value is num) {
      return value.toInt();
    }
    throw StateError('Expected integer value, got $value');
  }

  static int? _readNullableInt(Object? value) {
    if (value == null) {
      return null;
    }
    return _readInt(value);
  }

  static String? _readNullableString(Object? value) {
    if (value == null) {
      return null;
    }
    if (value is String) {
      return value;
    }
    return value.toString();
  }
}

class _GraphMessageIdentity {
  const _GraphMessageIdentity({
    required this.messageSsId,
    required this.rowidKeyedOverlayMessageRowId,
    required this.guid,
  });

  final int messageSsId;
  final int? rowidKeyedOverlayMessageRowId;
  final String? guid;
}
