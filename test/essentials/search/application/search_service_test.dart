import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:remember_this_text/essentials/search/application/graph_message_search.dart';
import 'package:remember_this_text/essentials/search/application/graph_search_repository_provider.dart';
import 'package:remember_this_text/essentials/search/application/search_service.dart';
import 'package:remember_this_text/essentials/search/application/search_service_provider.dart';

void main() {
  test('searchGraphMessageIds delegates graph scope and query', () async {
    final repository = _FakeGraphSearchRepository(resultIds: const [11, 12]);
    final container = _container(repository);
    addTearDown(container.dispose);

    final service = container.read(searchServiceProvider);
    final resultIds = await service.searchGraphMessageIds(
      scope: const GraphMessageSearchScope.conversation(42),
      query: 'settlement offer',
    );

    expect(resultIds, const [11, 12]);
    expect(repository.requests, hasLength(1));
    expect(
      repository.requests.single.scope.type,
      GraphMessageSearchScopeType.conversation,
    );
    expect(repository.requests.single.scope.id, 42);
    expect(repository.requests.single.query, 'settlement offer');
    expect(repository.requests.single.matchAnyTerm, isFalse);
    expect(repository.requests.single.filterSaved, isFalse);
  });

  test('searchGraphMessageIds preserves any-term search mode', () async {
    final repository = _FakeGraphSearchRepository(resultIds: const [99]);
    final container = _container(repository);
    addTearDown(container.dispose);

    final service = container.read(searchServiceProvider);
    await service.searchGraphMessageIds(
      scope: const GraphMessageSearchScope.global(),
      query: 'flower invoice',
      mode: SearchMode.anyTerm,
    );

    expect(repository.requests.single.matchAnyTerm, isTrue);
  });

  test(
    'searchGraphMessageIds strips saved operator and passes saved filter',
    () async {
      final repository = _FakeGraphSearchRepository(resultIds: const [77]);
      final container = _container(repository);
      addTearDown(container.dispose);

      final service = container.read(searchServiceProvider);
      final resultIds = await service.searchGraphMessageIds(
        scope: const GraphMessageSearchScope.global(),
        query: 'is:saved archive plan',
      );

      expect(resultIds, const [77]);
      expect(repository.requests.single.query, 'archive plan');
      expect(repository.requests.single.filterSaved, isTrue);
    },
  );

  test('searchGraphMessageIds can request saved-only graph evidence', () async {
    final repository = _FakeGraphSearchRepository(resultIds: const [31]);
    final container = _container(repository);
    addTearDown(container.dispose);

    final service = container.read(searchServiceProvider);
    final resultIds = await service.searchGraphMessageIds(
      scope: const GraphMessageSearchScope.handle(10),
      query: 'is:saved',
    );

    expect(resultIds, const [31]);
    expect(repository.requests.single.query, isEmpty);
    expect(repository.requests.single.filterSaved, isTrue);
  });

  test('empty search does not hit repository', () async {
    final repository = _FakeGraphSearchRepository(resultIds: const [1]);
    final container = _container(repository);
    addTearDown(container.dispose);

    final service = container.read(searchServiceProvider);
    final resultIds = await service.searchGraphMessageIds(
      scope: const GraphMessageSearchScope.global(),
      query: '   ',
    );

    expect(resultIds, isEmpty);
    expect(repository.requests, isEmpty);
  });

  test('trailing whitespace marks the last token complete', () async {
    final repository = _FakeGraphSearchRepository(resultIds: const [8]);
    final container = _container(repository);
    addTearDown(container.dispose);

    final service = container.read(searchServiceProvider);
    await service.searchGraphMessageIds(
      scope: const GraphMessageSearchScope.global(),
      query: 'flower ',
    );

    expect(repository.requests.single.lastTokenComplete, isTrue);
  });
}

ProviderContainer _container(_FakeGraphSearchRepository repository) {
  return ProviderContainer(
    overrides: [
      graphSearchRepositoryProvider.overrideWith((ref) async {
        return repository;
      }),
    ],
  );
}

class _FakeGraphSearchRepository implements GraphSearchRepository {
  _FakeGraphSearchRepository({required this.resultIds});

  final List<int> resultIds;
  final requests = <_SearchRequest>[];

  @override
  Future<List<int>> searchMessageIds({
    required GraphMessageSearchScope scope,
    required String query,
    required bool matchAnyTerm,
    required bool filterSaved,
    bool lastTokenComplete = false,
    int limit = graphSearchResultLimit,
  }) async {
    requests.add(
      _SearchRequest(
        scope: scope,
        query: query,
        matchAnyTerm: matchAnyTerm,
        filterSaved: filterSaved,
        lastTokenComplete: lastTokenComplete,
        limit: limit,
      ),
    );
    return resultIds;
  }
}

class _SearchRequest {
  const _SearchRequest({
    required this.scope,
    required this.query,
    required this.matchAnyTerm,
    required this.filterSaved,
    required this.lastTokenComplete,
    required this.limit,
  });

  final GraphMessageSearchScope scope;
  final String query;
  final bool matchAnyTerm;
  final bool filterSaved;
  final bool lastTokenComplete;
  final int limit;
}
