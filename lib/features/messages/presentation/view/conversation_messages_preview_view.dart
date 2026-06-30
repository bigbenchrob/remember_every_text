import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../../application/message_evidence/conversation_evidence_header_context_provider.dart';
import '../../application/message_evidence/message_evidence_spine_provider.dart';
import '../../domain/message_evidence/message_evidence_scope.dart';
import '../../domain/message_evidence/message_evidence_search_mode.dart';
import '../../domain/message_evidence/message_evidence_skeleton.dart';
import '../widgets/message_evidence/message_evidence_header.dart';
import '../widgets/message_evidence/message_evidence_timeline_view.dart';

class ConversationMessagesPreviewView extends ConsumerStatefulWidget {
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
  ConsumerState<ConversationMessagesPreviewView> createState() =>
      _ConversationMessagesPreviewViewState();
}

class _ConversationMessagesPreviewViewState
    extends ConsumerState<ConversationMessagesPreviewView> {
  late final TextEditingController _searchController = TextEditingController(
    text: widget.searchQuery?.trim() ?? '',
  );
  var _query = '';
  var _searchMode = MessageEvidenceSearchMode.allTerms;

  @override
  void initState() {
    super.initState();
    _query = _searchController.text;
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _query = _searchController.text;
    });
  }

  @override
  Widget build(BuildContext context) {
    final evidenceScope = ConversationEvidenceScope(
      conversationId: widget.conversationId,
    );
    final normalizedQuery = _query.trim();
    final skeletonAsync = ref.watch(
      messageEvidenceTimelineSkeletonProvider(scope: evidenceScope),
    );
    final matchingIdsAsync = normalizedQuery.isEmpty
        ? null
        : ref.watch(
            messageEvidenceTextMatchIdsProvider(
              scope: evidenceScope,
              query: normalizedQuery,
              mode: _searchMode,
            ),
          );
    final headerContextAsync = ref.watch(
      conversationEvidenceHeaderContextProvider(
        conversationId: widget.conversationId,
      ),
    );

    return skeletonAsync.when(
      skipLoadingOnReload: true,
      skipLoadingOnRefresh: true,
      data: (skeleton) {
        final headerContext = headerContextAsync.valueOrNull;
        final matchingIds = matchingIdsAsync?.valueOrNull;
        final isMatchingLoaded = matchingIdsAsync?.hasValue ?? false;
        final visibleSkeleton = _visibleSkeleton(
          skeleton: skeleton,
          query: normalizedQuery,
          matchingIds: matchingIds,
          isMatchingLoaded: isMatchingLoaded,
        );
        return MessageEvidenceTimelineView(
          evidenceScope: evidenceScope,
          skeleton: visibleSkeleton,
          headerData: MessageEvidenceHeaderModel(
            title:
                'Conversation with ${headerContext?.title ?? 'Unknown participants'}',
            dateRangeLabel: _dateRangeLabel(headerContext),
            countLabel: _countLabel(
              headerContext,
              skeleton.totalCount,
              normalizedQuery,
              matchingIds,
              isMatchingLoaded,
            ),
            activeScopeLabel: _activeScopeLabel(normalizedQuery),
            statusLine: _statusLine(normalizedQuery),
            searchConfig: MessageEvidenceHeaderSearchConfig(
              controller: _searchController,
              placeholder: 'Search this conversation',
              mode: _searchMode,
              onModeChanged: (mode) {
                setState(() {
                  _searchMode = mode;
                });
              },
            ),
          ),
          emptyMessage: _emptyMessage(
            query: normalizedQuery,
            isMatchingLoaded: isMatchingLoaded,
          ),
          anchorMessageId: widget.anchorMessageId,
          highlightQuery: normalizedQuery,
        );
      },
      loading: () =>
          const Center(child: Text('Loading conversation graph timeline...')),
      error: (error, stackTrace) =>
          Center(child: Text('Conversation graph timeline failed: $error')),
    );
  }

  String? _dateRangeLabel(ConversationEvidenceHeaderContext? headerContext) {
    final dateSpan = _conversationDateSpan(headerContext);
    if (dateSpan.isEmpty) {
      return null;
    }
    return dateSpan;
  }

  String _countLabel(
    ConversationEvidenceHeaderContext? headerContext,
    int skeletonCount,
    String query,
    List<int>? matchingIds,
    bool isMatchingLoaded,
  ) {
    final messageCount = headerContext?.messageCount ?? skeletonCount;
    if (query.isNotEmpty) {
      if (isMatchingLoaded) {
        return '${_formatCount(matchingIds?.length ?? 0)} of '
            '${_formatCount(messageCount)} messages match "$query"';
      }
      return 'matching messages...';
    }
    return '${_formatCount(messageCount)} messages';
  }

  String? _activeScopeLabel(String query) {
    final parts = <String>[];
    if (query.isNotEmpty) {
      parts.add('Message text contains "$query"');
    }
    if (widget.anchorMessageId != null) {
      parts.add('Anchored at message ${widget.anchorMessageId}');
    }
    if (parts.isEmpty) {
      return null;
    }
    return parts.join(' • ');
  }

  String _statusLine(String query) {
    final parts = <String>[
      'evidence skeleton',
      'full conversation',
      'hydrate visible rows',
    ];
    if (query.isNotEmpty) {
      parts.add('search context "$query"');
    }
    if (widget.anchorMessageId != null) {
      parts.add('anchor ${widget.anchorMessageId}');
    }
    return parts.join(' • ');
  }
}

MessageEvidenceTimelineSkeleton _visibleSkeleton({
  required MessageEvidenceTimelineSkeleton skeleton,
  required String query,
  required List<int>? matchingIds,
  required bool isMatchingLoaded,
}) {
  if (query.isEmpty) {
    return skeleton;
  }
  if (!isMatchingLoaded) {
    return const MessageEvidenceTimelineSkeleton(entries: []);
  }
  return skeleton.filteredByMessageIds(matchingIds ?? const <int>[]);
}

String _emptyMessage({required String query, required bool isMatchingLoaded}) {
  if (query.isEmpty) {
    return 'No messages found for this conversation.';
  }
  if (!isMatchingLoaded) {
    return 'Matching conversation messages...';
  }
  return 'No conversation messages match "$query".';
}

String _conversationDateSpan(ConversationEvidenceHeaderContext? headerContext) {
  final first = _formatDateLabel(headerContext?.firstMessageAtUtc);
  final last = _formatDateLabel(headerContext?.lastMessageAtUtc);
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
