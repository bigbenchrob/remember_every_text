import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:macos_ui/macos_ui.dart';

import '../../../../config/theme/colors/theme_colors.dart';
import '../../../../config/theme/spacing/app_spacing.dart';
import '../../../../config/theme/theme_typography.dart';
import '../../application/message_evidence/message_evidence_spine_provider.dart';
import '../../domain/message_evidence/message_evidence_scope.dart';
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
            headerData: MessageEvidenceHeaderData(
              title: presentation.title,
              subtitleParts: [
                presentation.description,
                _countLabel(
                  visibleCount: visibleSkeleton.totalCount,
                  totalCount: skeleton.totalCount,
                  query: normalizedQuery,
                  isMatching: matchingIdsAsync?.hasValue ?? false,
                ),
              ],
              scopeIndicator: widget.scrollToDate == null
                  ? null
                  : _RecoveredScrollIndicator(
                      scrollToDate: widget.scrollToDate!,
                    ),
              controls: _RecoveredSearchField(controller: _searchController),
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

class _RecoveredSearchField extends StatelessWidget {
  const _RecoveredSearchField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 260,
      child: MacosTextField(
        controller: controller,
        placeholder: 'Filter recovered messages',
        clearButtonMode: OverlayVisibilityMode.editing,
      ),
    );
  }
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
