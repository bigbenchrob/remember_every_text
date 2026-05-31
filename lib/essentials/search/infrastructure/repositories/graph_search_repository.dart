import 'package:collection/collection.dart';

import '../../../../core/util/message_tag_normalizer.dart';
import '../../../db/infrastructure/data_sources/local/conversation_graph/conversation_graph_database.dart';
import '../../../db/infrastructure/data_sources/local/overlay/overlay_database.dart';

const int graphSearchResultLimit = 500;

enum GraphMessageSearchScopeType { global, conversation, handle, contact }

class GraphMessageSearchScope {
  const GraphMessageSearchScope._({
    required this.type,
    this.id,
    this.ids = const <int>[],
  });

  const GraphMessageSearchScope.global()
    : this._(type: GraphMessageSearchScopeType.global);

  const GraphMessageSearchScope.conversation(int conversationId)
    : this._(
        type: GraphMessageSearchScopeType.conversation,
        id: conversationId,
      );

  const GraphMessageSearchScope.handle(int canonicalHandleId)
    : this._(type: GraphMessageSearchScopeType.handle, id: canonicalHandleId);

  const GraphMessageSearchScope.contactCanonicalHandles(
    List<int> canonicalHandleIds,
  ) : this._(
        type: GraphMessageSearchScopeType.contact,
        ids: canonicalHandleIds,
      );

  final GraphMessageSearchScopeType type;
  final int? id;
  final List<int> ids;
}

abstract interface class GraphSearchRepository {
  Future<List<int>> searchMessageIds({
    required GraphMessageSearchScope scope,
    required String query,
    required bool matchAnyTerm,
    required bool filterSaved,
    bool lastTokenComplete = false,
    int limit = graphSearchResultLimit,
  });
}

class SqliteGraphSearchRepository implements GraphSearchRepository {
  const SqliteGraphSearchRepository({
    required this.graphDatabase,
    required this.overlayDatabase,
  });

  final ConversationGraphDatabase graphDatabase;
  final OverlayDatabase overlayDatabase;

  @override
  Future<List<int>> searchMessageIds({
    required GraphMessageSearchScope scope,
    required String query,
    required bool matchAnyTerm,
    required bool filterSaved,
    bool lastTokenComplete = false,
    int limit = graphSearchResultLimit,
  }) async {
    final terms = _searchTerms(query);
    if (terms.isEmpty && !filterSaved) {
      return const <int>[];
    }

    final textResultIds = terms.isEmpty
        ? const <int>[]
        : await _searchTextMessageIds(
            scope: scope,
            terms: terms,
            matchAnyTerm: matchAnyTerm,
            limit: limit,
          );

    final tagResultIds = terms.isEmpty
        ? const <int>[]
        : await _searchTagMessageIds(
            scope: scope,
            terms: terms,
            matchAnyTerm: matchAnyTerm,
            lastTokenComplete: lastTokenComplete,
            limit: limit,
          );

    var resultIds = _mergeIds(tagResultIds, textResultIds, limit: limit);

    if (filterSaved) {
      final savedIds = await _readSavedMessageIds(scope: scope, limit: limit);
      if (terms.isEmpty) {
        resultIds = savedIds;
      } else {
        final savedSet = savedIds.toSet();
        resultIds = resultIds
            .where(savedSet.contains)
            .take(limit)
            .toList(growable: false);
      }
    }

    return resultIds.take(limit).toList(growable: false);
  }

