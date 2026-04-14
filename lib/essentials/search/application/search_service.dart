import 'dart:math';

import 'package:collection/collection.dart';
import 'package:drift/drift.dart' as drift;
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/util/message_tag_normalizer.dart';
import '../../db/feature_level_providers.dart';
import '../../db/infrastructure/data_sources/local/overlay/overlay_database.dart';
import '../../db/infrastructure/data_sources/local/working/working_database.dart';
import '../feature_level_providers.dart';

const _searchResultLimit = 500;
const _recencyWeight = 0.15;
const _savedResultBoost = 0.12;

enum SearchMode { allTerms, anyTerm }

class SearchService {
  SearchService({required this.ref});

  final Ref ref;

  /// Search chat messages, returning just message IDs for virtual scrolling.
  Future<List<int>> searchChatMessageIds({
    required int chatId,
    required String query,
  }) async {
    final parsedQuery = _parseSearchQuery(query);
    final trimmed = parsedQuery.query;
    if (trimmed.isEmpty && !parsedQuery.filterSaved) {
      return const [];
    }
    if (trimmed.isEmpty) {
      return _searchSavedMessageIds(chatId: chatId, contactId: null);
    }

    final lastTokenComplete = _hasTrailingWhitespace(trimmed);

    final tokens = _tokenize(trimmed);
    var textResults = const <int>[];
    if (_shouldUseFts(tokens)) {
      final ftsResults = await _ftsSearchIds(
        tokens: tokens,
        chatId: chatId,
        contactId: null,
        lastTokenComplete: lastTokenComplete,
      );
      textResults = ftsResults;
    }

    if (textResults.isEmpty) {
      textResults = await _legacyChatSearchIds(chatId: chatId, query: trimmed);
    }

    final merged = await _mergeTagMatches(
      query: trimmed,
      textResultIds: textResults,
      chatId: chatId,
      contactId: null,
      mode: SearchMode.allTerms,
    );

    if (!parsedQuery.filterSaved) {
      return merged;
    }

    return _filterSavedMessageIds(merged);
  }

  /// Search contact messages, returning just message IDs for virtual scrolling.
  Future<List<int>> searchContactMessageIds({
    required int contactId,
    required String query,
  }) async {
    final parsedQuery = _parseSearchQuery(query);
    final trimmed = parsedQuery.query;
    if (trimmed.isEmpty && !parsedQuery.filterSaved) {
      return const [];
    }
    if (trimmed.isEmpty) {
      return _searchSavedMessageIds(chatId: null, contactId: contactId);
    }

    final lastTokenComplete = _hasTrailingWhitespace(trimmed);

    final tokens = _tokenize(trimmed);
    var textResults = const <int>[];
    if (_shouldUseFts(tokens)) {
      final ftsResults = await _ftsSearchIds(
        tokens: tokens,
        chatId: null,
        contactId: contactId,
        lastTokenComplete: lastTokenComplete,
      );
      textResults = ftsResults;
    }

    if (textResults.isEmpty) {
      textResults = await _legacyContactSearchIds(
        contactId: contactId,
        query: trimmed,
      );
    }

    final merged = await _mergeTagMatches(
      query: trimmed,
      textResultIds: textResults.sorted((a, b) => b.compareTo(a)),
      chatId: null,
      contactId: contactId,
      mode: SearchMode.allTerms,
    );

    if (!parsedQuery.filterSaved) {
      return merged;
    }

    return _filterSavedMessageIds(merged);
  }

