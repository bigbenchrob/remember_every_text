import '../../domain/conversation_tags/conversation_tag_display.dart';

abstract class ConversationTagRepository {
  Future<List<ConversationTagDisplay>> readAllTags();

  Future<Map<int, List<ConversationTagDisplay>>> readTagsByConversationIds(
    Iterable<int> conversationIds,
  );

  Future<ConversationTagDisplay> createTag(String rawName);

  Future<ConversationTagDisplay> createAndAssignTag({
    required int conversationId,
    required String rawName,
  });

  Future<void> assignTag({required int conversationId, required int tagId});

  Future<void> removeTag({required int conversationId, required int tagId});
}
