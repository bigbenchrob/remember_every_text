import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../conversation_signatures/conversation_signature_display_provider.dart';
import 'conversation_tag_repository_provider.dart';
import 'conversation_tags_provider.dart';

part 'conversation_tag_actions_provider.g.dart';

@riverpod
class ConversationTagActions extends _$ConversationTagActions {
  @override
  FutureOr<void> build() {}

  Future<void> createAndAssignTag({
    required int conversationId,
    required String rawName,
  }) async {
    final repository = await ref.read(conversationTagRepositoryProvider.future);
    await repository.createAndAssignTag(
      conversationId: conversationId,
      rawName: rawName,
    );
    _invalidateConversationTagReads();
  }

  Future<void> assignTag({
    required int conversationId,
    required int tagId,
  }) async {
    final repository = await ref.read(conversationTagRepositoryProvider.future);
    await repository.assignTag(conversationId: conversationId, tagId: tagId);
    _invalidateConversationTagReads();
  }

  Future<void> removeTag({
    required int conversationId,
    required int tagId,
  }) async {
    final repository = await ref.read(conversationTagRepositoryProvider.future);
    await repository.removeTag(conversationId: conversationId, tagId: tagId);
    _invalidateConversationTagReads();
  }

  void _invalidateConversationTagReads() {
    ref.invalidate(conversationTagsProvider);
    ref.invalidate(conversationTagsByConversationIdsProvider);
    ref.invalidate(conversationSignatureDisplayProvider);
    ref.invalidate(conversationSignatureDisplayByIdsProvider);
    ref.invalidate(favouriteConversationSignatureDisplayProvider);
  }
}