  /// Search global messages, returning just message IDs for virtual scrolling.
  Future<List<int>> searchGlobalMessageIds({
    required String query,
    SearchMode mode = SearchMode.allTerms,
  }) async {
    final parsedQuery = _parseSearchQuery(query);
    final trimmed = parsedQuery.query;
    if (trimmed.isEmpty && !parsedQuery.filterSaved) {
      return const [];
    }
    if (trimmed.isEmpty) {
      return _searchSavedMessageIds(chatId: null, contactId: null);
    }

    final lastTokenComplete = _hasTrailingWhitespace(trimmed);

    final tokens = _tokenize(trimmed);
    var textResults = const <int>[];
    if (_shouldUseFts(tokens)) {
      final ftsResults = await _ftsSearchIds(
        tokens: tokens,
        chatId: null,
        contactId: null,
        mode: mode,
        lastTokenComplete: lastTokenComplete,
      );
      textResults = ftsResults;
    }

    if (textResults.isEmpty) {
      textResults = await _legacyGlobalSearchIds(query: trimmed);
    }

    final merged = await _mergeTagMatches(
      query: trimmed,
      textResultIds: textResults,
      chatId: null,
      contactId: null,
      mode: mode,
    );

    if (!parsedQuery.filterSaved) {
      return merged;
    }

    return _filterSavedMessageIds(merged);
  }

  Future<List<int>> _searchSavedMessageIds({
    required int? chatId,
    required int? contactId,
  }) async {
    final overlayDb = await ref.read(overlayDatabaseProvider.future);
    final savedGuids = await overlayDb.getAllSavedMessageGuids();
    if (savedGuids.isEmpty) {
      return const [];
    }

    final db = await ref.read(driftWorkingDatabaseProvider.future);

    if (contactId != null) {
      final rows =
          await (db.select(db.workingMessages).join([
                  drift.innerJoin(
                    db.contactMessageIndex,
                    db.contactMessageIndex.messageId.equalsExp(
                      db.workingMessages.id,
                    ),
                  ),
                ])
                ..where(db.workingMessages.guid.isIn(savedGuids))
                ..where(db.contactMessageIndex.contactId.equals(contactId))
                ..orderBy([
                  drift.OrderingTerm(
                    expression: db.workingMessages.id,
                    mode: drift.OrderingMode.desc,
                  ),
                ])
                ..limit(_searchResultLimit))
              .get();

      return rows.map((row) => row.readTable(db.workingMessages).id).toList();
    }

    final query = db.select(db.workingMessages)
      ..where((tbl) => tbl.guid.isIn(savedGuids))
      ..orderBy([(tbl) => drift.OrderingTerm.desc(tbl.id)])
      ..limit(_searchResultLimit);
    if (chatId != null) {
      query.where((tbl) => tbl.chatId.equals(chatId));
    }

    final rows = await query.get();
    return rows.map((row) => row.id).toList(growable: false);
  }

  Future<List<int>> _filterSavedMessageIds(List<int> messageIds) async {
    if (messageIds.isEmpty) {
      return const [];
    }

    final db = await ref.read(driftWorkingDatabaseProvider.future);
    final overlayDb = await ref.read(overlayDatabaseProvider.future);
    final rows =
        await (db.select(db.workingMessages)..where((tbl) {
              return tbl.id.isIn(messageIds);
            }))
            .get();
    final guidByMessageId = <int, String>{
      for (final row in rows) row.id: row.guid,
    };
    final savedFlags = await overlayDb.getSavedFlagsByGuids(
      guidByMessageId.values,
    );

    return messageIds
        .where((messageId) {
          final guid = guidByMessageId[messageId];
          if (guid == null) {
            return false;
          }
          return savedFlags[guid] ?? false;
        })
        .toList(growable: false);
  }

  bool _shouldUseFts(List<String> tokens) {
    if (!ref.read(useFtsSearchByDefaultProvider)) {
      return false;
    }
    return tokens.isNotEmpty;
  }

  Future<List<int>> _legacyChatSearchIds({
    required int chatId,
    required String query,
  }) async {
    final db = await ref.read(driftWorkingDatabaseProvider.future);
    final lowerQuery = query.toLowerCase();
    final pattern = '%$lowerQuery%';

    final queryBuilder = db.select(db.workingMessages)
      ..where((m) => m.chatId.equals(chatId))
      ..where((m) => m.textContent.isNotNull())
      ..where((m) => m.textContent.lower().like(pattern))
      ..orderBy([(m) => drift.OrderingTerm.desc(m.id)])
      ..limit(_searchResultLimit);

    final rows = await queryBuilder.get();
    return rows.map((r) => r.id).toList();
  }

