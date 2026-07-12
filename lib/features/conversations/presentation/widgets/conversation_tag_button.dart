import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Divider, Tooltip;
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:macos_ui/macos_ui.dart';

import '../../../../config/theme/colors/theme_colors.dart';
import '../../../../config/theme/spacing/app_spacing.dart';
import '../../../../config/theme/theme_typography.dart';
import '../../application/conversation_tags/conversation_tag_actions_provider.dart';
import '../../application/conversation_tags/conversation_tags_provider.dart';
import '../../domain/conversation_tags/conversation_tag_display.dart';

class ConversationTagButton extends ConsumerStatefulWidget {
  const ConversationTagButton({
    required this.conversationId,
    this.size = 24,
    this.iconSize = 13,
    super.key,
  });

  final int conversationId;
  final double size;
  final double iconSize;

  @override
  ConsumerState<ConversationTagButton> createState() =>
      _ConversationTagButtonState();
}

class _ConversationTagButtonState extends ConsumerState<ConversationTagButton> {
  var _isHovered = false;

  @override
  Widget build(BuildContext context) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final iconColor = _isHovered
        ? colors.content.iconSecondary
        : colors.content.textTertiary.withValues(alpha: 0.62);
    final background = _isHovered
        ? colors.surfaces.hover
        : colors.surfaces.canvas.withValues(alpha: 0);

    return Tooltip(
      message: 'Tag conversation',
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) {
          setState(() {
            _isHovered = true;
          });
        },
        onExit: (_) {
          setState(() {
            _isHovered = false;
          });
        },
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () async {
            await showMacosSheet<void>(
              context: context,
              builder: (context) {
                return ConversationTagEditorSheet(
                  conversationId: widget.conversationId,
                );
              },
            );
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            curve: Curves.easeOut,
            width: widget.size,
            height: widget.size,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Icon(
              CupertinoIcons.tag,
              size: widget.iconSize,
              color: iconColor,
            ),
          ),
        ),
      ),
    );
  }
}

class ConversationTagEditorSheet extends ConsumerStatefulWidget {
  const ConversationTagEditorSheet({required this.conversationId, super.key});

  final int conversationId;

  @override
  ConsumerState<ConversationTagEditorSheet> createState() =>
      _ConversationTagEditorSheetState();
}

