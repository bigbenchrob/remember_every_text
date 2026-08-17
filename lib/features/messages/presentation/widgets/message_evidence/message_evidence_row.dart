import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../../config/theme/colors/theme_colors.dart';
import '../../../../../config/theme/widgets/buttons/app_header_action_button.dart';
import '../../../../../config/theme/widgets/referential_correspondence_decoration.dart';
import '../../../../../essentials/debug/feature_level_providers.dart'
    show DeveloperModeValue, developerModeProvider;
import '../../../application/message_evidence/message_evidence_spine_provider.dart';
import '../../../domain/message_evidence/message_evidence_row_data.dart';
import '../../../domain/message_evidence/message_evidence_scope.dart';
import '../../view_model/shared/display_widgets/new_display_widgets.dart';
import 'message_attachment_evidence_tiles.dart';

class MessageEvidenceRow extends ConsumerStatefulWidget {
  const MessageEvidenceRow({
    required this.message,
    required this.evidenceScope,
    this.isAnchorMessage = false,
    this.correspondencePulseId = 0,
    this.searchQuery = '',
    this.onOpenConversationContext,
    super.key,
  });

  final MessageEvidenceRowData message;
  final MessageEvidenceScope evidenceScope;
  final bool isAnchorMessage;
  final int correspondencePulseId;
  final String searchQuery;
  final VoidCallback? onOpenConversationContext;

  @override
  ConsumerState<MessageEvidenceRow> createState() => _MessageEvidenceRowState();
}

class _MessageEvidenceRowState extends ConsumerState<MessageEvidenceRow>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 760),
  );
  late final Animation<double> _pulse = TweenSequence<double>([
    TweenSequenceItem(
      tween: Tween<double>(
        begin: 0,
        end: 1,
      ).chain(CurveTween(curve: Curves.easeOutCubic)),
      weight: 150,
    ),
    TweenSequenceItem(tween: ConstantTween<double>(1), weight: 360),
    TweenSequenceItem(
      tween: Tween<double>(
        begin: 1,
        end: 0,
      ).chain(CurveTween(curve: Curves.easeOutCubic)),
      weight: 250,
    ),
  ]).animate(_pulseController);
  int _lastPulseId = 0;

  @override
  void initState() {
    super.initState();
    _lastPulseId = widget.correspondencePulseId;
  }

  @override
  void didUpdateWidget(covariant MessageEvidenceRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.isAnchorMessage) {
      _pulseController.stop();
      _pulseController.value = 0;
      _lastPulseId = widget.correspondencePulseId;
      return;
    }

    if (widget.correspondencePulseId != _lastPulseId) {
      _lastPulseId = widget.correspondencePulseId;
      if (_motionDisabled(context)) {
        _pulseController.value = 0;
        return;
      }
      _pulseController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final developerMode = ref.watch(developerModeProvider).valueOrNull;
    final isDeveloperMode = developerMode == DeveloperModeValue.developer;
    final senderLabel = _conversationMessageSenderLabel(widget.message);
    final senderHandleLabel = _senderHandleLabelForScope(
      scope: widget.evidenceScope,
      message: widget.message,
      isDeveloperMode: isDeveloperMode,
    );
    final row = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextMessageTile(
          isMe: widget.message.isFromMe,
          text: _messageDisplayText(widget.message.text),
          sender: senderLabel,
          senderHandleLabel: senderHandleLabel,
          sentAt: _messageDate(widget.message.dateUtc),
          messageId: widget.message.messageId,
          highlight: widget.searchQuery,
          layout: MessageLayout.fullWidth,
        ),
        if (widget.message.attachmentCount > 0) ...[
          const SizedBox(height: 2),
          _MessageAttachments(
            evidenceScope: widget.evidenceScope,
            messageId: widget.message.messageId,
            expectedAttachmentCount: widget.message.attachmentCount,
            isFromMe: widget.message.isFromMe,
            sender: senderLabel,
            senderHandleLabel: senderHandleLabel,
            sentAt: _messageDate(widget.message.dateUtc),
            messageText: widget.message.text,
          ),
        ],
        if (widget.onOpenConversationContext != null) ...[
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerRight,
            child: AppHeaderActionButton(
              icon: CupertinoIcons.arrowshape_turn_up_right,
              label: 'In conversation',
              onPressed: widget.onOpenConversationContext!,
            ),
          ),
        ],
      ],
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: AnimatedBuilder(
        animation: _pulse,
        builder: (context, child) {
          final pulse = widget.isAnchorMessage ? _pulse.value : 0.0;
          return DecoratedBox(
            decoration: widget.isAnchorMessage
                ? referentialCorrespondenceDecoration(
                    colors: colors.messagePanels,
                    pulse: pulse,
                    borderRadius: BorderRadius.circular(10),
                  )
                : const BoxDecoration(),
            child: Padding(
              padding: EdgeInsets.all(widget.isAnchorMessage ? 4 : 0),
              child: child,
            ),
          );
        },
        child: row,
      ),
    );
  }

  bool _motionDisabled(BuildContext context) {
    final mediaQuery = MediaQuery.maybeOf(context);
    return mediaQuery?.disableAnimations ?? false;
  }
}