  Future<List<int>> _legacyContactSearchIds({
    required int contactId,
    required String query,
  }) async {
    final db = await ref.read(driftWorkingDatabaseProvider.future);
    final lowerQuery = query.toLowerCase();
    final pattern = '%$lowerQuery%';

    final queryBuilder =
        db.select(db.workingMessages).join([
            drift.innerJoin(
              db.contactMessageIndex,
              db.contactMessageIndex.messageId.equalsExp(db.workingMessages.id),
            ),
          ])
          ..where(db.contactMessageIndex.contactId.equals(contactId))
          ..where(db.workingMessages.textContent.isNotNull())
          ..where(db.workingMessages.textContent.lower().like(pattern))
          ..orderBy([
            drift.OrderingTerm(
              expression: db.workingMessages.id,
              mode: drift.OrderingMode.desc,
            ),
          ])
          ..limit(_searchResultLimit);

    final rows = await queryBuilder.get();
    return rows.map((r) => r.readTable(db.workingMessages).id).toList();
  }

  Future<List<int>> _legacyGlobalSearchIds({required String query}) async {
    final db = await ref.read(driftWorkingDatabaseProvider.future);
    final lowerQuery = query.toLowerCase();
    final pattern = '%$lowerQuery%';

    final queryBuilder = db.select(db.workingMessages)
      ..where((m) => m.textContent.isNotNull())
      ..where((m) => m.textContent.lower().like(pattern))
      ..orderBy([(m) => drift.OrderingTerm.desc(m.id)])
      ..limit(_searchResultLimit);

    final rows = await queryBuilder.get();
    return rows.map((r) => r.id).toList();
  }

  Future<List<int>> _ftsSearchIds({
    required List<String> tokens,
    required int? chatId,
    required int? contactId,
    bool lastTokenComplete = false,
    SearchMode mode = SearchMode.allTerms,
  }) async {
    final matchQuery = _buildMatchExpression(
      tokens,
      mode,
      lastTokenComplete: lastTokenComplete,
    );
    if (matchQuery == null) {
      return const [];
    }
    final db = await ref.read(driftWorkingDatabaseProvider.future);
    final now = DateTime.now().toUtc();

    final buffer = StringBuffer('''
SELECT 
  m.id AS message_id,
  m.guid AS message_guid,
  m.sent_at_utc AS sent_at_utc,
  bm25(messages_fts) AS bm25_score
FROM messages_fts
JOIN messages m ON m.id = messages_fts.rowid
WHERE messages_fts MATCH ?
''');
    final variables = <drift.Variable>[drift.Variable.withString(matchQuery)];

    if (chatId != null) {
      buffer.write(' AND m.chat_id = ?');
      variables.add(drift.Variable.withInt(chatId));
    }

    if (contactId != null) {
      buffer.write('''
 AND EXISTS (
   SELECT 1 FROM contact_message_index c
   WHERE c.message_id = m.id AND c.contact_id = ?
 )
''');
      variables.add(drift.Variable.withInt(contactId));
    }

    buffer.write(' LIMIT ?');
    variables.add(drift.Variable.withInt(_searchResultLimit));

    final rows = await db
        .customSelect(buffer.toString(), variables: variables)
        .get();

    if (rows.isEmpty) {
      return const [];
    }

    final overlayDb = await ref.read(overlayDatabaseProvider.future);
    final savedFlags = await overlayDb.getSavedFlagsByGuids(
      rows.map((row) {
        return row.data['message_guid'] as String? ?? '';
      }),
    );

    // Rank by BM25 + recency and return sorted IDs
    final ranked = rows
        .map(
          (row) => _RankedMessage(
            messageId: row.data['message_id'] as int,
            messageGuid: row.data['message_guid'] as String? ?? '',
            bm25: (row.data['bm25_score'] as num?)?.toDouble() ?? 0,
            sentAt: _parseUtc(row.data['sent_at_utc'] as String?),
          ),
        )
        .map((entry) {
          return entry.withFinalScore(
            now,
            isSaved: savedFlags[entry.messageGuid] ?? false,
          );
        })
        .sorted((a, b) => b.finalScore.compareTo(a.finalScore))
        .toList();

    return ranked.map((e) => e.messageId).toList();
  }