  Future<List<int>> _searchTextMessageIds({
    required GraphMessageSearchScope scope,
    required List<String> terms,
    required bool matchAnyTerm,
    required int limit,
  }) async {
    final searchClauses = <String>[];
    final searchArgs = <Object?>[];
    for (final term in terms) {
      searchClauses.add('''
        (
          lower(COALESCE(m.text, '')) LIKE ?
          OR lower(COALESCE(m.guid, '')) LIKE ?
          OR lower(COALESCE(sender_handle.id, '')) LIKE ?
          OR lower(COALESCE(sender_canonical.display_handle, '')) LIKE ?
          OR lower(COALESCE(m.semantic_kind, '')) LIKE ?
          OR lower(COALESCE(m.item_kind, '')) LIKE ?
        )
        ''');
      final pattern = '%$term%';
      searchArgs.addAll([pattern, pattern, pattern, pattern, pattern, pattern]);
    }

    final scoped = _scopeSql(scope);
    if (scoped == null) {
      return const <int>[];
    }

    final rows = await graphDatabase.selectRows(
      '''
      SELECT DISTINCT m.ss_id AS message_id
      FROM messages m
      ${scoped.joinSql}
      LEFT JOIN handles sender_handle ON sender_handle.ss_id =
        m.sender_handle_ss_id
      LEFT JOIN canonical_handles sender_canonical
        ON sender_canonical.canonical_handle_ss_id =
          m.sender_canonical_handle_ss_id
      WHERE ${scoped.whereSql}
        AND (${searchClauses.join(matchAnyTerm ? ' OR ' : ' AND ')})
      ORDER BY COALESCE(m.date_utc, '') DESC, m.ss_id DESC
      LIMIT ?
      ''',
      <Object?>[...scoped.args, ...searchArgs, limit],
    );

    return [for (final row in rows) _readInt(row['message_id'])];
  }

  Future<List<int>> _searchTagMessageIds({
    required GraphMessageSearchScope scope,
    required List<String> terms,
    required bool matchAnyTerm,
    required bool lastTokenComplete,
    required int limit,
  }) async {
    final graphTagIds = await _searchGraphNativeTagIds(
      terms: terms,
      matchAnyTerm: matchAnyTerm,
      lastTokenComplete: lastTokenComplete,
    );
    final legacyGuidTagIds = await _searchLegacyGuidTagIds(
      terms: terms,
      matchAnyTerm: matchAnyTerm,
      lastTokenComplete: lastTokenComplete,
    );

    final merged = _mergeIds(graphTagIds, legacyGuidTagIds, limit: limit);
    return _filterIdsToScope(scope: scope, messageIds: merged, limit: limit);
  }

  Future<List<int>> _searchGraphNativeTagIds({
    required List<String> terms,
    required bool matchAnyTerm,
    required bool lastTokenComplete,
  }) async {
    final rows = await overlayDatabase.customSelect('''
      SELECT message_ss_id, tag_display, tag_normalized
      FROM message_intent_tags
      ORDER BY tag_display ASC
      ''').get();

    final scored = <_ScoredMessageId>[];
    for (final row in rows) {
      final normalizedTag = row.data['tag_normalized'] as String? ?? '';
      final score = _tagMatchScore(
        normalizedTag: normalizedTag,
        terms: terms,
        matchAnyTerm: matchAnyTerm,
        lastTokenComplete: lastTokenComplete,
      );
      if (score == 0) {
        continue;
      }
      scored.add(
        _ScoredMessageId(
          messageId: _readInt(row.data['message_ss_id']),
          score: score,
        ),
      );
    }

    return _rankScoredIds(scored);
  }

  Future<List<int>> _searchLegacyGuidTagIds({
    required List<String> terms,
    required bool matchAnyTerm,
    required bool lastTokenComplete,
  }) async {
    final legacyTags = await overlayDatabase.getAllMessageUserTags();
    final matchingGuids = <String, int>{};
    for (final tag in legacyTags) {
      final score = _tagMatchScore(
        normalizedTag: tag.tagNormalized,
        terms: terms,
        matchAnyTerm: matchAnyTerm,
        lastTokenComplete: lastTokenComplete,
      );
      if (score == 0) {
        continue;
      }
      matchingGuids.update(
        tag.messageGuid,
        (current) => current > score ? current : score,
        ifAbsent: () => score,
      );
    }

    final resolved = await _resolveUniqueGuidMessageIds(matchingGuids.keys);
    final scored = <_ScoredMessageId>[
      for (final entry in resolved.entries)
        _ScoredMessageId(
          messageId: entry.value,
          score: matchingGuids[entry.key] ?? 0,
        ),
    ];
    return _rankScoredIds(scored);
  }

