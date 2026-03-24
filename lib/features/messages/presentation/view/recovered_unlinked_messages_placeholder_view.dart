import 'package:flutter/cupertino.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../../../../config/theme/colors/theme_colors.dart';
import '../../../../config/theme/spacing/app_spacing.dart';
import '../../../../config/theme/theme_typography.dart';
import '../../../../essentials/debug/application/developer_mode_provider.dart';
import '../../../../essentials/navigation/application/panels_view_state_provider.dart';
import '../../../../essentials/navigation/domain/entities/view_spec.dart';
import '../../../../essentials/navigation/domain/navigation_constants.dart';
import '../../../../essentials/navigation/domain/sidebar_mode.dart';
import '../../application/view_spec/resolver_tools/recovered_visible_month_provider.dart';
import '../../domain/entities/attachment_info.dart';
import '../../domain/spec_classes/messages_view_spec.dart';
import '../../infrastructure/repositories/recovered_unlinked_messages_provider.dart';

String _formatRecoveredSemanticKind(String semanticKind) {
  return switch (semanticKind) {
    'plain-text' => 'text',
    'rich-text' => 'rich text',
    'edited-or-unsent' => 'edited / unsent',
    'associated' => 'associated',
    'balloon-or-app' => 'balloon / app',
    'attachment-only' => 'attachment only',
    'system' => 'system',
    'sparse-artifact' => 'sparse artifact',
    _ => 'unknown variant',
  };
}

bool _isRecoveredFallbackText(String text) {
  return switch (text) {
    '(Sparse artifact: no preserved text or payload)' => true,
    '(No plain text content; summary metadata preserved)' => true,
    '(No plain text content; app or balloon payload preserved)' => true,
    '(Associated message carrier without plain text)' => true,
    '(No text content)' => true,
    '(No plain text content)' => true,
    '(No preserved content)' => true,
    _ => false,
  };
}

bool _hasMeaningfulRecoveredText(RecoveredUnlinkedMessageItem message) {
  final trimmed = message.text.trim();
  if (trimmed.isEmpty) {
    return false;
  }

  return !_isRecoveredFallbackText(trimmed);
}

String _buildRecoveredStatusLine(RecoveredUnlinkedMessageItem message) {
  final hasMeaningfulText = _hasMeaningfulRecoveredText(message);
  final hasAttachments = message.hasAttachments;
  final service = message.service;

  if (message.semanticKind == 'attachment-only' && hasAttachments) {
    return '$service associated with recovered attachments';
  }

  if (hasMeaningfulText && hasAttachments) {
    return '$service with recovered text and attachments';
  }

  if (hasMeaningfulText) {
    return '$service with recovered text';
  }

  if (hasAttachments) {
    return '$service associated with recovered attachments';
  }

  return '$service with no recoverable text or attachments';
}

/// Center-panel view for recovered unlinked messages.
class RecoveredUnlinkedMessagesPlaceholderView extends HookConsumerWidget {
  const RecoveredUnlinkedMessagesPlaceholderView({
    this.contactId,
    this.scrollToDate,
    this.onlyNoHandleFromMe = false,
    super.key,
  });

  final int? contactId;
  final DateTime? scrollToDate;
  final bool onlyNoHandleFromMe;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final typography = ref.watch(themeTypographyProvider);
    final asyncMessages = ref.watch(
      recoveredUnlinkedMessagesProvider(contactId: contactId),
    );
    final searchController = useTextEditingController();
    final query = useState('');
    final isContactScoped = contactId != null;
    final title = onlyNoHandleFromMe
        ? 'Recovered no-handle messages'
        : isContactScoped
        ? 'Recovered deleted messages'
        : 'Recovered deleted messages';
    final description = onlyNoHandleFromMe
        ? 'Recovered orphaned records that still look like outgoing messages but no longer retain handle linkage. This is an experimental slice of the recovered dataset.'
        : isContactScoped
        ? "Showing recovered deleted-message candidates that appear to match this contact's linked handles. These records remain separate from the normal chat flow."
        : 'Source records recovered from `chat.db` without a normal chat link. Many may reflect conversations deleted on iPhone or iPad, but they remain separate from the normal chat flow.';

