import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:macos_ui/macos_ui.dart';

import '../../../../config/theme/colors/theme_colors.dart';
import '../../../../config/theme/spacing/app_spacing.dart';
import '../../../../config/theme/theme_typography.dart';
import '../../../../config/theme/widgets/layout/vertical_column_bands.dart';
import '../../../../core/util/date_range_formatter.dart';
import '../../../../essentials/navigation/feature_level_providers.dart'
    show panelActionsProvider;
import '../../../messages/application/message_evidence/message_evidence_spine_provider.dart';
import '../../../messages/domain/message_evidence/message_evidence_scope.dart';
import '../../../messages/domain/message_evidence/message_evidence_skeleton.dart';
import '../../../messages/presentation/widgets/message_evidence/message_evidence_header.dart';
import '../../../messages/presentation/widgets/message_evidence/message_evidence_timeline_view.dart';
import '../../application/conversation_signatures/conversation_signature_display_provider.dart'
    show
        ConversationSignatureDisplayByIdsRequest,
        conversationSignatureDisplayByIdsProvider;
import '../widgets/conversation_favourite_button.dart';
import '../widgets/conversation_signature_card.dart';
import '../widgets/conversation_signature_card_presentation.dart';

class ConversationExcerptPanelView extends ConsumerWidget {
  const ConversationExcerptPanelView({
    required this.conversationId,
    required this.anchorMessageId,
    required this.beforeCount,
    required this.afterCount,
    super.key,
  });

  final int conversationId;
  final int anchorMessageId;
  final int beforeCount;
  final int afterCount;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final typography = ref.watch(themeTypographyProvider);
    final evidenceScope = ConversationExcerptEvidenceScope(
      conversationId: conversationId,
      anchorMessageId: anchorMessageId,
      beforeCount: beforeCount,
      afterCount: afterCount,
    );
    final skeletonAsync = ref.watch(
      messageEvidenceTimelineSkeletonProvider(scope: evidenceScope),
    );
    return ColoredBox(
      color: colors.messagePanels.coolPanelSurface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: skeletonAsync.when(
              skipLoadingOnReload: true,
              skipLoadingOnRefresh: true,
              data: (skeleton) {
                if (skeleton.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Conversation', style: typography.headline),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          'The selected message could not be loaded from conversation $conversationId.',
                          style: typography.body,
                        ),
                      ],
                    ),
                  );
                }

                return _ConversationExcerptColumnFrame(
                  title: Text(
                    'Conversation',
                    style: typography.title1.copyWith(
                      color: colors.content.textPrimary,
                    ),
                  ),
                  contextContent: _ConversationExcerptContextBand(
                    conversationId: conversationId,
                    label: _excerptLabel(beforeCount + afterCount + 1),
                    colors: colors,
                    typography: typography,
                  ),
                  content: MessageEvidenceTimelineView(
                    evidenceScope: evidenceScope,
                    skeleton: skeleton,
                    // Search is intentionally disabled for this bounded
                    // context-window scope: it is already a search-result
                    // evidence excerpt, not an independently navigable
                    // timeline.
                    headerData: MessageEvidenceHeaderModel(
                      title: 'Conversation excerpt',
                      identityContextLine: 'Conversation $conversationId',
                      dateRangeLabel: _dateSpan(skeleton.entries),
                      countLabel:
                          '${beforeCount + afterCount + 1} message window',
                      scopeContextLine: 'Conversation excerpt',
                    ),
                    showHeader: false,
                    emptyMessage: 'No context messages found.',
                    anchorMessageId: skeleton.initialAnchorMessageId,
                  ),
                );
              },
              loading: () => _ConversationExcerptColumnFrame(
                title: Text(
                  'Conversation',
                  style: typography.title1.copyWith(
                    color: colors.content.textPrimary,
                  ),
                ),
                contextContent: Text(
                  'Loading conversation...',
                  style: typography.caption.copyWith(
                    color: colors.content.textSecondary,
                  ),
                ),
                content: const SizedBox.shrink(),
              ),
              error: (error, _) => _ConversationExcerptColumnFrame(
                title: Text(
                  'Conversation',
                  style: typography.title1.copyWith(
                    color: colors.content.textPrimary,
                  ),
                ),
                contextContent: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Unable to load context',
                      style: typography.headline.copyWith(
                        color: colors.content.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$error',
                      style: typography.body.copyWith(
                        color: colors.content.textSecondary,
                      ),
                    ),
                  ],
                ),
                content: const SizedBox.shrink(),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: PushButton(
              controlSize: ControlSize.large,
              secondary: true,
              onPressed: () {
                ref.read(panelActionsProvider.notifier).closeActiveRightPanel();
              },
              child: const Text('Close sidebar'),
            ),
          ),
        ],
      ),
    );
  }
}