  Future<List<int>> _readSavedMessageIds({
    required GraphMessageSearchScope scope,
    required int limit,
  }) async {
    final graphNativeRows = await overlayDatabase.customSelect('''
      SELECT message_ss_id
      FROM message_intent_overlays
      WHERE is_saved = 1
      ''').get();

    final graphNativeIds = [
      for (final row in graphNativeRows) _readInt(row.data['message_ss_id']),
    ];

    final legacySavedGuids = await overlayDatabase.getAllSavedMessageGuids();
    final legacyIds = await _resolveUniqueGuidMessageIds(
      legacySavedGuids,
    ).then((idsByGuid) => idsByGuid.values.toList(growable: false));

    final merged = _mergeIds(graphNativeIds, legacyIds, limit: limit);
    return _filterIdsToScope(scope: scope, messageIds: merged, limit: limit);
  }

  Future<Map<String, int>> _resolveUniqueGuidMessageIds(
    Iterable<String> guids,
  ) async {
    final guidList = guids
        .map((guid) => guid.trim())
        .where((guid) => guid.isNotEmpty)
        .toSet()
        .toList(growable: false);
    if (guidList.isEmpty) {
      return const <String, int>{};
    }

    final rows = await graphDatabase.selectRows('''
      SELECT guid, MIN(ss_id) AS message_id, COUNT(*) AS message_count
      FROM messages
      WHERE guid IN (${_placeholders(guidList.length)})
      GROUP BY guid
      HAVING COUNT(*) = 1
      ''', guidList);

    final idsByGuid = <String, int>{};
    for (final row in rows) {
      final guid = row['guid'];
      if (guid is! String) {
        continue;
      }
      idsByGuid[guid] = _readInt(row['message_id']);
    }
    return idsByGuid;
  }

  Future<List<int>> _filterIdsToScope({
    required GraphMessageSearchScope scope,
    required List<int> messageIds,
    required int limit,
  }) async {
    if (messageIds.isEmpty) {
      return const <int>[];
    }

    final scoped = _scopeSql(scope, messageIds: messageIds);
    if (scoped == null) {
      return const <int>[];
    }

    final rows = await graphDatabase.selectRows(
      '''
      SELECT DISTINCT m.ss_id AS message_id
      FROM messages m
      ${scoped.joinSql}
      WHERE ${scoped.whereSql}
      ORDER BY COALESCE(m.date_utc, '') DESC, m.ss_id DESC
      LIMIT ?
      ''',
      <Object?>[...scoped.args, limit],
    );

    return [for (final row in rows) _readInt(row['message_id'])];
  }

  _GraphScopeSql? _scopeSql(
    GraphMessageSearchScope scope, {
    List<int> messageIds = const <int>[],
  }) {
    final messageFilter = messageIds.isEmpty
        ? ''
        : ' AND m.ss_id IN (${_placeholders(messageIds.length)})';
    final messageArgs = messageIds.cast<Object?>();

    switch (scope.type) {
      case GraphMessageSearchScopeType.global:
        return _GraphScopeSql(
          joinSql: '',
          whereSql: '1 = 1$messageFilter',
          args: messageArgs,
        );
      case GraphMessageSearchScopeType.conversation:
        final conversationId = scope.id;
        if (conversationId == null) {
          return null;
        }
        return _GraphScopeSql(
          joinSql: '''
          JOIN chat_to_message ctm ON ctm.message_ss_id = m.ss_id
          ''',
          whereSql: 'ctm.chat_ss_id = ?$messageFilter',
          args: <Object?>[conversationId, ...messageArgs],
        );
      case GraphMessageSearchScopeType.handle:
        final handleId = scope.id;
        if (handleId == null) {
          return null;
        }
        return _GraphScopeSql(
          joinSql: '''
          JOIN chat_to_message ctm ON ctm.message_ss_id = m.ss_id
          JOIN chat_to_handle cth ON cth.chat_ss_id = ctm.chat_ss_id
          LEFT JOIN handle_aliases ha ON ha.handle_ss_id = cth.handle_ss_id
          ''',
          whereSql:
              '''
          COALESCE(ha.canonical_handle_ss_id, cth.handle_ss_id) = ?
          $messageFilter
          ''',
          args: <Object?>[handleId, ...messageArgs],
        );
      case GraphMessageSearchScopeType.contact:
        final canonicalHandleIds = scope.ids;
        if (canonicalHandleIds.isEmpty) {
          return null;
        }
        return _GraphScopeSql(
          joinSql: '''
          JOIN chat_to_message ctm ON ctm.message_ss_id = m.ss_id
          JOIN chat_to_handle cth ON cth.chat_ss_id = ctm.chat_ss_id
          LEFT JOIN handle_aliases ha ON ha.handle_ss_id = cth.handle_ss_id
          ''',
          whereSql:
              '''
          COALESCE(ha.canonical_handle_ss_id, cth.handle_ss_id)
            IN (${_placeholders(canonicalHandleIds.length)})
          $messageFilter
          ''',
          args: <Object?>[...canonicalHandleIds, ...messageArgs],
        );
    }
  }
}

