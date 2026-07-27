import '../../application/message_evidence/conversation_evidence_header_context_provider.dart';

/// Stable presentation language for a Conversation message timeline.
final class ConversationMessagesEvidencePresentation {
  const ConversationMessagesEvidencePresentation({required this.title});

  factory ConversationMessagesEvidencePresentation.from({
    required ConversationEvidenceHeaderContext? headerContext,
  }) {
    return ConversationMessagesEvidencePresentation(
      title:
          'Conversation with '
          '${headerContext?.title ?? 'Unknown participants'}',
    );
  }

  final String title;
}
