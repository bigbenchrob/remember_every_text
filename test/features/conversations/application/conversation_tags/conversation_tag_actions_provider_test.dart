import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:remember_this_text/features/conversations/application/conversation_tags/conversation_tag_actions_provider.dart';
import 'package:remember_this_text/features/conversations/application/conversation_tags/conversation_tag_repository.dart';
import 'package:remember_this_text/features/conversations/application/conversation_tags/conversation_tag_repository_provider.dart';
import 'package:remember_this_text/features/conversations/application/conversation_tags/conversation_tags_provider.dart';
import 'package:remember_this_text/features/conversations/domain/conversation_tags/conversation_tag_display.dart';

void main() {
  test('actions mutate repository and invalidate tag read providers', () async {
    final repository = _MutableConversationTagRepository();
    final container = ProviderContainer(
      overrides: [
        conversationTagRepositoryProvider.overrideWith((ref) async {
          return repository;
        }),
      ],
    );
    addTearDown(container.dispose);

    expect(await container.read(conversationTagsProvider.future), isEmpty);

    await container
        .read(conversationTagActionsProvider.notifier)
        .createAndAssignTag(conversationId: 42, rawName: 'Family');

    expect(
      (await container.read(
        conversationTagsProvider.future,
      )).map((tag) => tag.displayName),
      ['Family'],
    );
    expect(
      (await container.read(
        conversationTagsByConversationIdsProvider(
          request: ConversationTagsByConversationIdsRequest(
            conversationIds: const [42],
          ),
        ).future,
      ))[42]!.map((tag) => tag.displayName),
      ['Family'],
    );
  });
}

class _MutableConversationTagRepository implements ConversationTagRepository {
  final _tags = <ConversationTagDisplay>[];
  final _assignments = <int, Set<int>>{};
  var _nextId = 1;

  @override
  Future<List<ConversationTagDisplay>> readAllTags() async {
    return List<ConversationTagDisplay>.unmodifiable(_tags);
  }

  @override
  Future<Map<int, List<ConversationTagDisplay>>> readTagsByConversationIds(
    Iterable<int> conversationIds,
  ) async {
    return {
      for (final conversationId in conversationIds)
        conversationId: [
          for (final tagId in _assignments[conversationId] ?? const <int>{})
            if (_tagById(tagId) != null) _tagById(tagId)!,
        ],
    };
  }

  @override
  Future<ConversationTagDisplay> createTag(String rawName) async {
    final normalized = rawName.trim().toLowerCase();
    final existing = _tagByNormalizedName(normalized);
    if (existing != null) {
      return existing;
    }
    final tag = ConversationTagDisplay(
      id: _nextId++,
      displayName: rawName.trim(),
      normalizedName: normalized,
    );
    _tags.add(tag);
    return tag;
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
    _assignments.putIfAbsent(conversationId, () => <int>{}).add(tagId);
  }

  @override
  Future<void> removeTag({
    required int conversationId,
    required int tagId,
  }) async {
    _assignments[conversationId]?.remove(tagId);
  }

  ConversationTagDisplay? _tagById(int tagId) {
    for (final tag in _tags) {
      if (tag.id == tagId) {
        return tag;
      }
    }
    return null;
  }

  ConversationTagDisplay? _tagByNormalizedName(String normalizedName) {
    for (final tag in _tags) {
      if (tag.normalizedName == normalizedName) {
        return tag;
      }
    }
    return null;
  }
}
