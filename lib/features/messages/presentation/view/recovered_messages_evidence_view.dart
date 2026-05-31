import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../config/theme/colors/theme_colors.dart';
import '../../../../config/theme/spacing/app_spacing.dart';
import '../../../../config/theme/theme_typography.dart';
import '../../application/message_evidence/message_evidence_spine_provider.dart';
import '../../domain/message_evidence/message_evidence_scope.dart';
import '../../domain/message_evidence/message_evidence_search_mode.dart';
import '../../domain/message_evidence/message_evidence_skeleton.dart';
import '../widgets/message_evidence/message_evidence_header.dart';
import '../widgets/message_evidence/message_evidence_timeline_view.dart';

class RecoveredMessagesEvidenceView extends ConsumerStatefulWidget {
  const RecoveredMessagesEvidenceView({
    this.contactId,
    this.scrollToDate,
    this.onlyNoHandleFromMe = false,
    super.key,
  });

  final int? contactId;
  final DateTime? scrollToDate;
  final bool onlyNoHandleFromMe;

  @override
  ConsumerState<RecoveredMessagesEvidenceView> createState() =>
      _RecoveredMessagesEvidenceViewState();
}

class _RecoveredMessagesEvidenceViewState
    extends ConsumerState<RecoveredMessagesEvidenceView> {
  late final TextEditingController _searchController = TextEditingController();
  String _query = '';
  MessageEvidenceSearchMode _searchMode = MessageEvidenceSearchMode.allTerms;

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
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final typography = ref.watch(themeTypographyProvider);
    final scope = RecoveredMessagesEvidenceScope(
      contactId: widget.contactId,
      onlyNoHandleFromMe: widget.onlyNoHandleFromMe,
    );
    final normalizedQuery = _query.trim();
    final skeletonAsync = ref.watch(
      messageEvidenceTimelineSkeletonProvider(scope: scope),
    );
    final matchingIdsAsync = normalizedQuery.isEmpty
        ? null
        : ref.watch(
            messageEvidenceTextMatchIdsProvider(
              scope: scope,
              query: normalizedQuery,
              mode: _searchMode,
            ),
          );
    final presentation = _RecoveredEvidencePresentation.from(
      contactId: widget.contactId,
      onlyNoHandleFromMe: widget.onlyNoHandleFromMe,
    );

    return ColoredBox(
      color: colors.messagePanels.coolPanelSurface,
      child: skeletonAsync.when(
        data: (skeleton) {
          final visibleSkeleton = _visibleSkeleton(
            skeleton: skeleton,
            matchingIds: matchingIdsAsync?.valueOrNull,
            query: normalizedQuery,
          );
          return MessageEvidenceTimelineView(
            evidenceScope: scope,
            skeleton: visibleSkeleton,
            headerData: MessageEvidenceHeaderModel(
              title: presentation.title,
              scopeContextLine: presentation.description,
              dateRangeLabel: _dateSpan(visibleSkeleton.entries),
              countLabel: _countLabel(
                visibleCount: visibleSkeleton.totalCount,
                totalCount: skeleton.totalCount,
                query: normalizedQuery,
                isMatching: matchingIdsAsync?.hasValue ?? false,
              ),
              activeScopeLabel: normalizedQuery.isEmpty
                  ? null
                  : 'Message text contains "$normalizedQuery"',
              activeScopeIndicator: widget.scrollToDate == null
                  ? null
                  : _RecoveredScrollIndicator(
                      scrollToDate: widget.scrollToDate!,
                    ),
              searchConfig: MessageEvidenceHeaderSearchConfig(
                controller: _searchController,
                placeholder: 'Search recovered messages',
                mode: _searchMode,
                onModeChanged: (mode) {
                  setState(() {
                    _searchMode = mode;
                  });
                },
              ),
            ),
            emptyMessage: normalizedQuery.isEmpty
                ? presentation.emptyMessage
                : 'No recovered messages match "$normalizedQuery".',
            monthAnchor: widget.scrollToDate,
            highlightQuery: normalizedQuery,
          );
        },
        loading: () => Center(
          child: Text(
            'Loading recovered messages...',
            style: typography.body.copyWith(
              color: colors.content.textSecondary,
            ),
          ),
        ),
        error: (error, _) => Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Unable to load recovered messages: $error',
            style: typography.body,
          ),
        ),
      ),
    );
  }
}

MessageEvidenceTimelineSkeleton _visibleSkeleton({
  required MessageEvidenceTimelineSkeleton skeleton,
  required List<int>? matchingIds,
  required String query,
}) {
  if (query.isEmpty) {
    return skeleton;
  }
  final matchingIdSet = (matchingIds ?? const <int>[]).toSet();
  return MessageEvidenceTimelineSkeleton(
    entries: [
      for (final entry in skeleton.entries)
        if (matchingIdSet.contains(entry.messageId)) entry,
    ],
    initialAnchorMessageId: skeleton.initialAnchorMessageId,
  );
}

String _countLabel({
  required int visibleCount,
  required int totalCount,
  required String query,
  required bool isMatching,
}) {
  if (query.isEmpty) {
    return '$totalCount recovered messages';
  }
  if (!isMatching) {
    return 'matching recovered messages...';
  }
  return '$visibleCount of $totalCount recovered messages match "$query"';
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
  return '${value.year}-${value.month.toString().padLeft(2, '0')}-'
      '${value.day.toString().padLeft(2, '0')}';
}

class _RecoveredEvidencePresentation {
  const _RecoveredEvidencePresentation({
    required this.title,
    required this.description,
    required this.emptyMessage,
  });

  factory _RecoveredEvidencePresentation.from({
    required int? contactId,
    required bool onlyNoHandleFromMe,
  }) {
    if (onlyNoHandleFromMe) {
      return const _RecoveredEvidencePresentation(
        title: 'Recovered no-handle messages',
        description:
            'Recovered orphaned records that look outgoing but no longer retain handle linkage.',
        emptyMessage: 'No recovered no-handle outgoing messages were found.',
      );
    }
    if (contactId != null) {
      return const _RecoveredEvidencePresentation(
        title: 'Recovered deleted messages',
        description:
            'Recovered deleted-message candidates associated with this contact.',
        emptyMessage:
            'No recovered deleted messages matched this contact scope.',
      );
    }
    return const _RecoveredEvidencePresentation(
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

class _RecoveredScrollIndicator extends StatelessWidget {
  const _RecoveredScrollIndicator({required this.scrollToDate});

  final DateTime scrollToDate;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: AppSpacing.sm),
      child: Text(
        '${scrollToDate.year}-${scrollToDate.month.toString().padLeft(2, '0')}',
      ),
    );
  }
}
