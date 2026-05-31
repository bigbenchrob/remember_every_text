import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:macos_ui/macos_ui.dart';

import '../../../../config/theme/colors/theme_colors.dart';
import '../../../../config/theme/spacing/app_spacing.dart';
import '../../../../config/theme/theme_typography.dart';
import '../../../../essentials/navigation/domain/navigation_constants.dart';
import '../../../../essentials/navigation/domain/sidebar_mode.dart';
import '../../../../essentials/navigation/feature_level_providers.dart';
import '../../application/message_evidence/message_evidence_spine_provider.dart';
import '../../domain/message_evidence/message_evidence_scope.dart';
import '../../domain/message_evidence/message_evidence_skeleton.dart';
import '../widgets/message_evidence/message_evidence_header.dart';
import '../widgets/message_evidence/message_evidence_timeline_view.dart';

class SearchResultContextSidebarView extends ConsumerWidget {
  const SearchResultContextSidebarView({
    required this.messageId,
    required this.chatId,
    required this.beforeCount,
    required this.afterCount,
    super.key,
  });

  final int messageId;
  final int chatId;
  final int beforeCount;
  final int afterCount;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final typography = ref.watch(themeTypographyProvider);
    final evidenceScope = SearchResultContextEvidenceScope(
      messageId: messageId,
      chatId: chatId,
      beforeCount: beforeCount,
      afterCount: afterCount,
    );
    final skeletonAsync = ref.watch(
      messageEvidenceTimelineSkeletonProvider(scope: evidenceScope),
    );

    Future<void> closeSidebar() async {
      ref
          .read(panelsViewStateProvider(SidebarMode.messages).notifier)
          .clear(panel: WindowPanel.right);
    }

    return ColoredBox(
      color: colors.surfaces.canvas,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: skeletonAsync.when(
              data: (skeleton) {
                if (skeleton.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Message context', style: typography.headline),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          'The selected message could not be loaded from chat $chatId.',
                          style: typography.body,
                        ),
                      ],
                    ),
                  );
                }

                return MessageEvidenceTimelineView(
                  evidenceScope: evidenceScope,
                  skeleton: skeleton,
                  // Search is intentionally disabled for this bounded
                  // context-window scope: it is already a search-result
                  // evidence excerpt, not an independently navigable timeline.
                  headerData: MessageEvidenceHeaderModel(
                    title: 'Message context',
                    identityContextLine: 'Chat $chatId',
                    dateRangeLabel: _dateSpan(skeleton.entries),
                    countLabel:
                        '${beforeCount + afterCount + 1} message window',
                    scopeContextLine: 'Search result context',
                    statusLine:
                        'search result context • evidence skeleton • hydrate visible rows',
                  ),
                  emptyMessage: 'No context messages found.',
                  anchorMessageId: skeleton.initialAnchorMessageId,
                );
              },
              loading: () => Center(
                child: Text(
                  'Loading message context...',
                  style: typography.body.copyWith(
                    color: colors.content.textSecondary,
                  ),
                ),
              ),
              error: (error, _) => Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Message context', style: typography.headline),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'Unable to load context: $error',
                      style: typography.body,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: PushButton(
              controlSize: ControlSize.large,
              secondary: true,
              onPressed: closeSidebar,
              child: const Text('Close sidebar'),
            ),
          ),
        ],
      ),
    );
  }
}

String _formatDateLabel(DateTime value) {
  return DateFormat.yMMMd().format(value.toLocal());
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
