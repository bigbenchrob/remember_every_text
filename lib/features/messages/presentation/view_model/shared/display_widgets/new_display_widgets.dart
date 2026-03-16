import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';

import '../../../../../../config/theme/colors/theme_colors.dart';
import '../../../../../../essentials/debug/application/developer_mode_provider.dart';
import '../hydration/attachment_info.dart';

// ignore: avoid_classes_with_only_static_members
class MsgTheme {
  static const maxBubbleWidth = 520.0;
  static const bubblePadding = EdgeInsets.symmetric(
    horizontal: 12,
    vertical: 10,
  );
  static const mediaRadius = BorderRadius.all(Radius.circular(14));
  static const textRadius = BorderRadius.all(Radius.circular(16));
  static const gapXS = SizedBox(height: 4);
  static const gapMD = SizedBox(height: 12);

  static EdgeInsets convoHPad() => const EdgeInsets.symmetric(horizontal: 14);
}

enum MessageLayout { bubble, fullWidth }

enum MessageClusterRole { standalone, first, middle, last }

class MessageGroupingStyle {
  const MessageGroupingStyle({
    required this.role,
    required this.showSenderHeader,
    required this.compactTopSpacing,
    required this.compactBottomSpacing,
    required this.softenContinuationChrome,
  });

  static const standalone = MessageGroupingStyle(
    role: MessageClusterRole.standalone,
    showSenderHeader: true,
    compactTopSpacing: false,
    compactBottomSpacing: false,
    softenContinuationChrome: false,
  );

  final MessageClusterRole role;
  final bool showSenderHeader;
  final bool compactTopSpacing;
  final bool compactBottomSpacing;
  final bool softenContinuationChrome;
}

Widget _alignMediaForLayout({
  required MessageLayout layout,
  required bool isMe,
  required Widget child,
}) {
  if (layout == MessageLayout.bubble) {
    return child;
  }

  return Align(
    alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: MsgTheme.maxBubbleWidth),
      child: child,
    ),
  );
}

Widget _alignMetadataForLayout({
  required MessageLayout layout,
  required bool isMe,
  required Widget child,
}) {
  if (layout == MessageLayout.bubble) {
    return child;
  }

  return Align(
    alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: MsgTheme.maxBubbleWidth),
      child: child,
    ),
  );
}

String _formatCompactMessageDateTime(DateTime dateTime) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  final month = months[dateTime.month - 1];
  final day = dateTime.day;
  final year = dateTime.year;
  final hour = dateTime.hour;
  final minute = dateTime.minute.toString().padLeft(2, '0');
  final hour12 = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
  final amPm = hour >= 12 ? 'PM' : 'AM';

  return '$month $day $year • $hour12:$minute $amPm';
}

String _formatClusterContinuationTime(DateTime dateTime) {
  final hour = dateTime.hour;
  final minute = dateTime.minute.toString().padLeft(2, '0');
  final hour12 = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);

  return '$hour12:$minute';
}

String _formatMessageIdLabel(int messageId) {
  final formattedId = messageId.toString().replaceAllMapped(
    RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
    (match) => '${match[1]},',
  );
  return 'Message ID $formattedId';
}

BorderRadius _textBorderRadiusForRole(MessageClusterRole role) {
  const large = Radius.circular(16);
  const flat = Radius.zero;

  return switch (role) {
    MessageClusterRole.standalone => const BorderRadius.all(large),
    MessageClusterRole.first => const BorderRadius.only(
      topLeft: large,
      topRight: large,
      bottomLeft: flat,
      bottomRight: flat,
    ),
    MessageClusterRole.middle => const BorderRadius.all(flat),
    MessageClusterRole.last => const BorderRadius.only(
      topLeft: flat,
      topRight: flat,
      bottomLeft: large,
      bottomRight: large,
    ),
  };
}

Border? _textBorderForRole({
  required MessageClusterRole role,
  required Color color,
}) {
  return switch (role) {
    MessageClusterRole.standalone => Border.all(color: color, width: 1),
    MessageClusterRole.first => Border(
      top: BorderSide(color: color),
      left: BorderSide(color: color),
      right: BorderSide(color: color),
    ),
    MessageClusterRole.middle => Border(
      left: BorderSide(color: color),
      right: BorderSide(color: color),
    ),
    MessageClusterRole.last => Border(
      left: BorderSide(color: color),
      right: BorderSide(color: color),
      bottom: BorderSide(color: color),
    ),
  };
}

