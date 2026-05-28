import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../essentials/conversation_graph/application/conversations/conversation.dart';
import '../../../../essentials/conversation_graph/application/conversations/conversation_reader_provider.dart';
import '../../../chats/application/conversation_browser/contact_handle_label_provider.dart';
import '../../application/message_evidence/message_evidence_spine_provider.dart';
import '../../domain/message_evidence/message_evidence_scope.dart';
import '../widgets/message_evidence/message_evidence_header.dart';
import '../widgets/message_evidence/message_evidence_timeline_view.dart';

class ConversationMessagesPreviewView extends ConsumerWidget {
  const ConversationMessagesPreviewView({
    required this.conversationId,
    this.anchorMessageId,
    this.searchQuery,
    super.key,
  });

  final int conversationId;
  final int? anchorMessageId;
  final String? searchQuery;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final evidenceScope = ConversationEvidenceScope(
      conversationId: conversationId,
    );
    final skeletonAsync = ref.watch(
      messageEvidenceTimelineSkeletonProvider(scope: evidenceScope),
    );
    final overviewsAsync = ref.watch(
      conversationOverviewsProvider(limit: 1000),
    );
    final labelsAsync = ref.watch(contactHandleLabelsProvider);

    return skeletonAsync.when(
      data: (skeleton) {
        final overview = _overviewForConversation(
          overviewsAsync.valueOrNull,
          conversationId,
        );
        return MessageEvidenceTimelineView(
          evidenceScope: evidenceScope,
          skeleton: skeleton,
          headerData: MessageEvidenceHeaderModel(
            title:
                'Conversation: ${_conversationTitle(overview, labelsAsync.valueOrNull)}',
            dateRangeLabel: _dateRangeLabel(overview),
            countLabel: _countLabel(overview, skeleton.totalCount),
            activeScopeLabel: _activeScopeLabel(),
            statusLine: _statusLine(),
          ),
          emptyMessage: 'No graph messages found for this conversation.',
          anchorMessageId: anchorMessageId,
          highlightQuery: searchQuery ?? '',
        );
      },
      loading: () =>
          const Center(child: Text('Loading conversation graph timeline...')),
      error: (error, stackTrace) =>
          Center(child: Text('Conversation graph timeline failed: $error')),
    );
  }

  ConversationOverview? _overviewForConversation(
    List<ConversationOverview>? overviews,
    int conversationId,
  ) {
    if (overviews == null) {
      return null;
    }
    for (final overview in overviews) {
      if (overview.conversationId == conversationId) {
        return overview;
      }
    }
    return null;
  }

  String? _dateRangeLabel(ConversationOverview? overview) {
    final dateSpan = _conversationDateSpan(overview);
    if (dateSpan.isEmpty) {
      return null;
    }
    return dateSpan;
  }

  String _countLabel(ConversationOverview? overview, int skeletonCount) {
    final messageCount = overview?.messageCount ?? skeletonCount;
    return '${_formatCount(messageCount)} messages';
  }

  String? _activeScopeLabel() {
    final parts = <String>[];
    final normalizedSearchQuery = searchQuery?.trim();
    if (normalizedSearchQuery != null && normalizedSearchQuery.isNotEmpty) {
      parts.add('Search context "$normalizedSearchQuery"');
    }
    if (anchorMessageId != null) {
      parts.add('Anchored at message $anchorMessageId');
    }
    if (parts.isEmpty) {
      return null;
    }
    return parts.join(' • ');
  }

  String _statusLine() {
    final parts = <String>[
      'graph skeleton',
      'full conversation',
      'hydrate visible rows',
    ];
    final normalizedSearchQuery = searchQuery?.trim();
    if (normalizedSearchQuery != null && normalizedSearchQuery.isNotEmpty) {
      parts.add('search context "$normalizedSearchQuery"');
    }
    if (anchorMessageId != null) {
      parts.add('anchor $anchorMessageId');
    }
    return parts.join(' • ');
  }
}

String _conversationTitle(
  ConversationOverview? overview,
  Map<String, ContactHandleLabel>? labels,
) {
  final participants = _conversationParticipants(overview, labels);
  if (participants.isEmpty) {
    return 'Unknown participants';
  }
  if (participants.length == 1) {
    return participants.first;
  }
  if (participants.length == 2) {
    return '${participants[0]} and ${participants[1]}';
  }
  return '${participants[0]}, ${participants[1]} + ${participants.length - 2} more';
}

List<String> _conversationParticipants(
  ConversationOverview? overview,
  Map<String, ContactHandleLabel>? labels,
) {
  final handles = overview?.participantHandles ?? const <String>[];
  final participants = <String>[];
  final seen = <String>{};
  for (final handle in handles) {
    final trimmed = handle.trim();
    if (trimmed.isEmpty) {
      continue;
    }
    final label =
        labels?[contactHandleLabelKeyForTesting(trimmed)]?.displayName;
    final participant = label ?? trimmed;
    if (seen.add(participant.toLowerCase())) {
      participants.add(participant);
    }
  }
  return participants;
}

String _conversationDateSpan(ConversationOverview? overview) {
  final first = _formatDateLabel(overview?.firstMessageAtUtc);
  final last = _formatDateLabel(overview?.lastMessageAtUtc);
  if (first == null && last == null) {
    return '';
  }
  if (first == null) {
    return 'through $last';
  }
  if (last == null || first == last) {
    return first;
  }
  return '$first to $last';
}

String? _formatDateLabel(String? value) {
  if (value == null || value.isEmpty) {
    return null;
  }
  final parsed = DateTime.tryParse(value);
  if (parsed == null) {
    return value;
  }
  return DateFormat.yMMMd().format(parsed.toLocal());
}

String _formatCount(int count) {
  return NumberFormat.decimalPattern().format(count);
}
