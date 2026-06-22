import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../../config/theme/colors/theme_colors.dart';
import '../../../../../config/theme/theme_typography.dart';
import '../../../application/message_evidence/message_attachment_evidence.dart';
import '../../view_model/shared/display_widgets/message_display_metrics.dart';
import '../../view_model/shared/display_widgets/new_display_widgets.dart';
import '../url_preview_widget.dart';
import 'media_tile_attachment.dart';

class MessageAttachmentEvidenceTiles extends StatelessWidget {
  const MessageAttachmentEvidenceTiles({
    required this.attachments,
    required this.isFromMe,
    required this.sender,
    required this.sentAt,
    required this.messageId,
    this.messageText,
    this.senderHandleLabel,
    super.key,
  });

  final List<MessageAttachmentEvidence> attachments;
  final bool isFromMe;
  final String sender;
  final DateTime sentAt;
  final int messageId;
  final String? messageText;
  final String? senderHandleLabel;

  @override
  Widget build(BuildContext context) {
    if (attachments.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final attachment in attachments) ...[
          const SizedBox(height: 8),
          _MessageAttachmentEvidenceTile(
            attachment: attachment,
            isFromMe: isFromMe,
            sender: sender,
            sentAt: sentAt,
            messageId: messageId,
            messageText: messageText,
            senderHandleLabel: senderHandleLabel,
          ),
        ],
      ],
    );
  }
}

class _MessageAttachmentEvidenceTile extends StatelessWidget {
  const _MessageAttachmentEvidenceTile({
    required this.attachment,
    required this.isFromMe,
    required this.sender,
    required this.sentAt,
    required this.messageId,
    required this.messageText,
    required this.senderHandleLabel,
  });

  final MessageAttachmentEvidence attachment;
  final bool isFromMe;
  final String sender;
  final DateTime sentAt;
  final int messageId;
  final String? messageText;
  final String? senderHandleLabel;

  @override
  Widget build(BuildContext context) {
    final tileAttachment = _mediaTileAttachment(attachment);
    if (attachment.isUrlPreview) {
      return _MessageUrlPreviewEvidenceTile(
        attachment: attachment,
        isFromMe: isFromMe,
        sender: sender,
        senderHandleLabel: senderHandleLabel,
        sentAt: sentAt,
        messageId: messageId,
        messageText: messageText,
      );
    }

    if (attachment.isImage && attachment.isDisplayable) {
      return ImageMessageTile(
        isMe: isFromMe,
        attachment: tileAttachment,
        sender: sender,
        senderHandleLabel: senderHandleLabel,
        sentAt: sentAt,
        messageId: messageId,
        layout: MessageLayout.fullWidth,
      );
    }

    if (attachment.isVideo && attachment.isDisplayable) {
      return VideoMessageTile(
        isMe: isFromMe,
        attachment: tileAttachment,
        sender: sender,
        senderHandleLabel: senderHandleLabel,
        sentAt: sentAt,
        messageId: messageId,
        layout: MessageLayout.fullWidth,
      );
    }

    return MessageAttachmentFallbackTile(attachment: attachment);
  }
}

class MessageAttachmentFallbackTile extends ConsumerWidget {
  const MessageAttachmentFallbackTile({
    required this.attachment,
    this.title,
    super.key,
  });

  final MessageAttachmentEvidence attachment;
  final String? title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final typography = ref.watch(themeTypographyProvider);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surfaces.control,
        border: Border.all(color: colors.lines.borderSubtle),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title ?? attachment.displayName, style: typography.callout),
            const SizedBox(height: 3),
            Text(
              attachment.availabilityLabel,
              style: typography.caption.copyWith(
                color: colors.content.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageUrlPreviewEvidenceTile extends StatelessWidget {
  const _MessageUrlPreviewEvidenceTile({
    required this.attachment,
    required this.isFromMe,
    required this.sender,
    required this.senderHandleLabel,
    required this.sentAt,
    required this.messageId,
    required this.messageText,
  });

  final MessageAttachmentEvidence attachment;
  final bool isFromMe;
  final String sender;
  final String? senderHandleLabel;
  final DateTime sentAt;
  final int messageId;
  final String? messageText;

  @override
  Widget build(BuildContext context) {
    final previewUrl = firstUrlInMessageText(messageText);
    if (previewUrl == null) {
      return MessageAttachmentFallbackTile(
        attachment: attachment,
        title: _linkPreviewFallbackTitle(attachment),
      );
    }

    return MessageShell(
      isMe: isFromMe,
      layout: MessageLayout.fullWidth,
      metadata: _alignForFullWidth(
        isFromMe: isFromMe,
        child: MetadataLine(
          sender: sender,
          senderHandleLabel: senderHandleLabel,
          sentAt: sentAt,
          messageId: messageId,
          layout: MessageLayout.fullWidth,
        ),
      ),
      child: _alignForFullWidth(
        isFromMe: isFromMe,
        child: UrlPreviewWidget(
          url: previewUrl,
          isFromMe: isFromMe,
          maxWidth: messageMaxBubbleWidth,
        ),
      ),
    );
  }
}

String _linkPreviewFallbackTitle(MessageAttachmentEvidence attachment) {
  if (attachment.sourceRecordCount <= 1) {
    return 'Link preview attachment';
  }
  return 'Link preview attachment (${attachment.sourceRecordCount} resources)';
}

Widget _alignForFullWidth({required bool isFromMe, required Widget child}) {
  return Align(
    alignment: isFromMe ? Alignment.centerRight : Alignment.centerLeft,
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: messageMaxBubbleWidth),
      child: child,
    ),
  );
}

MediaTileAttachment _mediaTileAttachment(MessageAttachmentEvidence attachment) {
  return MediaTileAttachment(
    id: attachment.attachmentSsId,
    localPath: attachment.sourcePathHint,
    mimeType: attachment.mimeType,
    transferName: attachment.transferName ?? attachment.displayName,
    resolvedDisplayPath: attachment.displayPath,
    availability: attachment.availability,
    provenance: attachment.provenance,
  );
}