    return ColoredBox(
      color: colors.messagePanels.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      CupertinoIcons.tray_arrow_down_fill,
                      size: 24,
                      color: colors.content.textSecondary,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(title, style: typography.title1),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(description, style: typography.callout),
                const SizedBox(height: AppSpacing.md),
                MacosTextField(
                  controller: searchController,
                  placeholder:
                      'Filter by text, sender, service, or attachment name',
                  onChanged: (value) {
                    query.value = value.trim().toLowerCase();
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: asyncMessages.when(
              data: (messages) {
                final bucketed = _applyRecoveredBucketFilter(
                  messages: messages,
                  onlyNoHandleFromMe: onlyNoHandleFromMe,
                );
                final filtered = _filterMessages(
                  messages: bucketed,
                  query: query.value,
                );

                if (bucketed.isEmpty) {
                  return _EmptyRecoveredMessagesState(
                    message: onlyNoHandleFromMe
                        ? 'No recovered no-handle outgoing messages were found.'
                        : isContactScoped
                        ? "No recovered deleted messages matched this contact's linked handles."
                        : 'No recovered deleted messages have been projected yet.',
                  );
                }

                if (filtered.isEmpty) {
                  // ignore: prefer_const_constructors
                  return _EmptyRecoveredMessagesState(
                    message:
                        'No recovered deleted messages match the current filter.',
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (isContactScoped && !onlyNoHandleFromMe)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
                        child: _RecoveredLegend(
                          directCount: filtered
                              .where((message) => !message.isInferred)
                              .length,
                          inferredCount: filtered
                              .where((message) => message.isInferred)
                              .length,
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        onlyNoHandleFromMe
                            ? '${filtered.length} of ${bucketed.length} recovered no-handle outgoing messages'
                            : '${filtered.length} of ${bucketed.length} recovered deleted-message candidates',
                        style: typography.caption1,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Expanded(
                      child: _RecoveredMessagesList(
                        contactId: contactId,
                        messages: filtered,
                        onlyNoHandleFromMe: onlyNoHandleFromMe,
                        scrollToDate: scrollToDate,
                      ),
                    ),
                  ],
                );
              },
              loading: () => const Center(child: ProgressCircle()),
              error: (error, _) => _EmptyRecoveredMessagesState(
                message: 'Unable to load recovered deleted messages: $error',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecoveredMessagesList extends HookConsumerWidget {
  const _RecoveredMessagesList({
    required this.contactId,
    required this.messages,
    required this.onlyNoHandleFromMe,
    this.scrollToDate,
  });

  final int? contactId;
  final List<RecoveredUnlinkedMessageItem> messages;
  final bool onlyNoHandleFromMe;
  final DateTime? scrollToDate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemScrollController = useMemoized(ItemScrollController.new);
    final itemPositionsListener = useMemoized(ItemPositionsListener.create);
    final lastScrollTarget = useRef<String?>(null);
    final visibleMonthNotifier = ref.read(
      recoveredVisibleMonthProvider(
        contactId: contactId,
        onlyNoHandleFromMe: onlyNoHandleFromMe,
      ).notifier,
    );
    final targetIndex = _targetIndexForScrollDate(
      messages: messages,
      scrollToDate: scrollToDate,
    );
    final targetKey = scrollToDate == null || targetIndex == null
        ? null
        : '${scrollToDate!.year}-${scrollToDate!.month.toString().padLeft(2, '0')}-$targetIndex';

    useEffect(() {
      if (targetIndex == null || targetKey == null) {
        return null;
      }
      if (lastScrollTarget.value == targetKey) {
        return null;
      }

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!itemScrollController.isAttached) {
          return;
        }

        lastScrollTarget.value = targetKey;
        itemScrollController.jumpTo(index: targetIndex);
      });

      return null;
    }, [targetKey, targetIndex, itemScrollController]);

    useEffect(() {
      void handlePositionsChanged() {
        final positions = itemPositionsListener.itemPositions.value;
        if (positions.isEmpty) {
          return;
        }

        final visiblePositions =
            positions
                .where((position) {
                  return position.itemTrailingEdge > 0 &&
                      position.itemLeadingEdge < 1;
                })
                .toList(growable: false)
              ..sort((left, right) {
                return left.itemLeadingEdge.compareTo(right.itemLeadingEdge);
              });

        if (visiblePositions.isEmpty) {
          return;
        }

        final topVisibleIndex = visiblePositions.first.index;
        if (topVisibleIndex < 0 || topVisibleIndex >= messages.length) {
          return;
        }

        visibleMonthNotifier.setMonthKey(
          _monthKeyForDate(messages[topVisibleIndex].sentAt),
        );
      }

      itemPositionsListener.itemPositions.addListener(handlePositionsChanged);

      WidgetsBinding.instance.addPostFrameCallback((_) {
        handlePositionsChanged();
      });

      return () {
        itemPositionsListener.itemPositions.removeListener(
          handlePositionsChanged,
        );
      };
    }, [itemPositionsListener, messages, visibleMonthNotifier]);

    return ScrollablePositionedList.builder(
      itemScrollController: itemScrollController,
      itemPositionsListener: itemPositionsListener,
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: index == messages.length - 1 ? 0 : AppSpacing.sm,
          ),
          child: _RecoveredUnlinkedMessageCard(message: messages[index]),
        );
      },
    );
  }
}