class MessageShell extends StatelessWidget {
  const MessageShell({
    super.key,
    required this.isMe,
    required this.child,
    this.metadata,
    this.layout = MessageLayout.bubble,
    this.grouping = MessageGroupingStyle.standalone,
  });

  final bool isMe;
  final Widget child;
  final Widget? metadata;
  final MessageLayout layout;
  final MessageGroupingStyle grouping;

  @override
  Widget build(BuildContext context) {
    final bubbleRow = switch (layout) {
      MessageLayout.bubble => Row(
        mainAxisAlignment: isMe
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: MsgTheme.maxBubbleWidth,
            ),
            child: child,
          ),
        ],
      ),
      MessageLayout.fullWidth => child,
    };

    return Padding(
      padding: switch (layout) {
        MessageLayout.bubble => const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 12,
        ),
        MessageLayout.fullWidth => EdgeInsets.only(
          top: grouping.compactTopSpacing ? 0 : 10,
          bottom: grouping.compactBottomSpacing ? 0 : 6,
        ),
      },
      child: Column(
        crossAxisAlignment: switch (layout) {
          MessageLayout.bubble =>
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          MessageLayout.fullWidth => CrossAxisAlignment.stretch,
        },
        children: [
          bubbleRow,
          if (metadata != null) ...[MsgTheme.gapXS, metadata!],
        ],
      ),
    );
  }
}

class MetadataLine extends ConsumerWidget {
  const MetadataLine({
    super.key,
    required this.sender,
    required this.sentAt,
    required this.messageId,
    this.layout = MessageLayout.bubble,
  });

  final String sender;
  final DateTime sentAt;
  final int messageId;
  final MessageLayout layout;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final developerMode = ref.watch(developerModeProvider).valueOrNull;
    final isDeveloperMode = developerMode == DeveloperModeValue.developer;
    final formattedDateTime = _formatDateTime(sentAt);
    final metadataText = isDeveloperMode
        ? '$sender * $formattedDateTime * ID: $messageId'
        : '$sender * $formattedDateTime';

    return Text(
      metadataText,
      style: TextStyle(
        color: layout == MessageLayout.fullWidth
            ? colors.content.textSecondary
            : colors.messageBubble(MessageBubble.metadata),
        fontSize: layout == MessageLayout.fullWidth ? 12 : 11,
        height: 1.2,
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final weekday = weekdays[dateTime.weekday - 1];
    final month = months[dateTime.month - 1];
    final day = dateTime.day;
    final hour = dateTime.hour;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final hour12 = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    final amPm = hour >= 12 ? 'PM' : 'AM';
    final year = dateTime.year;
    return '$weekday, $month $day, $year $hour12:$minute $amPm';
  }
}

class TextMessageTile extends ConsumerWidget {
  const TextMessageTile({
    super.key,
    required this.isMe,
    required this.text,
    required this.sender,
    required this.sentAt,
    required this.messageId,
    this.highlight,
    this.layout = MessageLayout.bubble,
    this.grouping = MessageGroupingStyle.standalone,
  });

  final bool isMe;
  final String text;
  final String sender;
  final DateTime sentAt;
  final int messageId;
  final String? highlight;
  final MessageLayout layout;
  final MessageGroupingStyle grouping;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final developerMode = ref.watch(developerModeProvider).valueOrNull;
    final isDeveloperMode = developerMode == DeveloperModeValue.developer;
    final bg = switch (layout) {
      MessageLayout.bubble =>
        isMe
            ? colors.messageBubble(MessageBubble.sentBg)
            : colors.messageBubble(MessageBubble.receivedBg),
      MessageLayout.fullWidth =>
        isMe
            ? grouping.softenContinuationChrome
                  ? Color.lerp(
                      colors.messagePanels.accentTintSoft,
                      colors.messagePanels.coolPanelSurface,
                      0.18,
                    )!
                  : colors.messagePanels.accentTintSoft
            : grouping.softenContinuationChrome
            ? Color.lerp(
                colors.messagePanels.receivedSurface,
                colors.messagePanels.coolPanelSurface,
                0.22,
              )!
            : colors.messagePanels.receivedSurface,
    };
    final borderColor = switch (layout) {
      MessageLayout.bubble => null,
      MessageLayout.fullWidth =>
        isMe
            ? grouping.softenContinuationChrome
                  ? colors.messagePanels.accentBorderSoft.withValues(
                      alpha: 0.72,
                    )
                  : colors.messagePanels.accentBorderSoft
            : grouping.softenContinuationChrome
            ? colors.messagePanels.cardBorder.withValues(alpha: 0.78)
            : colors.messagePanels.cardBorder,
    };
    final style = TextStyle(
      color: layout == MessageLayout.fullWidth
          ? colors.content.textPrimary
          : isMe
          ? colors.messageBubble(MessageBubble.sentText)
          : colors.messageBubble(MessageBubble.receivedText),
      height: 1.25,
      fontSize: 14.5,
    );
    final highlightStyle = style.copyWith(
      backgroundColor: layout == MessageLayout.fullWidth
          ? isMe
                ? colors.messagePanels.selectionTint
                : colors.messagePanels.supportSurface
          : isMe
          ? colors.messageBubble(MessageBubble.sentHighlight)
          : colors.messageBubble(MessageBubble.receivedHighlight),
    );
    final contentSpan = _buildContentSpan(
      baseStyle: style,
      highlightStyle: highlightStyle,
    );

