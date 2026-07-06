import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:macos_ui/macos_ui.dart';

import '../../../../config/theme/colors/theme_colors.dart';
import '../../../../config/theme/spacing/app_spacing.dart';
import '../../../../config/theme/theme_typography.dart';
import '../../../../config/theme/widgets/layout/app_panel_bands.dart';
import '../../../../core/util/date_range_formatter.dart';
import '../../../../essentials/conversation_graph/presentation/widgets/conversation_favourite_button.dart';
import '../../../../essentials/conversation_graph/presentation/widgets/conversation_signature_card.dart';
import '../../../../essentials/navigation/feature_level_providers.dart'
    show panelActionsProvider;
import '../../application/message_evidence/message_evidence_identity.dart';
import '../../application/message_evidence/message_evidence_spine_provider.dart';
import '../../application/sidebar_cassette_spec/resolver_tools/conversation_signature_display_provider.dart';
import '../../domain/message_evidence/message_evidence_scope.dart';
import '../../domain/message_evidence/message_evidence_skeleton.dart';
import '../widgets/conversation_signature_card_presentation.dart';
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
    final conversationId = canonicalConversationEvidenceId(chatId);

    return ColoredBox(
      color: colors.messagePanels.coolPanelSurface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: AppPanelBands.sidePanelPadding,
            child: Text(
              'Conversation',
              style: typography.title1.copyWith(
                color: colors.content.textPrimary,
              ),
            ),
          ),
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

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _ConversationContextCardHeader(
                      conversationId: conversationId,
                      excerptMessageCount: beforeCount + afterCount + 1,
                    ),
                    Expanded(
                      child: MessageEvidenceTimelineView(
                        evidenceScope: evidenceScope,
                        skeleton: skeleton,
                        // Search is intentionally disabled for this bounded
                        // context-window scope: it is already a search-result
                        // evidence excerpt, not an independently navigable
                        // timeline.
                        headerData: MessageEvidenceHeaderModel(
                          title: 'Message context',
                          identityContextLine: 'Chat $chatId',
                          dateRangeLabel: _dateSpan(skeleton.entries),
                          countLabel:
                              '${beforeCount + afterCount + 1} message window',
                          scopeContextLine: 'Search result context',
                        ),
                        showHeader: false,
                        emptyMessage: 'No context messages found.',
                        anchorMessageId: skeleton.initialAnchorMessageId,
                      ),
                    ),
                  ],
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
  const _ConversationContextCardHeader({
    required this.conversationId,
    required this.excerptMessageCount,
  });

  final int conversationId;
  final int excerptMessageCount;

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

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        16,
        AppPanelBands.titleToPrimaryGap,
        16,
        0,
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: _contextIntroHeaderHeight),
        child: signaturesAsync.when(
          data: (signatures) {
            if (signatures.isEmpty) {
              return _ConversationContextIntro(
                excerptMessageCount: excerptMessageCount,
                labelStyle: _excerptLabelStyle(colors, typography),
                child: _ConversationContextFallbackHeader(
                  conversationId: conversationId,
                  colors: colors,
                  typography: typography,
                ),
              );
            }

            final signature = signatures.first;
            return _ConversationContextIntro(
              excerptMessageCount: excerptMessageCount,
              labelStyle: _excerptLabelStyle(colors, typography),
              child: ConversationSignatureCard(
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
              ),
            );
          },
          loading: () => Text(
            'Loading conversation...',
            style: typography.caption.copyWith(
              color: colors.content.textSecondary,
            ),
          ),
          error: (error, _) => _ConversationContextIntro(
            excerptMessageCount: excerptMessageCount,
            labelStyle: _excerptLabelStyle(colors, typography),
            child: _ConversationContextFallbackHeader(
              conversationId: conversationId,
              colors: colors,
              typography: typography,
            ),
          ),
        ),
      ),
    );
  }
}

class _ConversationContextIntro extends StatelessWidget {
  const _ConversationContextIntro({
    required this.child,
    required this.excerptMessageCount,
    required this.labelStyle,
  });

  final Widget child;
  final int excerptMessageCount;
  final TextStyle labelStyle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        child,
        const SizedBox(height: AppPanelBands.primaryToSecondaryGap),
        Text(_excerptLabel(excerptMessageCount), style: labelStyle),
        const SizedBox(height: AppPanelBands.secondaryToContentGap),
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

const double _contextIntroHeaderHeight = 132;

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
