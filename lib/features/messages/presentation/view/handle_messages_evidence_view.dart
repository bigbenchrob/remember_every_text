import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../handles/feature_level_providers.dart';
import '../../application/message_evidence/message_evidence_spine_provider.dart';
import '../../domain/message_evidence/message_evidence_scope.dart';
import '../../domain/message_evidence/message_evidence_search_mode.dart';
import '../../domain/message_evidence/message_evidence_skeleton.dart';
import '../widgets/message_evidence/message_evidence_header.dart';
import '../widgets/message_evidence/message_evidence_timeline_view.dart';

class HandleMessagesEvidenceView extends ConsumerStatefulWidget {
  const HandleMessagesEvidenceView({required this.handleId, super.key});

  final int handleId;

  @override
  ConsumerState<HandleMessagesEvidenceView> createState() =>
      _HandleMessagesEvidenceViewState();
}

class _HandleMessagesEvidenceViewState
    extends ConsumerState<HandleMessagesEvidenceView> {
  late final TextEditingController _searchController = TextEditingController();
  var _query = '';
  var _searchMode = MessageEvidenceSearchMode.allTerms;

  @override
  void initState() {
    super.initState();
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
    final evidenceScope = HandleMessagesEvidenceScope(
      handleId: widget.handleId,
    );
    final normalizedQuery = _query.trim();
    final skeletonAsync = ref.watch(
      messageEvidenceTimelineSkeletonProvider(scope: evidenceScope),
    );
    final displayNameAsync = ref.watch(
      handleDisplayNameProvider(handleId: widget.handleId),
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

    return skeletonAsync.when(
      data: (skeleton) {
        return MessageEvidenceTimelineView(
          evidenceScope: evidenceScope,
          skeleton: skeleton,
          headerData: MessageEvidenceHeaderModel(
            title: 'Messages for ${_handleLabel(displayNameAsync.valueOrNull)}',
            dateRangeLabel: _dateSpan(skeleton.entries),
            countLabel: _countLabel(
              totalCount: skeleton.totalCount,
              query: normalizedQuery,
              matchingIds: matchingIdsAsync?.valueOrNull,
              isMatchingLoaded: matchingIdsAsync?.hasValue ?? false,
            ),
            scopeContextLine: 'Handle scope',
            activeScopeLabel: normalizedQuery.isEmpty
                ? null
                : 'Message text contains "$normalizedQuery"',
            statusLine:
                'evidence skeleton • handle scope • hydrate visible rows',
            searchConfig: MessageEvidenceHeaderSearchConfig(
              controller: _searchController,
              placeholder: 'Search messages from this handle',
              mode: _searchMode,
              onModeChanged: (mode) {
                setState(() {
                  _searchMode = mode;
                });
              },
            ),
          ),
          emptyMessage: 'No messages found for this handle.',
          highlightQuery: normalizedQuery,
        );
      },
      loading: () => const Center(child: Text('Loading handle messages...')),
      error: (error, stackTrace) =>
          Center(child: Text('Handle messages failed: $error')),
    );
  }
}

String _handleLabel(String? value) {
  final label = value?.trim();
  if (label == null || label.isEmpty) {
    return 'this handle';
  }
  return label;
}

String _countLabel({
  required int totalCount,
  required String query,
  required List<int>? matchingIds,
  required bool isMatchingLoaded,
}) {
  if (query.isNotEmpty) {
    if (isMatchingLoaded) {
      return '${_formatCount(matchingIds?.length ?? 0)} of '
          '${_formatCount(totalCount)} messages match "$query"';
    }
    return 'matching messages...';
  }
  return '${_formatCount(totalCount)} messages';
}

String _dateSpan(List<MessageEvidenceSkeletonEntry> entries) {
  final dates = [
    for (final entry in entries)
      if (_parseDate(entry.dateUtc) case final DateTime date) date,
  ];
  if (dates.isEmpty) {
    return 'No dated messages';
  }
  dates.sort();
  final first = _formatDateLabel(dates.first);
  final last = _formatDateLabel(dates.last);
  if (first == last) {
    return first;
  }
  return '$first to $last';
}

DateTime? _parseDate(String? value) {
  if (value == null || value.isEmpty) {
    return null;
  }
  return DateTime.tryParse(value);
}

String _formatDateLabel(DateTime value) {
  return DateFormat.yMMMd().format(value.toLocal());
}

String _formatCount(int count) {
  return NumberFormat.decimalPattern().format(count);
}
