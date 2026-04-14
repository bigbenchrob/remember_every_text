import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:macos_ui/macos_ui.dart'
    show
        ControlSize,
        MacosSheet,
        MacosSwitch,
        MacosTextField,
        MacosTooltip,
        PushButton,
        showMacosSheet;

import '../../../../config/theme/colors/theme_colors.dart';
import '../../../../config/theme/theme_typography.dart';
import '../../../../core/util/message_tag_normalizer.dart';
import '../../application/user_metadata/message_user_metadata_controller.dart';
import '../../domain/entities/message_user_metadata.dart';
import '../view_model/shared/hydration/messages_for_handle_provider.dart';

class MessageUserMetadataCardDecorator extends HookConsumerWidget {
  const MessageUserMetadataCardDecorator({
    required this.message,
    required this.child,
    this.secondaryAction,
    super.key,
  });

  final MessageListItem message;
  final Widget child;
  final Widget? secondaryAction;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metadata = _effectiveMetadata(ref, message);
    final isHovered = useState(false);

    return MouseRegion(
      onEnter: (_) {
        isHovered.value = true;
      },
      onExit: (_) {
        isHovered.value = false;
      },
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          child,
          if (metadata.hasUserMetadata && !isHovered.value)
            Positioned(
              top: 10,
              right: 12,
              child: _MessageMetadataIndicator(metadata: metadata),
            ),
          if (isHovered.value)
            Positioned(
              top: 8,
              right: 12,
              child: _MessageMetadataActionCluster(
                message: message,
                metadata: metadata,
                secondaryAction: secondaryAction,
              ),
            ),
        ],
      ),
    );
  }
}

class MessageSearchMatchMetadata extends ConsumerWidget {
  const MessageSearchMatchMetadata({
    required this.message,
    required this.query,
    super.key,
  });

  final MessageListItem message;
  final String query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final typography = ref.watch(themeTypographyProvider);
    final metadata = _effectiveMetadata(ref, message);
    final matchedTags = matchedMessageTagsForQuery(
      displayTags: metadata.tags,
      query: query,
    );

    if (matchedTags.isEmpty && !metadata.isSaved) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 12),
      child: Wrap(
        spacing: 6,
        runSpacing: 6,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          if (metadata.isSaved)
            _MessageMetadataChip(
              label: 'Saved',
              icon: CupertinoIcons.bookmark_fill,
              backgroundColor: colors.accents.primary.withValues(alpha: 0.12),
              borderColor: colors.accents.primary.withValues(alpha: 0.24),
              textStyle: typography.caption1.copyWith(
                color: colors.accents.primary,
              ),
            ),
          if (matchedTags.isNotEmpty)
            Text(
              'Matched tags',
              style: typography.caption1.copyWith(
                color: colors.content.textSecondary,
              ),
            ),
          for (final tag in matchedTags)
            _MessageMetadataChip(
              label: tag,
              icon: CupertinoIcons.tag_fill,
              backgroundColor: colors.messagePanels.supportSurface,
              borderColor: colors.lines.borderSubtle,
              textStyle: typography.caption1.copyWith(
                color: colors.content.textPrimary,
              ),
            ),
        ],
      ),
    );
  }
}

class _MessageMetadataActionCluster extends ConsumerWidget {
  const _MessageMetadataActionCluster({
    required this.message,
    required this.metadata,
    this.secondaryAction,
  });

  final MessageListItem message;
  final MessageUserMetadata metadata;
  final Widget? secondaryAction;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _MessageMetadataActionButton(
          tooltip: metadata.hasUserMetadata
              ? 'Edit saved / tags'
              : 'Save / tag',
          icon: metadata.isSaved
              ? CupertinoIcons.bookmark_fill
              : metadata.tags.isNotEmpty
              ? CupertinoIcons.tag_fill
              : CupertinoIcons.bookmark,
          isAccent: metadata.hasUserMetadata,
          onPressed: () async {
            showMacosSheet(
              context: context,
              barrierDismissible: true,
              builder: (_) => _MessageUserMetadataSheet(message: message),
            );
          },
        ),
        if (secondaryAction != null) ...[
          const SizedBox(width: 6),
          secondaryAction!,
        ],
      ],
    );
  }
}

class _MessageMetadataActionButton extends ConsumerWidget {
  const _MessageMetadataActionButton({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
    this.isAccent = false,
  });

