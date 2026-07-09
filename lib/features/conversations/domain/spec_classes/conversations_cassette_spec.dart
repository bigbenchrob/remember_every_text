import 'package:freezed_annotation/freezed_annotation.dart';

part 'conversations_cassette_spec.freezed.dart';

/// Specification for Conversation-owned sidebar cassettes.
@freezed
abstract class ConversationsCassetteSpec with _$ConversationsCassetteSpec {
  /// Compact conversation topology signatures for the Conversations branch.
  const factory ConversationsCassetteSpec.conversationSignatures() =
      _ConversationsConversationSignaturesSpec;
}
