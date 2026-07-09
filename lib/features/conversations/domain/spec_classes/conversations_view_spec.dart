import 'package:freezed_annotation/freezed_annotation.dart';

part 'conversations_view_spec.freezed.dart';

@freezed
abstract class ConversationsSpec with _$ConversationsSpec {
  /// Center-panel Conversation message evidence timeline.
  const factory ConversationsSpec.conversationMessages({
    required int conversationId,
    int? anchorMessageId,
    String? searchQuery,
  }) = _ConversationsConversationMessages;

  /// End-sidebar Conversation excerpt anchored around a selected message.
  const factory ConversationsSpec.conversationExcerpt({
    required int conversationId,
    required int anchorMessageId,
    @Default(10) int beforeCount,
    @Default(10) int afterCount,
  }) = _ConversationsConversationExcerpt;
}