int? _targetIndexForScrollDate({
  required List<RecoveredUnlinkedMessageItem> messages,
  required DateTime? scrollToDate,
}) {
  if (scrollToDate == null || messages.isEmpty) {
    return null;
  }

  final monthStart = DateTime(scrollToDate.year, scrollToDate.month, 1);

  for (var index = 0; index < messages.length; index += 1) {
    final sentAt = messages[index].sentAt;
    if (sentAt == null) {
      continue;
    }
    if (!sentAt.isBefore(monthStart)) {
      return index;
    }
  }

  return messages.length - 1;
}

String? _monthKeyForDate(DateTime? date) {
  if (date == null) {
    return null;
  }

  return '${date.year}-${date.month.toString().padLeft(2, '0')}';
}

List<RecoveredUnlinkedMessageItem> _applyRecoveredBucketFilter({
  required List<RecoveredUnlinkedMessageItem> messages,
  required bool onlyNoHandleFromMe,
}) {
  if (!onlyNoHandleFromMe) {
    return messages;
  }

  return messages
      .where((message) {
        return message.isFromMe && message.senderHandleId == null;
      })
      .toList(growable: false);
}

List<RecoveredUnlinkedMessageItem> _filterMessages({
  required List<RecoveredUnlinkedMessageItem> messages,
  required String query,
}) {
  if (query.isEmpty) {
    return messages;
  }

  return messages
      .where((message) {
        final attachmentText = message.attachments
            .map((attachment) => attachment.transferName?.trim())
            .whereType<String>()
            .where((name) => name.isNotEmpty)
            .join(' ')
            .toLowerCase();
        final haystack = [
          message.senderLabel.toLowerCase(),
          message.service.toLowerCase(),
          message.itemType.toLowerCase(),
          message.text.toLowerCase(),
          attachmentText,
        ].join(' ');
        return haystack.contains(query);
      })
      .toList(growable: false);
}