  Future<List<int>> _mergeTagMatches({
    required String query,
    required List<int> textResultIds,
    required int? chatId,
    required int? contactId,
    required SearchMode mode,
  }) async {
    final tagResultIds = await _searchScopedTagMessageIds(
      query: query,
      chatId: chatId,
      contactId: contactId,
      mode: mode,
    );
    if (tagResultIds.isEmpty) {
      return textResultIds.take(_searchResultLimit).toList(growable: false);
    }

    final merged = <int>[];
    final seen = <int>{};

    for (final messageId in tagResultIds.followedBy(textResultIds)) {
      if (!seen.add(messageId)) {
        continue;
      }
      merged.add(messageId);
      if (merged.length >= _searchResultLimit) {
        break;
      }
    }

    return merged;
  }

  Future<List<int>> _searchScopedTagMessageIds({
    required String query,
    required int? chatId,
    required int? contactId,
    required SearchMode mode,
  }) async {
    final tokens = tokenizeNormalizedMessageTagQuery(query);
    if (tokens.isEmpty) {
      return const [];
    }

    final overlayDb = await ref.read(overlayDatabaseProvider.future);
    final tagHitsByGuid = _collectTagHitsByGuid(
      allTags: await overlayDb.getAllMessageUserTags(),
      tokens: tokens,
      lastTokenComplete: _hasTrailingWhitespace(query),
      mode: mode,
    );
    if (tagHitsByGuid.isEmpty) {
      return const [];
    }

    final db = await ref.read(driftWorkingDatabaseProvider.future);
    final candidates = await _loadScopedTagCandidates(
      db: db,
      messageGuids: tagHitsByGuid.keys,
      chatId: chatId,
      contactId: contactId,
    );
    if (candidates.isEmpty) {
      return const [];
    }

    final savedFlags = await overlayDb.getSavedFlagsByGuids(
      candidates.map((c) {
        return c.messageGuid;
      }),
    );
    final now = DateTime.now().toUtc();

    final ranked = candidates
        .map((candidate) {
          final hit = tagHitsByGuid[candidate.messageGuid]!;
          return _RankedTagMessage(
            messageId: candidate.messageId,
            sentAt: candidate.sentAt,
            finalScore: hit.score(
              now,
              isSaved: savedFlags[candidate.messageGuid] ?? false,
              sentAt: candidate.sentAt,
            ),
          );
        })
        .sorted((a, b) {
          final scoreCompare = b.finalScore.compareTo(a.finalScore);
          if (scoreCompare != 0) {
            return scoreCompare;
          }

          final sentAtA = a.sentAt;
          final sentAtB = b.sentAt;
          if (sentAtA != null && sentAtB != null) {
            final sentAtCompare = sentAtB.compareTo(sentAtA);
            if (sentAtCompare != 0) {
              return sentAtCompare;
            }
          } else if (sentAtA != null) {
            return 1;
          } else if (sentAtB != null) {
            return -1;
          }

          return b.messageId.compareTo(a.messageId);
        })
        .take(_searchResultLimit)
        .toList(growable: false);

    return ranked.map((entry) => entry.messageId).toList(growable: false);
  }

