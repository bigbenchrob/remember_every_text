import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:macos_ui/macos_ui.dart';

import '../../../../config/theme/colors/theme_colors.dart';
import '../../../../config/theme/spacing/app_spacing.dart';
import '../../../../config/theme/theme_typography.dart';
import '../../../../essentials/navigation/domain/navigation_constants.dart';
import '../../../../essentials/navigation/domain/sidebar_mode.dart';
import '../../../../essentials/navigation/feature_level_providers.dart';
import '../../application/view_spec/resolver_tools/search_result_context_provider.dart';
import '../view_model/shared/hydration/messages_for_handle_provider.dart';
import '../widgets/message_card.dart';

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
    final contextAsync = ref.watch(
      searchResultContextProvider(
        messageId: messageId,
        chatId: chatId,
        beforeCount: beforeCount,
        afterCount: afterCount,
      ),
    );

    Future<void> closeSidebar() async {
      ref
          .read(panelsViewStateProvider(SidebarMode.messages).notifier)
          .clear(panel: WindowPanel.right);
    }

    return ColoredBox(
      color: colors.surfaces.canvas,
      child: contextAsync.when(
        data: (state) {
          final selectedMessage = state.selectedMessage;
          if (selectedMessage == null) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
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
                  ),
                  PushButton(
                    controlSize: ControlSize.large,
                    secondary: true,
                    onPressed: closeSidebar,
                    child: const Text('Close sidebar'),
                  ),
                ],
              ),
            );
          }

          final visibleMessages = <MessageListItem>[
            ...state.beforeMessages,
            selectedMessage,
            ...state.afterMessages,
          ];

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Message context', style: typography.headline),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Focused view for a search result with nearby records from the same chat.',
                  style: typography.body.copyWith(
                    color: colors.content.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Chat $chatId • ${state.beforeMessages.length} before • ${state.afterMessages.length} after',
                  style: typography.caption1.copyWith(
                    color: colors.content.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Expanded(
                  child: ListView.separated(
                    itemCount: visibleMessages.length + 2,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: AppSpacing.sm),
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return _ContextBoundaryHint(
                          visible: state.hasMoreBefore,
                          text: 'Earlier messages exist above this window.',
                        );
                      }

                      if (index == visibleMessages.length + 1) {
                        return _ContextBoundaryHint(
                          visible: state.hasMoreAfter,
                          text: 'Later messages exist below this window.',
                        );
                      }

                      final message = visibleMessages[index - 1];
                      final isSelected = message.id == selectedMessage.id;

                      return _ContextMessageCard(
                        message: message,
                        isSelected: isSelected,
                      );
                    },
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                PushButton(
                  controlSize: ControlSize.large,
                  secondary: true,
                  onPressed: closeSidebar,
                  child: const Text('Close sidebar'),
                ),
              ],
            ),
          );
        },
        loading: () => Center(
          child: Text(
            'Loading message context…',
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
              Expanded(
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
              PushButton(
                controlSize: ControlSize.large,
                secondary: true,
                onPressed: closeSidebar,
                child: const Text('Close sidebar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ContextMessageCard extends ConsumerWidget {
  const _ContextMessageCard({required this.message, required this.isSelected});

  final MessageListItem message;
  final bool isSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: isSelected
            ? colors.messagePanels.selectionTint
            : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        border: isSelected
            ? Border.all(color: colors.messagePanels.accentBorderSoft)
            : null,
      ),
      child: Padding(
        padding: EdgeInsets.all(isSelected ? 4 : 0),
        child: MessageCard(
          message: message,
          layout: MessageCardLayout.analysis,
        ),
      ),
    );
  }
}

class _ContextBoundaryHint extends ConsumerWidget {
  const _ContextBoundaryHint({required this.visible, required this.text});

  final bool visible;
  final String text;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!visible) {
      return const SizedBox.shrink();
    }

    final typography = ref.watch(themeTypographyProvider);
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: typography.caption1.copyWith(
          color: colors.content.textSecondary,
        ),
      ),
    );
  }
}
