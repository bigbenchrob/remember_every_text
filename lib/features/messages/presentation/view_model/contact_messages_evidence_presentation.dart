import '../../application/message_evidence/contact_evidence_header_context_provider.dart';

/// Stable presentation language for contact message evidence.
final class ContactMessagesEvidencePresentation {
  const ContactMessagesEvidencePresentation({required this.title});

  factory ContactMessagesEvidencePresentation.from({
    required ContactEvidenceHeaderContext? headerContext,
    required int? filterHandleId,
    required bool isHeaderLoading,
  }) {
    if (isHeaderLoading) {
      return const ContactMessagesEvidencePresentation(
        title: 'Loading contact messages',
      );
    }

    final resolvedLabel = headerContext?.contactName.trim();
    final contactLabel = resolvedLabel == null || resolvedLabel.isEmpty
        ? 'this contact'
        : resolvedLabel;
    return ContactMessagesEvidencePresentation(
      title: filterHandleId == null
          ? 'All messages from $contactLabel'
          : 'Messages from $contactLabel',
    );
  }

  final String title;
}