class _ConversationTagEditorSheetState
    extends ConsumerState<ConversationTagEditorSheet> {
  late final TextEditingController _controller;
  var _errorMessage = '';
  var _isBusy = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final typography = ref.watch(themeTypographyProvider);
    final assignedTagsAsync = ref.watch(
      conversationTagsByConversationIdsProvider(
        request: ConversationTagsByConversationIdsRequest(
          conversationIds: [widget.conversationId],
        ),
      ),
    );
    final allTagsAsync = ref.watch(conversationTagsProvider);

    return MacosSheet(
      child: Center(
        child: Container(
          width: 460,
          height: 520,
          padding: const EdgeInsets.all(20),
          child: assignedTagsAsync.when(
            data: (assignedByConversation) {
              final assignedTags =
                  assignedByConversation[widget.conversationId] ??
                  const <ConversationTagDisplay>[];
              return allTagsAsync.when(
                data: (allTags) {
                  return _ConversationTagEditorContent(
                    allTags: allTags,
                    assignedTags: assignedTags,
                    controller: _controller,
                    isBusy: _isBusy,
                    errorMessage: _errorMessage,
                    colors: colors,
                    typography: typography,
                    onCreate: _createAndAssignTag,
                    onAssign: _assignTag,
                    onRemove: _removeTag,
                  );
                },
                loading: () => const Center(child: ProgressCircle()),
                error: (error, _) => _ConversationTagError(
                  message: 'Unable to load tags: $error',
                  typography: typography,
                  colors: colors,
                ),
              );
            },
            loading: () => const Center(child: ProgressCircle()),
            error: (error, _) => _ConversationTagError(
              message: 'Unable to load conversation tags: $error',
              typography: typography,
              colors: colors,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _createAndAssignTag() async {
    await _runAction(() async {
      await ref
          .read(conversationTagActionsProvider.notifier)
          .createAndAssignTag(
            conversationId: widget.conversationId,
            rawName: _controller.text,
          );
      _controller.clear();
    });
  }

  Future<void> _assignTag(ConversationTagDisplay tag) async {
    await _runAction(() async {
      await ref
          .read(conversationTagActionsProvider.notifier)
          .assignTag(conversationId: widget.conversationId, tagId: tag.id);
    });
  }

  Future<void> _removeTag(ConversationTagDisplay tag) async {
    await _runAction(() async {
      await ref
          .read(conversationTagActionsProvider.notifier)
          .removeTag(conversationId: widget.conversationId, tagId: tag.id);
    });
  }

  Future<void> _runAction(Future<void> Function() action) async {
    if (_isBusy) {
      return;
    }
    setState(() {
      _isBusy = true;
      _errorMessage = '';
    });
    try {
      await action();
    } on FormatException catch (error) {
      setState(() {
        _errorMessage = error.message;
      });
    } catch (error) {
      setState(() {
        _errorMessage = 'Unable to update tags: $error';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isBusy = false;
        });
      }
    }
  }
}

class _ConversationTagEditorContent extends StatelessWidget {
  const _ConversationTagEditorContent({
    required this.allTags,
    required this.assignedTags,
    required this.controller,
    required this.isBusy,
    required this.errorMessage,
    required this.colors,
    required this.typography,
    required this.onCreate,
    required this.onAssign,
    required this.onRemove,
  });

  final List<ConversationTagDisplay> allTags;
  final List<ConversationTagDisplay> assignedTags;
  final TextEditingController controller;
  final bool isBusy;
  final String errorMessage;
  final ThemeColors colors;
  final ThemeTypography typography;
  final Future<void> Function() onCreate;
  final Future<void> Function(ConversationTagDisplay tag) onAssign;
  final Future<void> Function(ConversationTagDisplay tag) onRemove;

  @override
  Widget build(BuildContext context) {
    final assignedIds = assignedTags.map((tag) => tag.id).toSet();
    final availableTags = allTags
        .where((tag) => !assignedIds.contains(tag.id))
        .toList(growable: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Conversation Tags',
          style: typography.title2.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Tags describe the meaning of this conversation.',
          style: typography.caption.copyWith(
            color: colors.content.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text('Applied', style: typography.cassetteCardSectionHeader),
        const SizedBox(height: AppSpacing.sm),
        if (assignedTags.isEmpty)
          Text(
            'No tags yet.',
            style: typography.caption.copyWith(
              color: colors.content.textTertiary,
            ),
          )
        else
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final tag in assignedTags)
                _AppliedConversationTagChip(
                  tag: tag,
                  colors: colors,
                  typography: typography,
                  onRemove: isBusy ? null : () => onRemove(tag),
                ),
            ],
          ),
        const SizedBox(height: AppSpacing.lg),
        Text('Create tag', style: typography.cassetteCardSectionHeader),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(
              child: MacosTextField(
                controller: controller,
                placeholder: 'Family, Work, Hawaii Trip...',
                enabled: !isBusy,
                onSubmitted: (_) async {
                  if (!isBusy) {
                    await onCreate();
                  }
                },
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            PushButton(
              controlSize: ControlSize.regular,
              onPressed: isBusy ? null : () async => onCreate(),
              child: isBusy
                  ? const CupertinoActivityIndicator()
                  : const Text('Create & Apply'),
            ),
          ],
        ),
        if (errorMessage.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.xs),
            child: Text(
              errorMessage,
              style: typography.caption.copyWith(color: colors.status.error),
            ),
          ),
        const SizedBox(height: AppSpacing.lg),
        Text('Existing tags', style: typography.cassetteCardSectionHeader),
        const SizedBox(height: AppSpacing.sm),
        Expanded(
          child: availableTags.isEmpty
              ? Text(
                  'No other tags available.',
                  style: typography.caption.copyWith(
                    color: colors.content.textTertiary,
                  ),
                )
              : MacosScrollbar(
                  child: ListView.separated(
                    itemCount: availableTags.length,
                    separatorBuilder: (context, index) =>
                        Divider(height: 1, color: colors.lines.divider),
                    itemBuilder: (context, index) {
                      final tag = availableTags[index];
                      return _AvailableConversationTagRow(
                        tag: tag,
                        colors: colors,
                        typography: typography,
                        onTap: isBusy ? null : () async => onAssign(tag),
                      );
                    },
                  ),
                ),
        ),
        const SizedBox(height: AppSpacing.md),
        Align(
          alignment: Alignment.centerRight,
          child: PushButton(
            controlSize: ControlSize.regular,
            secondary: true,
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Done'),
          ),
        ),
      ],
    );
  }
}

class _AppliedConversationTagChip extends StatelessWidget {
  const _AppliedConversationTagChip({
    required this.tag,
    required this.colors,
    required this.typography,
    required this.onRemove,
  });

  final ConversationTagDisplay tag;
  final ThemeColors colors;
  final ThemeTypography typography;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surfaces.selected.withValues(alpha: 0.38),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: colors.lines.borderSubtle.withValues(alpha: 0.32),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 8, right: 4, top: 3, bottom: 3),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(tag.displayName, style: typography.caption),
            const SizedBox(width: 3),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onRemove,
              child: Icon(
                CupertinoIcons.xmark,
                size: 11,
                color: onRemove == null
                    ? colors.content.textDisabled
                    : colors.content.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AvailableConversationTagRow extends StatelessWidget {
  const _AvailableConversationTagRow({
    required this.tag,
    required this.colors,
    required this.typography,
    required this.onTap,
  });

  final ConversationTagDisplay tag;
  final ThemeColors colors;
  final ThemeTypography typography;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 9),
        child: Row(
          children: [
            Icon(
              CupertinoIcons.tag,
              size: 12,
              color: colors.content.iconSecondary,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                tag.displayName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: typography.callout,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConversationTagError extends StatelessWidget {
  const _ConversationTagError({
    required this.message,
    required this.typography,
    required this.colors,
  });

  final String message;
  final ThemeTypography typography;
  final ThemeColors colors;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: typography.callout.copyWith(color: colors.status.error),
      ),
    );
  }
}
