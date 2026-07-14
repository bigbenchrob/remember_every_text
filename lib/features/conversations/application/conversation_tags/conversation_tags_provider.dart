import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/conversation_tags/conversation_tag_display.dart';
import 'conversation_tag_repository_provider.dart';

part 'conversation_tags_provider.g.dart';

@immutable
class ConversationTagsByConversationIdsRequest {
  ConversationTagsByConversationIdsRequest({
    required Iterable<int> conversationIds,
  }) : conversationIds = List<int>.unmodifiable(conversationIds);

  final List<int> conversationIds;

  static const _equality = ListEquality<int>();

  @override
  bool operator ==(Object other) {
    return other is ConversationTagsByConversationIdsRequest &&
        _equality.equals(other.conversationIds, conversationIds);
  }

  @override
  int get hashCode => _equality.hash(conversationIds);
}

@riverpod
Future<List<ConversationTagDisplay>> conversationTags(Ref ref) async {
  final repository = await ref.watch(conversationTagRepositoryProvider.future);
  return repository.readAllTags();
}

@riverpod
Future<Map<int, List<ConversationTagDisplay>>>
conversationTagsByConversationIds(
  Ref ref, {
  required ConversationTagsByConversationIdsRequest request,
}) async {
  final repository = await ref.watch(conversationTagRepositoryProvider.future);
  return repository.readTagsByConversationIds(request.conversationIds);
}
