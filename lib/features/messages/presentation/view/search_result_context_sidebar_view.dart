import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../../../../config/theme/colors/theme_colors.dart';
import '../../../../config/theme/spacing/app_spacing.dart';
import '../../../../config/theme/theme_typography.dart';
import '../../../../essentials/navigation/domain/navigation_constants.dart';
import '../../../../essentials/navigation/domain/sidebar_mode.dart';
import '../../../../essentials/navigation/feature_level_providers.dart';
import '../../application/view_spec/resolver_tools/message_context_anchor_provider.dart';
import '../../application/view_spec/resolver_tools/search_result_context_provider.dart';
import '../view_model/shared/hydration/messages_for_handle_provider.dart';
import '../widgets/message_card.dart';
import '../widgets/message_context_anchor_chrome.dart';

class SearchResultContextSidebarView extends HookConsumerWidget {
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
    final activeContextAnchor = ref.watch(messageContextAnchorProvider);
    final contextAsync = ref.watch(
      searchResultContextProvider(
        messageId: messageId,
        chatId: chatId,
        beforeCount: beforeCount,
        afterCount: afterCount,
      ),
    );
    final itemScrollController = useMemoized(ItemScrollController.new);
    final lastAppliedAnchorKey = useRef<String?>(null);
    final contextState = contextAsync.valueOrNull;
    final visibleMessageCount = contextState == null
        ? 0
        : contextState.beforeMessages.length +
              contextState.afterMessages.length +
              (contextState.selectedMessage == null ? 0 : 1);
    final anchorIndex = contextState?.selectedMessage == null
        ? null
        : contextState!.beforeMessages.length + 1;
    final anchorActivationKey =
        activeContextAnchor?.activationKey ??
        '$chatId::$messageId::$beforeCount::$afterCount';

    useEffect(
      () {
        if (contextState?.selectedMessage == null || anchorIndex == null) {
          return null;
        }

        final scrollKey = '$anchorActivationKey::$visibleMessageCount';
        if (lastAppliedAnchorKey.value == scrollKey) {
          return null;
        }

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!itemScrollController.isAttached) {
            return;
          }

          itemScrollController.jumpTo(index: anchorIndex, alignment: 0.45);
          lastAppliedAnchorKey.value = scrollKey;
        });

        return null;
      },
      [
        anchorActivationKey,
        anchorIndex,
        contextState?.selectedMessage?.id,
        visibleMessageCount,
      ],
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
                  child: ScrollablePositionedList.builder(
                    key: const ValueKey<String>('search-result-context-list'),
                    itemScrollController: itemScrollController,
                    itemCount: visibleMessages.length + 2,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                          child: _ContextBoundaryHint(
                            visible: state.hasMoreBefore,
                            text: 'Earlier messages exist above this window.',
                          ),
                        );
                      }

                      if (index == visibleMessages.length + 1) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                          child: _ContextBoundaryHint(
                            visible: state.hasMoreAfter,
                            text: 'Later messages exist below this window.',
                          ),
                        );
                      }

                      final message = visibleMessages[index - 1];
                      final isSelected = message.id == selectedMessage.id;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: _ContextMessageCard(
                          message: message,
                          isSelected: isSelected,
                          activationKey: anchorActivationKey,
                        ),
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
  const _ContextMessageCard({
    required this.message,
    required this.isSelected,
    required this.activationKey,
  });

  final MessageListItem message;
  final bool isSelected;
  final String activationKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MessageContextAnchorChrome(
      isContextAnchor: isSelected,
      isSelected: isSelected,
      activationKey: activationKey,
      activationDelay: const Duration(milliseconds: 70),
      debugId: 'search-context-${message.id}',
      child: MessageCard(message: message, layout: MessageCardLayout.analysis),
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