class _EmptyRecoveredMessagesState extends ConsumerWidget {
  const _EmptyRecoveredMessagesState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final typography = ref.watch(themeTypographyProvider);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              CupertinoIcons.tray,
              size: 36,
              color: colors.content.textTertiary,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(message, style: typography.body, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _RecoveredUnlinkedMessageCard extends ConsumerWidget {
  const _RecoveredUnlinkedMessageCard({required this.message});

  final RecoveredUnlinkedMessageItem message;

  _SelectedRecoveredAttachment? _selectedRecoveredAttachment(WidgetRef ref) {
    final rightSpec = ref.watch(
      panelsViewStateProvider(
        SidebarMode.messages,
      ).select((panels) => panels[WindowPanel.right]?.activePage?.spec),
    );

    return rightSpec?.when(
      messages: (messagesSpec) => messagesSpec.mapOrNull(
        recoveredAttachmentViewer: (selectedSpec) =>
            _SelectedRecoveredAttachment(
              messageId: selectedSpec.messageId,
              attachmentId: selectedSpec.attachment.id,
            ),
      ),
      import: (_) => null,
      onboarding: (_) => null,
    );
  }

  List<AttachmentInfo> _visibleAttachments() {
    return message.attachments.take(6).toList(growable: false);
  }

  String _attachmentLabel(AttachmentInfo attachment, int index) {
    final transferName = attachment.transferName?.trim();
    if (transferName != null && transferName.isNotEmpty) {
      return transferName;
    }

    final resolvedPath = attachment.resolvedLocalPath()?.trim();
    if (resolvedPath != null && resolvedPath.isNotEmpty) {
      final segments = resolvedPath.split('/');
      final lastSegment = segments.isEmpty
          ? resolvedPath
          : segments.last.trim();
      if (lastSegment.isNotEmpty) {
        return lastSegment;
      }
    }

    return 'Attachment ${index + 1}';
  }

  String _buildHeaderTitle() {
    if (message.isFromMe) {
      return 'You';
    }

    final contactName = message.contactName?.trim();
    final senderLabel = message.senderLabel.trim();
    final hasContactName = contactName != null && contactName.isNotEmpty;
    final hasConcreteSenderLabel =
        senderLabel.isNotEmpty && senderLabel != 'Unknown Sender';

    if (hasContactName && hasConcreteSenderLabel) {
      return '$contactName • $senderLabel';
    }

    if (hasContactName) {
      return 'Contact: $contactName';
    }

    return 'Unknown Sender';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final typography = ref.watch(themeTypographyProvider);
    final developerMode = ref.watch(developerModeProvider).valueOrNull;
    final isDeveloperMode = developerMode == DeveloperModeValue.developer;
    final dateFormatter = DateFormat('MMM d, yyyy h:mm a');
    final isSparseArtifact = message.isSparseArtifact;
    final isFromMe = message.isFromMe;
    final hasMeaningfulText = _hasMeaningfulRecoveredText(message);
    final statusLine = _buildRecoveredStatusLine(message);
    final attachments = _visibleAttachments();
    final selectedAttachment = _selectedRecoveredAttachment(ref);
    final isSelectedMessage = selectedAttachment?.messageId == message.id;
    final backgroundColor = message.isInferred
        ? colors.messagePanels.accentTint
        : isFromMe
        ? colors.messagePanels.accentTintSoft
        : isSparseArtifact
        ? colors.messagePanels.mutedTint
        : colors.messagePanels.card;
    final baseBorderColor = message.isInferred
        ? colors.messagePanels.accentBorder
        : isFromMe
        ? colors.messagePanels.accentBorderSoft
        : isSparseArtifact
        ? colors.messagePanels.mutedBorder
        : colors.messagePanels.cardBorder;
    final borderColor = isSelectedMessage
        ? colors.messagePanels.selectionBorder
        : baseBorderColor;
    final cardColor = isSelectedMessage
        ? colors.messagePanels.selectionTint
        : backgroundColor;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(_buildHeaderTitle(), style: typography.headline),
              ),
              Text(
                message.sentAt == null
                    ? 'Unknown date'
                    : dateFormatter.format(message.sentAt!),
                style: typography.caption1,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            statusLine,
            style: typography.caption1.copyWith(
              color: colors.content.textSecondary,
            ),
          ),
          if (message.isInferred) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Best guess: inferred from nearby recovered messages for this contact.',
              style: typography.caption1.copyWith(
                color: colors.accents.primary.withValues(alpha: 0.92),
              ),
            ),
          ],
          if (hasMeaningfulText) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(message.text, style: typography.body),
          ],
          if (message.hasAttachments) ...[
            const SizedBox(height: AppSpacing.sm),
            if (attachments.isNotEmpty) ...[
              Wrap(
                spacing: AppSpacing.xs,
                runSpacing: AppSpacing.xs,
                children: [
                  for (var index = 0; index < attachments.length; index += 1)
                    _RecoveredAttachmentChip(
                      label: _attachmentLabel(attachments[index], index),
                      attachment: attachments[index],
                      messageId: message.id,
                      isSelected:
                          selectedAttachment?.messageId == message.id &&
                          selectedAttachment?.attachmentId ==
                              attachments[index].id,
                    ),
                ],
              ),
            ],
          ],
          if (isDeveloperMode) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              [
                'Message ID: ${message.id}',
                'Semantic: ${_formatRecoveredSemanticKind(message.semanticKind)}',
                if (isSparseArtifact) 'Sparse artifact',
                if (message.rawItemType != null)
                  'Raw item_type: ${message.rawItemType}',
                if (message.rawAssociatedMessageType != null)
                  'Raw associated_message_type: ${message.rawAssociatedMessageType}',
              ].join(' • '),
              style: typography.caption1.copyWith(
                color: colors.content.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _RecoveredAttachmentChip extends ConsumerWidget {
  const _RecoveredAttachmentChip({
    required this.label,
    required this.attachment,
    required this.messageId,
    required this.isSelected,
  });

  final String label;
  final AttachmentInfo attachment;
  final int messageId;
  final bool isSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final typography = ref.watch(themeTypographyProvider);
    final chipColor = isSelected
        ? colors.messagePanels.chipSelectionTint
        : colors.messagePanels.supportSurface;
    final chipBorderColor = isSelected
        ? colors.messagePanels.selectionBorder
        : colors.messagePanels.chipBorder;
    final chipTextColor = isSelected
        ? colors.accents.primary
        : colors.content.textPrimary;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          ref
              .read(panelsViewStateProvider(SidebarMode.messages).notifier)
              .show(
                panel: WindowPanel.right,
                spec: ViewSpec.messages(
                  MessagesSpec.recoveredAttachmentViewer(
                    messageId: messageId,
                    attachment: attachment,
                  ),
                ),
              );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: chipColor,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: chipBorderColor, width: 1),
          ),
          child: Text(
            label,
            style: typography.caption1.copyWith(color: chipTextColor),
          ),
        ),
      ),
    );
  }
}