  Future<List<_ScopedTagCandidate>> _loadScopedTagCandidates({
    required WorkingDatabase db,
    required Iterable<String> messageGuids,
    required int? chatId,
    required int? contactId,
  }) async {
    final guidList = messageGuids.where((guid) => guid.isNotEmpty).toList();
    if (guidList.isEmpty) {
      return const <_ScopedTagCandidate>[];
    }

    if (contactId != null) {
      final rows =
          await (db.select(db.workingMessages).join([
                  drift.innerJoin(
                    db.contactMessageIndex,
                    db.contactMessageIndex.messageId.equalsExp(
                      db.workingMessages.id,
                    ),
                  ),
                ])
                ..where(db.workingMessages.guid.isIn(guidList))
                ..where(db.contactMessageIndex.contactId.equals(contactId)))
              .get();

      return rows
          .map((row) {
            final message = row.readTable(db.workingMessages);
            return _ScopedTagCandidate(
              messageId: message.id,
              messageGuid: message.guid,
              sentAt: _parseUtc(message.sentAtUtc),
            );
          })
          .toList(growable: false);
    }

    final query = db.select(db.workingMessages)
      ..where((tbl) => tbl.guid.isIn(guidList));
    if (chatId != null) {
      query.where((tbl) => tbl.chatId.equals(chatId));
    }

    final rows = await query.get();

    return rows
        .map((message) {
          return _ScopedTagCandidate(
            messageId: message.id,
            messageGuid: message.guid,
            sentAt: _parseUtc(message.sentAtUtc),
          );
        })
        .toList(growable: false);
  }
}

_ParsedSearchQuery _parseSearchQuery(String rawQuery) {
  final rawTokens = rawQuery
      .trim()
      .split(RegExp(r'\s+'))
      .where((token) => token.isNotEmpty)
      .toList(growable: false);
  if (rawTokens.isEmpty) {
    return const _ParsedSearchQuery(query: '', filterSaved: false);
  }

  final queryTokens = <String>[];
  var filterSaved = false;
  for (final token in rawTokens) {
    if (token.toLowerCase() == 'is:saved') {
      filterSaved = true;
      continue;
    }
    queryTokens.add(token);
  }

  return _ParsedSearchQuery(
    query: queryTokens.join(' ').trim(),
    filterSaved: filterSaved,
  );
}

class _ParsedSearchQuery {
  const _ParsedSearchQuery({required this.query, required this.filterSaved});

  final String query;
  final bool filterSaved;
}

Map<String, _TagSearchHit> _collectTagHitsByGuid({
  required List<MessageUserTag> allTags,
  required List<String> tokens,
  required bool lastTokenComplete,
  required SearchMode mode,
}) {
  if (tokens.isEmpty || allTags.isEmpty) {
    return const <String, _TagSearchHit>{};
  }

  final mutableHits = <String, _MutableTagSearchHit>{};
  for (final tag in allTags) {
    for (var index = 0; index < tokens.length; index++) {
      final strength = _normalizedTagTokenMatchStrength(
        normalizedTag: tag.tagNormalized,
        normalizedToken: tokens[index],
        allowPrefix: index == tokens.length - 1 && !lastTokenComplete,
      );
      if (strength == 0) {
        continue;
      }

      mutableHits
          .putIfAbsent(tag.messageGuid, _MutableTagSearchHit.new)
          .record(
            tokenIndex: index,
            strength: strength,
            displayTag: tag.tagDisplay,
          );
    }
  }

  final finalized = <String, _TagSearchHit>{};
  for (final entry in mutableHits.entries) {
    final hit = entry.value.finalize(tokenCount: tokens.length, mode: mode);
    if (hit == null) {
      continue;
    }
    finalized[entry.key] = hit;
  }

  return finalized;
}

int _normalizedTagTokenMatchStrength({
  required String normalizedTag,
  required String normalizedToken,
  required bool allowPrefix,
}) {
  if (normalizedTag.isEmpty || normalizedToken.isEmpty) {
    return 0;
  }

  if (normalizedTag == normalizedToken) {
    return 2;
  }

  final words = normalizedTag.split(' ');
  if (words.contains(normalizedToken)) {
    return 2;
  }

  if (allowPrefix && words.any((word) => word.startsWith(normalizedToken))) {
    return 1;
  }

  return 0;
}

List<String> _tokenize(String input) {
  return input
      .split(RegExp(r'\s+'))
      .map((token) => token.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), ''))
      .where((token) => token.isNotEmpty)
      .toList(growable: false);
}

/// Whether [input] ends with whitespace, signaling the last word is complete.
bool _hasTrailingWhitespace(String input) {
  return input.isNotEmpty && input != input.trimRight();
}