  final String tooltip;
  final IconData icon;
  final Future<void> Function() onPressed;
  final bool isAccent;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);

    return MacosTooltip(
      message: tooltip,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: onPressed,
          child: Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: isAccent
                  ? colors.accents.primary.withValues(alpha: 0.16)
                  : colors.surfaces.control.withValues(alpha: 0.94),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isAccent
                    ? colors.accents.primary.withValues(alpha: 0.28)
                    : colors.lines.borderSubtle,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              icon,
              size: 14,
              color: isAccent
                  ? colors.accents.primary
                  : colors.content.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

class _MessageMetadataIndicator extends ConsumerWidget {
  const _MessageMetadataIndicator({required this.metadata});

  final MessageUserMetadata metadata;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final typography = ref.watch(themeTypographyProvider);
    final tagCount = metadata.tags.length;
    final label = metadata.isSaved && tagCount > 0
        ? '$tagCount'
        : tagCount > 0
        ? '$tagCount'
        : 'Saved';

    return IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.surfaces.control.withValues(alpha: 0.94),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: colors.lines.borderSubtle),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                metadata.isSaved
                    ? CupertinoIcons.bookmark_fill
                    : CupertinoIcons.tag_fill,
                size: 11,
                color: metadata.isSaved
                    ? colors.accents.primary
                    : colors.content.textSecondary,
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: typography.caption1.copyWith(
                  color: colors.content.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MessageMetadataChip extends StatelessWidget {
  const _MessageMetadataChip({
    required this.label,
    required this.icon,
    required this.backgroundColor,
    required this.borderColor,
    required this.textStyle,
  });

  final String label;
  final IconData icon;
  final Color backgroundColor;
  final Color borderColor;
  final TextStyle textStyle;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: borderColor),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 11, color: textStyle.color),
            const SizedBox(width: 4),
            Text(label, style: textStyle),
          ],
        ),
      ),
    );
  }
}

class _MessageUserMetadataSheet extends HookConsumerWidget {
  const _MessageUserMetadataSheet({required this.message});

  final MessageListItem message;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final typography = ref.watch(themeTypographyProvider);
    final controller = useTextEditingController();
    useListenable(controller);

    final metadataAsync = ref.watch(
      messageUserMetadataControllerProvider(messageGuid: message.guid),
    );
    final metadata =
        metadataAsync.valueOrNull ??
        MessageUserMetadata(
          messageGuid: message.guid,
          isSaved: message.isSaved,
          tags: message.tags,
        );
    final notifier = ref.read(
      messageUserMetadataControllerProvider(messageGuid: message.guid).notifier,
    );
    final suggestionsAsync = ref.watch(
      messageTagSuggestionsProvider(query: controller.text),
    );
    final hasSuggestionQuery = normalizeMessageTagValue(
      controller.text,
    ).isNotEmpty;

    Future<void> submitTags() async {
      final parsedTags = parseMessageTagInput(controller.text);
      if (parsedTags.isEmpty) {
        return;
      }
      await notifier.addTags(parsedTags);
      controller.clear();
    }

    final normalizedExistingTags = metadata.tags
        .map(normalizeMessageTagValue)
        .toSet();
    final suggestions = hasSuggestionQuery
        ? suggestionsAsync.valueOrNull
                  ?.where((tag) {
                    return !normalizedExistingTags.contains(
                      normalizeMessageTagValue(tag),
                    );
                  })
                  .take(4)
                  .toList(growable: false) ??
              const <String>[]
        : const <String>[];

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360, maxHeight: 420),
        child: MacosSheet(
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 24,
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Saved & Tags', style: typography.title3),
                const SizedBox(height: 6),
                Text(
                  _sheetPreviewText(message.text),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: typography.caption1.copyWith(
                    color: colors.content.textSecondary,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Saved',
                        style: typography.body.copyWith(
                          color: colors.content.textPrimary,
                        ),
                      ),
                    ),
                    MacosSwitch(
                      value: metadata.isSaved,
                      onChanged: (value) {
                        unawaited(notifier.setSaved(isSaved: value));
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  'Tags',
                  style: typography.body.copyWith(
                    color: colors.content.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                if (metadata.tags.isEmpty)
                  Text(
                    'No tags yet.',
                    style: typography.caption1.copyWith(
                      color: colors.content.textSecondary,
                    ),
                  )
                else
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final tag in metadata.tags)
                        InputChip(
                          label: Text(tag),
                          onDeleted: () {
                            unawaited(notifier.removeTag(tag));
                          },
                        ),
                    ],
                  ),
                const SizedBox(height: 12),
                MacosTextField(
                  controller: controller,
                  autofocus: true,
                  placeholder: 'Add tags, separated by commas',
                  onChanged: (value) {
                    if (value.contains(',')) {
                      unawaited(submitTags());
                    }
                  },
                  onSubmitted: (_) async {
                    await submitTags();
                  },
                ),
                if (suggestions.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final suggestion in suggestions)
                        ActionChip(
                          label: Text(suggestion),
                          onPressed: () {
                            unawaited(notifier.addTags(<String>[suggestion]));
                          },
                        ),
                    ],
                  ),
                ],
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    PushButton(
                      controlSize: ControlSize.regular,
                      secondary: true,
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('Done'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

MessageUserMetadata _effectiveMetadata(WidgetRef ref, MessageListItem message) {
  final metadataAsync = ref.watch(
    messageUserMetadataControllerProvider(messageGuid: message.guid),
  );

  return metadataAsync.valueOrNull ??
      MessageUserMetadata(
        messageGuid: message.guid,
        isSaved: message.isSaved,
        tags: message.tags,
      );
}

String _sheetPreviewText(String text) {
  final trimmed = text.trim();
  if (trimmed.isEmpty || trimmed == '[No text content]') {
    return 'No text preview available for this message.';
  }
  return trimmed;
}
