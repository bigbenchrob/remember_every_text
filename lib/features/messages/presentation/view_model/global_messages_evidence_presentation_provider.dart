import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../application/message_evidence/global_messages_search_session_provider.dart';
import '../../application/message_evidence/message_evidence_spine_provider.dart';
import '../../domain/message_evidence/message_evidence_scope.dart';
import '../../domain/message_evidence/message_evidence_search_mode.dart';
import '../../domain/message_evidence/message_evidence_skeleton.dart';
import 'global_messages_evidence_presentation.dart';

part 'global_messages_evidence_presentation_provider.g.dart';

/// Prepared source-view state shared by the global evidence view and its
/// page-level Track presentations.
///
/// This boundary owns the source-specific skeleton requests. Consumers receive
/// semantic presentation state rather than creating parallel evidence paths.
final class GlobalMessagesEvidencePresentationState {
  const GlobalMessagesEvidencePresentationState({
    required this.query,
    required this.mode,
    required this.evidenceScope,
    required this.allMessagesSkeleton,
    required this.visibleSkeleton,
    required this.labels,
    required this.investigationStatus,
  });

  final String query;
  final MessageEvidenceSearchMode mode;
  final MessageEvidenceScope evidenceScope;
  final AsyncValue<MessageEvidenceTimelineSkeleton> allMessagesSkeleton;
  final AsyncValue<MessageEvidenceTimelineSkeleton> visibleSkeleton;
  final GlobalMessagesEvidenceHeaderLabels? labels;
  final SearchInvestigationStatusPresentationModel? investigationStatus;
}

@riverpod
GlobalMessagesEvidencePresentationState globalMessagesEvidencePresentation(
  Ref ref, {
  DateTime? monthAnchor,
}) {
  final session = ref.watch(
    globalMessagesSearchSessionProvider(monthAnchor: monthAnchor),
  );
  final query = session.query.trim();
  const allMessagesScope = GlobalMessagesEvidenceScope();
  final evidenceScope = query.isEmpty
      ? allMessagesScope
      : MessageSearchEvidenceScope(query: query, mode: session.mode);
  final allMessagesSkeleton = ref.watch(
    messageEvidenceTimelineSkeletonProvider(scope: allMessagesScope),
  );
  final visibleSkeleton = query.isEmpty
      ? allMessagesSkeleton
      : ref.watch(
          messageEvidenceTimelineSkeletonProvider(scope: evidenceScope),
        );
  final allMessages = allMessagesSkeleton.valueOrNull;
  final visibleMessages = visibleSkeleton.valueOrNull;
  final labels = allMessages == null
      ? null
      : globalMessagesEvidenceHeaderLabels(
          allMessagesSkeleton: allMessages,
          visibleSkeleton:
              visibleMessages ??
              const MessageEvidenceTimelineSkeleton(entries: []),
          query: query,
          hasMatchesLoaded: query.isEmpty || visibleSkeleton.hasValue,
          monthAnchor: monthAnchor,
        );
  final investigationStatus = searchInvestigationStatusPresentationModel(
    query: query,
    monthAnchor: monthAnchor,
    isSearching:
        query.isNotEmpty &&
        visibleSkeleton.isLoading &&
        !visibleSkeleton.hasValue,
  );

  return GlobalMessagesEvidencePresentationState(
    query: query,
    mode: session.mode,
    evidenceScope: evidenceScope,
    allMessagesSkeleton: allMessagesSkeleton,
    visibleSkeleton: visibleSkeleton,
    labels: labels,
    investigationStatus: investigationStatus,
  );
}