    return MessageShell(
      isMe: isMe,
      layout: layout,
      grouping: grouping,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: MsgTheme.bubblePadding.horizontal / 2,
          vertical:
              layout == MessageLayout.fullWidth && grouping.compactTopSpacing
              ? 8.5
              : MsgTheme.bubblePadding.vertical / 2,
        ),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: layout == MessageLayout.fullWidth
              ? _textBorderRadiusForRole(grouping.role)
              : MsgTheme.textRadius,
          border: borderColor == null
              ? null
              : layout == MessageLayout.fullWidth
              ? _textBorderForRole(role: grouping.role, color: borderColor)
              : Border.all(color: borderColor, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (grouping.showSenderHeader) ...[
              Row(
                children: [
                  Expanded(
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: sender,
                            style: TextStyle(
                              color: colors.content.textSecondary,
                              fontSize: 12,
                              height: 1.2,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          TextSpan(
                            text: ' — ',
                            style: TextStyle(
                              color: colors.content.textTertiary,
                              fontSize: 12,
                              height: 1.2,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          TextSpan(
                            text: _formatCompactMessageDateTime(sentAt),
                            style: TextStyle(
                              color: colors.content.textSecondaryQuiet,
                              fontSize: 12,
                              height: 1.2,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (isDeveloperMode) ...[
                    const SizedBox(width: 12),
                    Text(
                      _formatMessageIdLabel(messageId),
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        color: colors.content.textSecondary,
                        fontSize: 12,
                        height: 1.2,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 8),
            ],
            if (grouping.showSenderHeader)
              SelectableText.rich(contentSpan)
            else
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(child: SelectableText.rich(contentSpan)),
                  const SizedBox(width: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      _formatClusterContinuationTime(sentAt),
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        color: colors.content.textSecondaryQuiet,
                        fontSize: 11,
                        height: 1.1,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  TextSpan _buildContentSpan({
    required TextStyle baseStyle,
    required TextStyle highlightStyle,
  }) {
    final query = highlight?.trim();
    if (query == null || query.isEmpty) {
      return TextSpan(text: text, style: baseStyle);
    }

    final lowerText = text.toLowerCase();
    final lowerQuery = query.toLowerCase();
    final spans = <TextSpan>[];
    var start = 0;
    var matchIndex = lowerText.indexOf(lowerQuery, start);

    while (matchIndex != -1) {
      if (matchIndex > start) {
        spans.add(
          TextSpan(text: text.substring(start, matchIndex), style: baseStyle),
        );
      }

      spans.add(
        TextSpan(
          text: text.substring(matchIndex, matchIndex + query.length),
          style: highlightStyle,
        ),
      );
      start = matchIndex + query.length;
      matchIndex = lowerText.indexOf(lowerQuery, start);
    }

    if (start < text.length) {
      spans.add(TextSpan(text: text.substring(start), style: baseStyle));
    }

    if (spans.isEmpty) {
      return TextSpan(text: text, style: baseStyle);
    }

    return TextSpan(children: spans);
  }
}

class ImageMessageTile extends StatelessWidget {
  const ImageMessageTile({
    super.key,
    required this.isMe,
    required this.attachment,
    required this.sender,
    required this.sentAt,
    required this.messageId,
    this.layout = MessageLayout.bubble,
    this.grouping = MessageGroupingStyle.standalone,
  });

  final bool isMe;
  final AttachmentInfo attachment;
  final String sender;
  final DateTime sentAt;
  final int messageId;
  final MessageLayout layout;
  final MessageGroupingStyle grouping;

  @override
  Widget build(BuildContext context) {
    final resolvedPath = attachment.resolvedLocalPath();
    final file = resolvedPath != null ? File(resolvedPath) : null;
    final exists = file?.existsSync() ?? false;
    final aspectRatio = attachment.aspectRatio ?? 4 / 3;

    return MessageShell(
      isMe: isMe,
      layout: layout,
      grouping: grouping,
      metadata: _alignMetadataForLayout(
        layout: layout,
        isMe: isMe,
        child: MetadataLine(
          sender: sender,
          sentAt: sentAt,
          messageId: messageId,
          layout: layout,
        ),
      ),
      child: _alignMediaForLayout(
        layout: layout,
        isMe: isMe,
        child: ClipRRect(
          borderRadius: MsgTheme.mediaRadius,
          child: _IntrinsicSizedMedia(
            child: AspectRatio(
              aspectRatio: aspectRatio,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  const ColoredBox(color: Colors.black12),
                  if (exists)
                    Image.file(
                      file!,
                      fit: BoxFit.cover,
                      filterQuality: FilterQuality.medium,
                    )
                  else
                    const Center(child: Text('Image unavailable')),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class VideoMessageTile extends ConsumerStatefulWidget {
  const VideoMessageTile({
    super.key,
    required this.isMe,
    required this.attachment,
    required this.sender,
    required this.sentAt,
    required this.messageId,
    this.layout = MessageLayout.bubble,
    this.grouping = MessageGroupingStyle.standalone,
  });

  final bool isMe;
  final AttachmentInfo attachment;
  final String sender;
  final DateTime sentAt;
  final int messageId;
  final MessageLayout layout;
  final MessageGroupingStyle grouping;

  @override
  ConsumerState<VideoMessageTile> createState() => _VideoMessageTileState();
}

class _VideoMessageTileState extends ConsumerState<VideoMessageTile> {
  VideoPlayerController? _controller;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    final resolvedPath = widget.attachment.resolvedLocalPath();
    if (resolvedPath == null) {
      return;
    }
    final file = File(resolvedPath);
    if (!file.existsSync()) {
      return;
    }
    _controller = VideoPlayerController.file(file)
      ..setLooping(true)
      ..initialize().then((_) {
        if (!mounted) {
          return;
        }
        setState(() {
          _ready = true;
        });
      });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _toggle() {
    if (_controller == null || !_ready) {
      return;
    }
    if (_controller!.value.isPlaying) {
      _controller!.pause();
    } else {
      _controller!.play();
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final aspectRatio = widget.attachment.aspectRatio ?? 16 / 9;
    final hasVideo = _controller != null;

    return MessageShell(
      isMe: widget.isMe,
      layout: widget.layout,
      grouping: widget.grouping,
      metadata: _alignMetadataForLayout(
        layout: widget.layout,
        isMe: widget.isMe,
        child: MetadataLine(
          sender: widget.sender,
          sentAt: widget.sentAt,
          messageId: widget.messageId,
          layout: widget.layout,
        ),
      ),
      child: _alignMediaForLayout(
        layout: widget.layout,
        isMe: widget.isMe,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: colors.surfaces.surface,
            borderRadius: MsgTheme.mediaRadius,
            border: Border.all(color: colors.lines.borderSubtle),
          ),
          child: ClipRRect(
            borderRadius: MsgTheme.mediaRadius,
            child: _IntrinsicSizedMedia(
              child: AspectRatio(
                aspectRatio: aspectRatio,
                child: Stack(
                  fit: StackFit.expand,
                  alignment: Alignment.center,
                  children: [
                    const ColoredBox(color: Colors.black26),
                    if (hasVideo && _ready)
                      VideoPlayer(_controller!)
                    else if (hasVideo)
                      const Center(
                        child: SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    else
                      const Center(child: Text('Video unavailable')),
                    if (hasVideo)
                      Positioned.fill(
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: _toggle,
                            child: AnimatedOpacity(
                              duration: const Duration(milliseconds: 180),
                              opacity: _controller!.value.isPlaying ? 0.0 : 1.0,
                              child: Center(
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: const BoxDecoration(
                                    color: Colors.black54,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    _controller!.value.isPlaying
                                        ? Icons.pause
                                        : Icons.play_arrow,
                                    size: 28,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    if (hasVideo && _ready)
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: VideoProgressIndicator(
                          _controller!,
                          allowScrubbing: true,
                          padding: const EdgeInsets.symmetric(
                            vertical: 6,
                            horizontal: 8,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class LinkPreviewTile extends ConsumerWidget {
  const LinkPreviewTile({
    super.key,
    required this.isMe,
    required this.url,
    required this.sender,
    required this.sentAt,
    required this.messageId,
    this.previewImage,
    this.previewImageWidget,
    this.previewText,
    this.layout = MessageLayout.bubble,
    this.grouping = MessageGroupingStyle.standalone,
  }) : assert(
         previewImage != null || previewImageWidget != null,
         'Provide either previewImage or previewImageWidget',
       );

  final bool isMe;
  final Uri url;
  final String sender;
  final DateTime sentAt;
  final int messageId;
  final File? previewImage;
  final Widget? previewImageWidget;
  final String? previewText;
  final MessageLayout layout;
  final MessageGroupingStyle grouping;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final domain = url.host;
    final image =
        previewImageWidget ??
        Image.file(
          previewImage!,
          fit: BoxFit.cover,
          filterQuality: FilterQuality.medium,
        );

    final card = DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surfaces.surface,
        borderRadius: MsgTheme.mediaRadius,
        border: Border.all(color: colors.lines.borderSubtle),
      ),
      child: ClipRRect(
        borderRadius: MsgTheme.mediaRadius,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _IntrinsicSizedMedia(child: image),
            Container(
              color: colors.messageBubble(MessageBubble.linkBanner),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              child: Text(
                domain,
                style: TextStyle(
                  color: colors.messageBubble(MessageBubble.linkBannerText),
                  fontSize: 12.5,
                  height: 1.2,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if ((previewText ?? '').trim().isNotEmpty)
              Container(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                child: Text(
                  previewText!,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.25,
                    color: colors.content.textPrimary,
                  ),
                ),
              ),
          ],
        ),
      ),
    );

    return MessageShell(
      isMe: isMe,
      layout: layout,
      grouping: grouping,
      metadata: MetadataLine(
        sender: sender,
        sentAt: sentAt,
        messageId: messageId,
        layout: layout,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(onTap: () => _launch(url), child: card),
      ),
    );
  }

  Future<void> _launch(Uri target) async {
    if (!await launchUrl(target, mode: LaunchMode.externalApplication)) {
      // Optional: surface failure to caller.
    }
  }
}

class _IntrinsicSizedMedia extends StatelessWidget {
  const _IntrinsicSizedMedia({required this.child});

  final Widget child;

  static const double _maxHeight = 420;
  static const double _minHeight = 140;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight: _minHeight,
            maxHeight: _maxHeight,
          ),
          child: child,
        );
      },
    );
  }
}

enum MsgType { text, image, video, link }

class DemoMessage {
  DemoMessage({
    required this.type,
    required this.isMe,
    required this.sender,
    required this.sentAt,
    required this.messageId,
    this.text,
    this.file,
    this.url,
    this.previewText,
  });

  final MsgType type;
  final bool isMe;
  final String sender;
  final DateTime sentAt;
  final int messageId;
  final String? text;
  final File? file;
  final Uri? url;
  final String? previewText;
}

class DemoConversationList extends StatelessWidget {
  const DemoConversationList({super.key, required this.items});

  final List<DemoMessage> items;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: MsgTheme.convoHPad(),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final message = items[index];
        switch (message.type) {
          case MsgType.text:
            return TextMessageTile(
              isMe: message.isMe,
              text: message.text ?? '',
              sender: message.sender,
              sentAt: message.sentAt,
              messageId: message.messageId,
            );
          case MsgType.image:
            return ImageMessageTile(
              isMe: message.isMe,
              attachment: AttachmentInfo(
                id: message.messageId,
                localPath: message.file?.path,
                mimeType: 'image/*',
                transferName: message.file?.path,
              ),
              sender: message.sender,
              sentAt: message.sentAt,
              messageId: message.messageId,
            );
          case MsgType.video:
            return VideoMessageTile(
              isMe: message.isMe,
              attachment: AttachmentInfo(
                id: message.messageId,
                localPath: message.file?.path,
                mimeType: 'video/*',
                transferName: message.file?.path,
              ),
              sender: message.sender,
              sentAt: message.sentAt,
              messageId: message.messageId,
            );
          case MsgType.link:
            return LinkPreviewTile(
              isMe: message.isMe,
              url: message.url!,
              sender: message.sender,
              sentAt: message.sentAt,
              messageId: message.messageId,
              previewImage: message.file,
              previewText: message.previewText,
            );
        }
      },
    );
  }
}
