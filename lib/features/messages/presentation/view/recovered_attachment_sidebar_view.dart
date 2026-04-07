import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show SelectableText;
import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:macos_ui/macos_ui.dart';

import '../../../../config/theme/colors/theme_colors.dart';
import '../../../../config/theme/spacing/app_spacing.dart';
import '../../../../config/theme/theme_typography.dart';
import '../../../../essentials/navigation/domain/navigation_constants.dart';
import '../../../../essentials/navigation/domain/sidebar_mode.dart';
import '../../../../essentials/navigation/feature_level_providers.dart';
import '../../domain/entities/attachment_info.dart';

class RecoveredAttachmentSidebarView extends ConsumerWidget {
  const RecoveredAttachmentSidebarView({
    required this.messageId,
    required this.attachment,
    super.key,
  });

  final int messageId;
  final AttachmentInfo attachment;

  String _displayName() {
    final transferName = attachment.transferName?.trim();
    if (transferName != null && transferName.isNotEmpty) {
      return transferName;
    }

    final resolvedPath = attachment.resolvedLocalPath()?.trim();
    if (resolvedPath == null || resolvedPath.isEmpty) {
      return 'Recovered attachment';
    }

    final segments = resolvedPath.split('/');
    final lastSegment = segments.isEmpty ? resolvedPath : segments.last.trim();
    if (lastSegment.isEmpty) {
      return 'Recovered attachment';
    }

    return lastSegment;
  }

  String _kindLabel() {
    if (attachment.isImage) {
      return 'Recovered image attachment';
    }
    if (attachment.isVideo) {
      return 'Recovered video attachment';
    }
    if (attachment.isUrlPreview) {
      return 'Recovered link preview attachment';
    }
    return 'Recovered attachment';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final typography = ref.watch(themeTypographyProvider);
    final resolvedPath = attachment.resolvedLocalPath();
    final hasLocalPath = resolvedPath != null && resolvedPath.isNotEmpty;

    Future<void> closeSidebar() async {
      ref
          .read(panelsViewStateProvider(SidebarMode.messages).notifier)
          .clear(panel: WindowPanel.right);
    }

    return ColoredBox(
      color: colors.surfaces.canvas,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ListView(
                children: [
                  Text('Recovered attachment', style: typography.headline),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    _displayName(),
                    style: typography.body.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    '${_kindLabel()} from recovered message $messageId',
                    style: typography.caption1.copyWith(
                      color: colors.content.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _RecoveredAttachmentPreview(
                    attachment: attachment,
                    resolvedPath: resolvedPath,
                  ),
                  if (hasLocalPath) ...[
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'Recovered file path',
                      style: typography.caption.copyWith(
                        color: colors.content.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    SelectableText(resolvedPath, style: typography.caption1),
                  ],
                  if (attachment.mimeType != null &&
                      attachment.mimeType!.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'MIME type',
                      style: typography.caption.copyWith(
                        color: colors.content.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(attachment.mimeType!, style: typography.caption1),
                  ],
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Align(
              alignment: Alignment.centerLeft,
              child: PushButton(
                controlSize: ControlSize.large,
                secondary: true,
                onPressed: closeSidebar,
                child: const Text('Close sidebar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecoveredAttachmentPreview extends ConsumerWidget {
  const _RecoveredAttachmentPreview({
    required this.attachment,
    required this.resolvedPath,
  });

  final AttachmentInfo attachment;
  final String? resolvedPath;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final typography = ref.watch(themeTypographyProvider);
    final hasLocalPath = resolvedPath != null && resolvedPath!.isNotEmpty;

    if (hasLocalPath && attachment.isImage) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.file(
          File(resolvedPath!),
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) {
            return const _RecoveredAttachmentPlaceholder(
              cardKey: ValueKey<String>('recovered-placeholder-image-error'),
              title: 'Image preview unavailable',
              body:
                  'The recovered image file exists in metadata, but could not be rendered here.',
            );
          },
        ),
      );
    }

    if (attachment.isVideo) {
      return const _RecoveredAttachmentPlaceholder(
        cardKey: ValueKey<String>('recovered-placeholder-video'),
        title: 'Recovered video',
        body:
            'This recovered attachment looks like a video. Inline video playback can be added later.',
      );
    }

    if (attachment.isUrlPreview) {
      return const _RecoveredAttachmentPlaceholder(
        cardKey: ValueKey<String>('recovered-placeholder-link-preview'),
        title: 'Recovered link preview attachment',
        body:
            'This attachment appears to be a stored link-preview payload. Dedicated preview rendering can be added later.',
      );
    }

    if (hasLocalPath) {
      return const _RecoveredAttachmentPlaceholder(
        cardKey: ValueKey<String>('recovered-placeholder-file'),
        title: 'Recovered file',
        body:
            'A recovered attachment file is linked to this message. Rich inline rendering is not available for this file type yet.',
      );
    }

    return _RecoveredAttachmentPlaceholder(
      cardKey: const ValueKey<String>('recovered-placeholder-metadata-only'),
      title: 'Attachment metadata only',
      body:
          'This recovered attachment still has identifying metadata, but no local file path survived into the current projection.',
      iconColor: colors.content.textSecondary,
      textStyle: typography.body,
    );
  }
}

class _RecoveredAttachmentPlaceholder extends ConsumerWidget {
  const _RecoveredAttachmentPlaceholder({
    required this.title,
    required this.body,
    this.cardKey,
    this.iconColor,
    this.textStyle,
  });

  final String title;
  final String body;
  final Key? cardKey;
  final Color? iconColor;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final typography = ref.watch(themeTypographyProvider);

    return Align(
      alignment: Alignment.centerLeft,
      widthFactor: 1,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 260),
        child: Container(
          key: cardKey,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colors.surfaces.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colors.lines.borderSubtle, width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                CupertinoIcons.doc,
                color: iconColor ?? colors.content.textSecondary,
                size: 24,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                title,
                style: typography.body.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(body, style: textStyle ?? typography.body),
            ],
          ),
        ),
      ),
    );
  }
}