String? _buildMatchExpression(
  List<String> tokens,
  SearchMode mode, {
  bool lastTokenComplete = false,
}) {
  final sanitized = tokens
      .map((token) => token.replaceAll("'", ''))
      .where((token) => token.isNotEmpty)
      .toList();
  if (sanitized.isEmpty) {
    return null;
  }
  final operator = mode == SearchMode.allTerms ? ' AND ' : ' OR ';
  // Prefix-match (*) only the last token, and only when the user hasn't
  // signaled word completion with trailing whitespace.
  final parts = <String>[];
  for (var i = 0; i < sanitized.length; i++) {
    final isLast = i == sanitized.length - 1;
    if (isLast && !lastTokenComplete) {
      parts.add('${sanitized[i]}*');
    } else {
      parts.add(sanitized[i]);
    }
  }
  return parts.join(operator);
}

DateTime? _parseUtc(String? value) {
  if (value == null) {
    return null;
  }
  return DateTime.tryParse(value)?.toUtc();
}

class _RankedMessage {
  const _RankedMessage({
    required this.messageId,
    required this.messageGuid,
    required this.bm25,
    required this.sentAt,
    this.finalScore = 0,
  });

  final int messageId;
  final String messageGuid;
  final double bm25;
  final DateTime? sentAt;
  final double finalScore;

  _RankedMessage withFinalScore(DateTime now, {required bool isSaved}) {
    final base = -bm25;
    final recencyBoost = _computeRecencyBoost(now, sentAt);
    return _RankedMessage(
      messageId: messageId,
      messageGuid: messageGuid,
      bm25: bm25,
      sentAt: sentAt,
      finalScore:
          base +
          _recencyWeight * recencyBoost +
          (isSaved ? _savedResultBoost : 0),
    );
  }
}

class _ScopedTagCandidate {
  const _ScopedTagCandidate({
    required this.messageId,
    required this.messageGuid,
    required this.sentAt,
  });

  final int messageId;
  final String messageGuid;
  final DateTime? sentAt;
}

class _RankedTagMessage {
  const _RankedTagMessage({
    required this.messageId,
    required this.sentAt,
    required this.finalScore,
  });

  final int messageId;
  final DateTime? sentAt;
  final double finalScore;
}

class _TagSearchHit {
  const _TagSearchHit({
    required this.matchedTags,
    required this.exactTokenMatches,
    required this.prefixTokenMatches,
  });

  final List<String> matchedTags;
  final int exactTokenMatches;
  final int prefixTokenMatches;

  double score(
    DateTime now, {
    required bool isSaved,
    required DateTime? sentAt,
  }) {
    return exactTokenMatches * 40 +
        prefixTokenMatches * 18 +
        max(0, matchedTags.length - 1) * 8 +
        (isSaved ? 4 : 0) +
        _computeRecencyBoost(now, sentAt);
  }
}

class _MutableTagSearchHit {
  final Map<int, int> _tokenStrengths = <int, int>{};
  final Set<String> _matchedTags = <String>{};

  void record({
    required int tokenIndex,
    required int strength,
    required String displayTag,
  }) {
    _matchedTags.add(displayTag);
    final currentStrength = _tokenStrengths[tokenIndex] ?? 0;
    if (strength > currentStrength) {
      _tokenStrengths[tokenIndex] = strength;
    }
  }

  _TagSearchHit? finalize({required int tokenCount, required SearchMode mode}) {
    final matchedTokenCount = _tokenStrengths.length;
    final isMatch = mode == SearchMode.anyTerm
        ? matchedTokenCount > 0
        : matchedTokenCount == tokenCount;
    if (!isMatch) {
      return null;
    }

    return _TagSearchHit(
      matchedTags: _matchedTags.sorted(),
      exactTokenMatches: _tokenStrengths.values.where((value) {
        return value == 2;
      }).length,
      prefixTokenMatches: _tokenStrengths.values.where((value) {
        return value == 1;
      }).length,
    );
  }
}

double _computeRecencyBoost(DateTime now, DateTime? sentAt) {
  if (sentAt == null) {
    return 0;
  }
  final ageHours = max(0, now.difference(sentAt).inHours.toDouble());
  return 1 / (1 + ageHours / 24);
}