class _MessageAttachments extends ConsumerWidget {
  const _MessageAttachments({
    required this.evidenceScope,
    required this.messageId,
    required this.expectedAttachmentCount,
    required this.isFromMe,
    required this.sender,
    required this.sentAt,
    this.messageText,
    this.senderHandleLabel,
  });

  final MessageEvidenceScope evidenceScope;
  final int messageId;
  final int expectedAttachmentCount;
  final bool isFromMe;
  final String sender;
  final DateTime sentAt;
  final String? messageText;
  final String? senderHandleLabel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final attachmentsAsync = ref.watch(
      messageEvidenceAttachmentsProvider(
        scope: evidenceScope,
        messageId: messageId,
      ),
    );
    return attachmentsAsync.when(
      data: (attachments) {
        if (attachments.isEmpty) {
          return Text('attachments: $expectedAttachmentCount linked');
        }
        return MessageAttachmentEvidenceTiles(
          attachments: attachments,
          isFromMe: isFromMe,
          sender: sender,
          senderHandleLabel: senderHandleLabel,
          sentAt: sentAt,
          messageId: messageId,
          messageText: messageText,
        );
      },
      loading: () => Text('attachments: $expectedAttachmentCount loading'),
      error: (error, stackTrace) => Text('attachments failed: $error'),
    );
  }
}

String? _senderHandleLabelForScope({
  required MessageEvidenceScope scope,
  required MessageEvidenceRowData message,
  required bool isDeveloperMode,
}) {
  final handleLabel = message.senderRawHandleLabel?.trim();
  if (handleLabel == null || handleLabel.isEmpty) {
    return null;
  }
  if (isDeveloperMode || _isExplicitHandleScope(scope)) {
    return handleLabel;
  }
  return null;
}

bool _isExplicitHandleScope(MessageEvidenceScope scope) {
  return switch (scope) {
    HandleMessagesEvidenceScope() => true,
    ContactHandleMessagesEvidenceScope() => true,
    ContactMessageSearchEvidenceScope(:final handleId) => handleId != null,
    _ => false,
  };
}

DateTime _messageDate(String? value) {
  if (value == null || value.isEmpty) {
    return DateTime.fromMillisecondsSinceEpoch(0);
  }
  return DateTime.tryParse(value)?.toLocal() ??
      DateTime.fromMillisecondsSinceEpoch(0);
}

String _messageDisplayText(String? value) {
  if (value != null && value.isNotEmpty) {
    return value;
  }
  return 'no text';
}

String _conversationMessageSenderLabel(MessageEvidenceRowData message) {
  if (message.isSelfConversation) {
    return 'self';
  }
  if (message.isFromMe) {
    final recipient = message.conversationDisplayTitle?.trim();
    if (recipient != null && recipient.isNotEmpty) {
      return 'from me to $recipient';
    }
    return 'from me';
  }
  if (message.senderIsMe) {
    return 'received from me';
  }
  return 'received from ${_messageSenderLabel(message)}';
}

String _messageSenderLabel(MessageEvidenceRowData message) {
  final handle = message.senderDisplayHandle?.trim();
  if (handle != null && handle.isNotEmpty) {
    return handle;
  }
  if (message.senderCanonicalHandleId != null) {
    return 'canonical handle ${message.senderCanonicalHandleId}';
  }
  if (message.senderHandleId != null) {
    return 'handle ${message.senderHandleId}';
  }
  return 'unknown sender';
}