class _GraphScopeSql {
  const _GraphScopeSql({
    required this.joinSql,
    required this.whereSql,
    required this.args,
  });

  final String joinSql;
  final String whereSql;
  final List<Object?> args;
}

class _ScoredMessageId {
  const _ScoredMessageId({required this.messageId, required this.score});

  final int messageId;
  final int score;
}

List<String> _searchTerms(String query) {
  return query
      .split(RegExp(r'\s+'))
      .map(normalizeMessageTagValue)
      .where((term) => term.isNotEmpty)
      .toList(growable: false);
}

int _tagMatchScore({
  required String normalizedTag,
  required List<String> terms,
  required bool matchAnyTerm,
  required bool lastTokenComplete,
}) {
  if (normalizedTag.isEmpty || terms.isEmpty) {
    return 0;
  }

  var score = 0;
  var matchedTerms = 0;
  final words = normalizedTag.split(' ');
  for (var index = 0; index < terms.length; index++) {
    final term = terms[index];
    final allowPrefix = index == terms.length - 1 && !lastTokenComplete;
    final strength = _normalizedTagTokenMatchStrength(
      normalizedTag: normalizedTag,
      words: words,
      normalizedToken: term,
      allowPrefix: allowPrefix,
    );
    if (strength == 0) {
      continue;
    }
    matchedTerms += 1;
    score += strength;
  }

  if (matchAnyTerm) {
    return matchedTerms > 0 ? score : 0;
  }
  return matchedTerms == terms.length ? score : 0;
}

int _normalizedTagTokenMatchStrength({
  required String normalizedTag,
  required List<String> words,
  required String normalizedToken,
  required bool allowPrefix,
}) {
  if (normalizedTag == normalizedToken) {
    return 4;
  }
  if (words.contains(normalizedToken)) {
    return 3;
  }
  if (allowPrefix && words.any((word) => word.startsWith(normalizedToken))) {
    return 1;
  }
  return 0;
}

List<int> _rankScoredIds(List<_ScoredMessageId> scored) {
  return scored
      .sorted((left, right) {
        final scoreCompare = right.score.compareTo(left.score);
        if (scoreCompare != 0) {
          return scoreCompare;
        }
        return right.messageId.compareTo(left.messageId);
      })
      .map((entry) => entry.messageId)
      .toSet()
      .toList(growable: false);
}

List<int> _mergeIds(
  List<int> primary,
  List<int> secondary, {
  required int limit,
}) {
  final merged = <int>[];
  final seen = <int>{};
  for (final messageId in primary.followedBy(secondary)) {
    if (!seen.add(messageId)) {
      continue;
    }
    merged.add(messageId);
    if (merged.length >= limit) {
      break;
    }
  }
  return merged;
}

String _placeholders(int count) {
  return List.filled(count, '?').join(', ');
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
