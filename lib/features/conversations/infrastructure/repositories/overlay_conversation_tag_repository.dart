import 'package:drift/drift.dart';

import '../../../../essentials/db/infrastructure/data_sources/local/overlay/overlay_database.dart';
import '../../application/conversation_tags/conversation_tag_repository.dart';
import '../../domain/conversation_tags/conversation_tag_display.dart';

class OverlayConversationTagRepository implements ConversationTagRepository {
  const OverlayConversationTagRepository({required OverlayDatabase database})
    : _database = database;

  final OverlayDatabase _database;

  @override
  Future<List<ConversationTagDisplay>> readAllTags() async {
    final rows = await (_database.select(
      _database.conversationTags,
    )..orderBy([(tbl) => OrderingTerm.asc(tbl.displayName)])).get();
    return rows.map(_toDisplay).toList(growable: false);
  }

  @override
  Future<Map<int, List<ConversationTagDisplay>>> readTagsByConversationIds(
    Iterable<int> conversationIds,
  ) async {
    final ids = conversationIds.toSet().toList(growable: false);
    if (ids.isEmpty) {
      return const <int, List<ConversationTagDisplay>>{};
    }

    final assignmentRows = await (_database.select(
      _database.conversationTagAssignments,
    )..where((tbl) => tbl.conversationId.isIn(ids))).get();
    if (assignmentRows.isEmpty) {
      return {for (final id in ids) id: const <ConversationTagDisplay>[]};
    }

    final tagIds = assignmentRows.map((row) => row.tagId).toSet().toList();
    final tagRows = await (_database.select(
      _database.conversationTags,
    )..where((tbl) => tbl.id.isIn(tagIds))).get();
    final tagsById = {for (final row in tagRows) row.id: _toDisplay(row)};
    final result = {for (final id in ids) id: <ConversationTagDisplay>[]};

    for (final assignment in assignmentRows) {
      final tag = tagsById[assignment.tagId];
      if (tag == null) {
        continue;
      }
      result
          .putIfAbsent(
            assignment.conversationId,
            () => <ConversationTagDisplay>[],
          )
          .add(tag);
    }

    for (final entry in result.entries) {
      entry.value.sort((left, right) {
        return left.displayName.toLowerCase().compareTo(
          right.displayName.toLowerCase(),
        );
      });
    }
    return {
      for (final entry in result.entries)
        entry.key: List<ConversationTagDisplay>.unmodifiable(entry.value),
    };
  }

  @override
  Future<ConversationTagDisplay> createTag(String rawName) async {
    final displayName = normalizeConversationTagDisplayName(rawName);
    final normalizedName = normalizeConversationTagName(rawName);
    if (displayName.isEmpty || normalizedName.isEmpty) {
      throw const FormatException('Conversation tag name cannot be empty.');
    }

    final existing = await _readTagByNormalizedName(normalizedName);
    if (existing != null) {
      return _toDisplay(existing);
    }

    final now = DateTime.now().toUtc().toIso8601String();
    final id = await _database
        .into(_database.conversationTags)
        .insert(
          ConversationTagsCompanion.insert(
            displayName: displayName,
            normalizedName: normalizedName,
            createdAtUtc: now,
            updatedAtUtc: now,
          ),
        );
    final row = await (_database.select(
      _database.conversationTags,
    )..where((tbl) => tbl.id.equals(id))).getSingle();
    return _toDisplay(row);
  }

  @override
  Future<ConversationTagDisplay> createAndAssignTag({
    required int conversationId,
    required String rawName,
  }) async {
    final tag = await createTag(rawName);
    await assignTag(conversationId: conversationId, tagId: tag.id);
    return tag;
  }

  @override
  Future<void> assignTag({
    required int conversationId,
    required int tagId,
  }) async {
    if (conversationId <= 0 || tagId <= 0) {
      return;
    }

    final existing =
        await (_database.select(_database.conversationTagAssignments)
              ..where((tbl) {
                return tbl.conversationId.equals(conversationId) &
                    tbl.tagId.equals(tagId);
              }))
            .getSingleOrNull();
    final now = DateTime.now().toUtc().toIso8601String();

    await _database
        .into(_database.conversationTagAssignments)
        .insertOnConflictUpdate(
          ConversationTagAssignmentsCompanion.insert(
            conversationId: conversationId,
            tagId: tagId,
            createdAtUtc: existing?.createdAtUtc ?? now,
            updatedAtUtc: now,
          ),
        );
  }

  @override
  Future<void> removeTag({
    required int conversationId,
    required int tagId,
  }) async {
    await (_database.delete(_database.conversationTagAssignments)..where((tbl) {
          return tbl.conversationId.equals(conversationId) &
              tbl.tagId.equals(tagId);
        }))
        .go();
  }

  @override
  Future<void> setTagVisibilityPolicy({
    required int tagId,
    required ConversationTagVisibilityPolicy visibilityPolicy,
  }) async {
    if (tagId <= 0) {
      return;
    }
    final now = DateTime.now().toUtc().toIso8601String();
    await (_database.update(_database.conversationTags)..where((tbl) {
          return tbl.id.equals(tagId);
        }))
        .write(
          ConversationTagsCompanion(
            visibilityPolicy: Value(visibilityPolicy.storageValue),
            updatedAtUtc: Value(now),
          ),
        );
  }

  Future<ConversationTag?> _readTagByNormalizedName(String normalizedName) {
    return (_database.select(_database.conversationTags)..where((tbl) {
          return tbl.normalizedName.equals(normalizedName);
        }))
        .getSingleOrNull();
  }

  ConversationTagDisplay _toDisplay(ConversationTag row) {
    return ConversationTagDisplay(
      id: row.id,
      displayName: row.displayName,
      normalizedName: row.normalizedName,
      visibilityPolicy: parseConversationTagVisibilityPolicy(
        row.visibilityPolicy,
      ),
    );
  }
}