class _SelectedRecoveredAttachment {
  const _SelectedRecoveredAttachment({
    required this.messageId,
    required this.attachmentId,
  });

  final int messageId;
  final int attachmentId;
}

class _RecoveredLegend extends ConsumerWidget {
  const _RecoveredLegend({
    required this.directCount,
    required this.inferredCount,
  });

  final int directCount;
  final int inferredCount;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final typography = ref.watch(themeTypographyProvider);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.messagePanels.supportSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.messagePanels.cardBorder, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Legend',
            style: typography.caption.copyWith(
              color: colors.content.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Attributed matches are linked by surviving sender identity. Best-guess rows are nearby outgoing no-handle records shown as a conservative heuristic for deleted-conversation context.',
            style: typography.caption1,
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.xs,
            children: [
              _LegendChip(
                label: '$directCount attributed',
                backgroundColor: colors.surfaces.surface,
                borderColor: colors.lines.borderSubtle,
              ),
              _LegendChip(
                label: '$inferredCount best guess',
                backgroundColor: colors.accents.primary.withValues(alpha: 0.10),
                borderColor: colors.accents.primary.withValues(alpha: 0.28),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LegendChip extends ConsumerWidget {
  const _LegendChip({
    required this.label,
    required this.backgroundColor,
    required this.borderColor,
  });

  final String label;
  final Color backgroundColor;
  final Color borderColor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final typography = ref.watch(themeTypographyProvider);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Text(label, style: typography.caption1),
    );
  }
}