class _ConversationContextCardHeader extends ConsumerWidget {
  const _ConversationContextCardHeader({required this.conversationId});

  final int conversationId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final typography = ref.watch(themeTypographyProvider);
    final signaturesAsync = ref.watch(
      conversationSignatureDisplayByIdsProvider(
        request: ConversationSignatureDisplayByIdsRequest(
          conversationIds: [conversationId],
        ),
      ),
    );

    return signaturesAsync.when(
      data: (signatures) {
        if (signatures.isEmpty) {
          return _ConversationContextFallbackHeader(
            conversationId: conversationId,
            colors: colors,
            typography: typography,
          );
        }

        final signature = signatures.first;
        return ConversationSignatureCard(
          signature: conversationSignatureCardDataFromDisplay(signature),
          style: conversationSignatureContextHeaderCardStyle(
            colors,
            typography,
          ),
          monthColorForMessageCount:
              conversationSignatureMonthColorForMessageCount,
          trailing: ConversationFavouriteButton(
            conversationId: signature.conversationId,
          ),
        );
      },
      loading: () => Text(
        'Loading conversation...',
        style: typography.caption.copyWith(color: colors.content.textSecondary),
      ),
      error: (error, _) => _ConversationContextFallbackHeader(
        conversationId: conversationId,
        colors: colors,
        typography: typography,
      ),
    );
  }
}

class _ConversationExcerptColumnFrame extends StatelessWidget {
  const _ConversationExcerptColumnFrame({
    required this.title,
    required this.contextContent,
    required this.content,
  });

  final Widget title;
  final Widget contextContent;
  final Widget content;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TitleColumnBand(child: title),
        ContextColumnBand(child: contextContent),
        Expanded(child: content),
      ],
    );
  }
}

class _ConversationExcerptContextBand extends StatelessWidget {
  const _ConversationExcerptContextBand({
    required this.conversationId,
    required this.label,
    required this.colors,
    required this.typography,
  });

  final int conversationId;
  final String label;
  final ThemeColors colors;
  final ThemeTypography typography;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _ConversationContextCardHeader(conversationId: conversationId),
        const SizedBox(height: 10),
        Text(label, style: _excerptLabelStyle(colors, typography)),
      ],
    );
  }
}

class _ConversationContextFallbackHeader extends StatelessWidget {
  const _ConversationContextFallbackHeader({
    required this.conversationId,
    required this.colors,
    required this.typography,
  });

  final int conversationId;
  final ThemeColors colors;
  final ThemeTypography typography;

  @override
  Widget build(BuildContext context) {
    return Text(
      'Conversation $conversationId',
      style: typography.headline.copyWith(color: colors.content.textPrimary),
    );
  }
}

TextStyle _excerptLabelStyle(ThemeColors colors, ThemeTypography typography) {
  return typography.caption.copyWith(
    color: colors.content.textSecondary.withValues(alpha: 0.78),
    fontWeight: FontWeight.w500,
  );
}

String _excerptLabel(int count) {
  if (count <= 1) {
    return 'Excerpt centered on the chosen message';
  }
  return '$count-message excerpt centered on the chosen message';
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
  return DateRangeFormatter.formatMessageEvidenceRange(
    start: dates.first,
    end: dates.last,
    itemCount: entries.length,
    emptyLabel: 'No dated messages',
  );
}

DateTime? _parseDate(String? value) {
  if (value == null || value.isEmpty) {
    return null;
  }
  return DateTime.tryParse(value);
}
