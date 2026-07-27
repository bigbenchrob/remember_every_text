/// Stable presentation language for recovered-message evidence surfaces.
final class RecoveredEvidencePresentation {
  const RecoveredEvidencePresentation({
    required this.title,
    required this.description,
    required this.emptyMessage,
  });

  factory RecoveredEvidencePresentation.from({
    required int? contactId,
    required bool onlyNoHandleFromMe,
  }) {
    if (onlyNoHandleFromMe) {
      return const RecoveredEvidencePresentation(
        title: 'Recovered no-handle messages',
        description:
            'Recovered orphaned records that look outgoing but no longer retain handle linkage.',
        emptyMessage: 'No recovered no-handle outgoing messages were found.',
      );
    }
    if (contactId != null) {
      return const RecoveredEvidencePresentation(
        title: 'Recovered deleted messages',
        description:
            'Recovered deleted-message candidates associated with this contact.',
        emptyMessage:
            'No recovered deleted messages matched this contact scope.',
      );
    }
    return const RecoveredEvidencePresentation(
      title: 'Recovered deleted messages',
      description:
          'Source records recovered without normal conversation linkage.',
      emptyMessage: 'No recovered deleted messages have been projected yet.',
    );
  }

  final String title;
  final String description;
  final String emptyMessage;
}
