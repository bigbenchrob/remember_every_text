import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../feature_level_providers.dart';
import 'graph_message_search.dart';

enum SearchMode { allTerms, anyTerm }

class SearchService {
  SearchService({required this.ref});

  final Ref ref;

  /// Search graph messages, returning canonical source-scoped message IDs.
  Future<List<int>> searchGraphMessageIds({
    required GraphMessageSearchScope scope,
    required String query,
    SearchMode mode = SearchMode.allTerms,
  }) async {
    final parsedQuery = _parseSearchQuery(query);
    final trimmed = parsedQuery.query;
    if (trimmed.isEmpty && !parsedQuery.filterSaved) {
      return const [];
    }

    final repository = await ref.read(graphSearchRepositoryProvider.future);
    return repository.searchMessageIds(
      scope: scope,
      query: trimmed,
      matchAnyTerm: mode == SearchMode.anyTerm,
      filterSaved: parsedQuery.filterSaved,
      lastTokenComplete: _hasTrailingWhitespace(query),
    );
  }
}

({String query, bool filterSaved}) _parseSearchQuery(String query) {
  final tokens = query.split(RegExp(r'\s+'));
  final retained = <String>[];
  var filterSaved = false;
  for (final token in tokens) {
    if (token.trim().toLowerCase() == 'is:saved') {
      filterSaved = true;
      continue;
    }
    retained.add(token);
  }
  return (query: retained.join(' ').trim(), filterSaved: filterSaved);
}

/// Whether [input] ends with whitespace, signaling the last word is complete.
bool _hasTrailingWhitespace(String input) {
  return input.isNotEmpty && input != input.trimRight();
}
