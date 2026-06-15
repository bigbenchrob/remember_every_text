import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../config/theme/colors/theme_colors.dart';
import '../../../../config/theme/theme_typography.dart';
import '../../../../essentials/conversation_graph/presentation/widgets/conversation_favourite_button.dart';
import '../../../../essentials/conversation_graph/presentation/widgets/conversation_signature_card.dart';
import '../../../../essentials/navigation/domain/entities/view_spec.dart';
import '../../../../essentials/navigation/domain/navigation_constants.dart';
import '../../../../essentials/navigation/domain/sidebar_mode.dart';
import '../../../../essentials/navigation/feature_level_providers.dart';
import '../../application/sidebar_cassette_spec/resolver_tools/contact_conversation_signatures_provider.dart';
import '../../application/sidebar_cassette_spec/resolver_tools/conversation_signature_display_provider.dart';
import '../../domain/calendar_heatmap_timeline_data.dart';
import '../../domain/spec_classes/messages_view_spec.dart';
import 'calendar_heatmap_timeline_widget.dart';

class ContactGraphConversationSection extends ConsumerWidget {
  const ContactGraphConversationSection({
    required this.contactId,
    this.padding = const EdgeInsets.fromLTRB(20, 0, 20, 12),
    this.maxHeight = 220,
    super.key,
  });

  final int contactId;
  final EdgeInsetsGeometry padding;
  final double maxHeight;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final signaturesAsync = ref.watch(
      contactConversationSignaturesProvider(contactId: contactId),
    );

    return signaturesAsync.when(
      data: (signatureDisplays) {
        if (signatureDisplays.isEmpty) {
          return _ContactGraphConversationNotice(
            padding: padding,
            title: 'No conversations found',
            message:
                'The graph has no conversation edges for this contact yet.',
          );
        }

        return _ContactGraphConversationContent(
          signatureDisplays: signatureDisplays,
          padding: padding,
          maxHeight: maxHeight,
        );
      },
      loading: () => _ContactGraphConversationNotice(
        padding: padding,
        title: 'Loading conversations',
        message: 'Reading the source-scoped conversation graph.',
      ),
      error: (error, _) => _ContactGraphConversationNotice(
        padding: padding,
        title: 'Unable to load conversations',
        message: '$error',
      ),
    );
  }
}

class _ContactGraphConversationNotice extends ConsumerWidget {
  const _ContactGraphConversationNotice({
    required this.padding,
    required this.title,
    required this.message,
  });

  final EdgeInsetsGeometry padding;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final typography = ref.watch(themeTypographyProvider);

    return Padding(
      padding: padding,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.messagePanels.supportSurface,
          border: Border.all(color: colors.messagePanels.cardBorder),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: typography.headline),
              const SizedBox(height: 4),
              Text(message, style: typography.caption1),
            ],
          ),
        ),
      ),
    );
  }
}

class _ContactGraphConversationContent extends ConsumerStatefulWidget {
  const _ContactGraphConversationContent({
    required this.signatureDisplays,
    required this.padding,
    required this.maxHeight,
  });

  final List<ConversationSignatureDisplayModel> signatureDisplays;
  final EdgeInsetsGeometry padding;
  final double maxHeight;

  @override
  ConsumerState<_ContactGraphConversationContent> createState() =>
      _ContactGraphConversationContentState();
}

class _ContactGraphConversationContentState
    extends ConsumerState<_ContactGraphConversationContent> {
  @override
  Widget build(BuildContext context) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final typography = ref.watch(themeTypographyProvider);
    final cardStyle = _conversationSignatureCardStyle(colors, typography);
    final signatureDisplays = widget.signatureDisplays;

    return Padding(
      padding: widget.padding,
      child: SizedBox(
        width: double.infinity,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: widget.maxHeight),
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: signatureDisplays.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final signature = signatureDisplays[index];
              return ConversationSignatureCard(
                signature: _toCardData(signature),
                style: cardStyle,
                monthColorForMessageCount:
                    _conversationMonthColorForMessageCount,
                trailing: ConversationFavouriteButton(
                  conversationId: signature.conversationId,
                ),
                onPressed: () {
                  _showConversation(ref, signature.conversationId);
                },
              );
            },
          ),
        ),
      ),
    );
  }

  void _showConversation(WidgetRef ref, int conversationId) {
    ref
        .read(panelsViewStateProvider(SidebarMode.messages).notifier)
        .show(
          panel: WindowPanel.center,
          spec: ViewSpec.messages(
            MessagesSpec.forConversation(conversationId: conversationId),
          ),
        );
  }
}

ConversationSignatureCardData _toCardData(
  ConversationSignatureDisplayModel signature,
) {
  return ConversationSignatureCardData(
    conversationId: signature.conversationId,
    title: signature.title,
    participantCount: signature.participantCount,
    messageCount: signature.messageCount,
    firstMessageAtUtc: signature.firstMessageAtUtc,
    lastMessageAtUtc: signature.lastMessageAtUtc,
    activityMonths: signature.activityMonths,
  );
}

Color _conversationMonthColorForMessageCount(int messageCount) {
  return calendarHeatmapColorForIntensity(
    MonthIntensity.fromMessageCount(messageCount),
  );
}

ConversationSignatureCardStyle _conversationSignatureCardStyle(
  ThemeColors colors,
  ThemeTypography typography,
) {
  return ConversationSignatureCardStyle(
    backgroundColor: colors.surfaces.surface.withValues(alpha: 0.14),
    hoverBackgroundColor: colors.surfaces.hover,
    selectedBackgroundColor: colors.surfaces.selected,
    borderColor: colors.lines.borderSubtle.withValues(alpha: 0),
    hoverBorderColor: colors.lines.borderSubtle.withValues(alpha: 0.38),
    selectedBorderColor: colors.accents.selection.withValues(alpha: 0.58),
    titleStyle: typography.callout.copyWith(
      color: colors.content.textPrimary,
      fontWeight: FontWeight.w600,
    ),
    selectedTitleStyle: typography.callout.copyWith(
      color: colors.content.textPrimary,
      fontWeight: FontWeight.w600,
    ),
    participantSuffixStyle: typography.caption.copyWith(
      color: colors.content.textTertiary.withValues(alpha: 0.68),
      fontWeight: FontWeight.w500,
    ),
    summaryStyle: typography.caption.copyWith(
      color: colors.content.textTertiary.withValues(alpha: 0.78),
    ),
    emptyMonthBorderColor: colors.lines.borderSubtle,
  );
}
