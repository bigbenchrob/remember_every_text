import '../conversations/conversation.dart';
import '../conversations/conversation_reader.dart';
import 'conversation_signature.dart';

class ConversationSignatureReader {
  const ConversationSignatureReader({required this.reader});

  final ConversationReader reader;

  Future<List<ConversationSignature>> readSignatures({int limit = 100}) async {
    final overviews = await reader.readOverviews(limit: limit);
    return _readSignaturesForOverviews(overviews);
  }

  Future<List<ConversationSignature>> readSignaturesByIds({
    required List<int> conversationIds,
  }) async {
    final overviews = await reader.readOverviewsByIds(
      conversationIds: conversationIds,
    );
    return _readSignaturesForOverviews(overviews);
  }

  Future<List<ConversationSignature>> _readSignaturesForOverviews(
    List<ConversationOverview> overviews,
  ) async {
    final traces = await reader.readActivityTraces(
      conversationIds: [
        for (final overview in overviews) overview.conversationId,
      ],
    );

    return [
      for (final overview in overviews)
        _signatureFromOverview(overview, traces[overview.conversationId]),
    ];
  }

  ConversationSignature _signatureFromOverview(
    ConversationOverview overview,
    ConversationActivityTrace? trace,
  ) {
    final participantLabels = overview.participantHandles.isEmpty
        ? const ['Unknown']
        : List<String>.unmodifiable(overview.participantHandles);
    return ConversationSignature(
      conversationId: overview.conversationId,
      title: _titleForParticipants(participantLabels),
      participantLabels: participantLabels,
      participantCount: overview.participantCount,
      isGroup: overview.isGroup,
      messageCount: overview.messageCount,
      attachmentCount: overview.attachmentCount,
      firstMessageAtUtc: overview.firstMessageAtUtc,
      lastMessageAtUtc: overview.lastMessageAtUtc,
      lastMessageText: overview.lastMessageText,
      activityMonths: [
        for (final month
            in trace?.months ?? const <ConversationActivityMonth>[])
          ConversationSignatureMonth(
            year: month.year,
            month: month.month,
            messageCount: month.messageCount,
          ),
      ],
    );
  }

  String _titleForParticipants(List<String> participants) {
    if (participants.isEmpty) {
      return 'Unknown';
    }
    if (participants.length == 1) {
      return participants.first;
    }
    if (participants.length == 2) {
      return '${participants[0]} and ${participants[1]}';
    }
    return '${participants[0]}, ${participants[1]} + ${participants.length - 2}';
  }
}
