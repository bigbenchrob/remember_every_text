import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../../config/theme/colors/theme_colors.dart';
import '../../../../../essentials/debug/feature_level_providers.dart';
import '../../../application/message_evidence/message_evidence_spine_provider.dart';
import '../../../domain/message_evidence/message_evidence_row_data.dart';
import '../../../domain/message_evidence/message_evidence_scope.dart';
import '../../view_model/shared/display_widgets/new_display_widgets.dart';
import 'message_attachment_evidence_tiles.dart';
import 'message_evidence_badges.dart';

class MessageEvidenceRow extends ConsumerWidget {
  const MessageEvidenceRow({
    required this.message,
    required this.evidenceScope,
    this.isAnchorMessage = false,
    this.searchQuery = '',
    super.key,
  });

  final MessageEvidenceRowData message;
  final MessageEvidenceScope evidenceScope;
  final bool isAnchorMessage;
  final String searchQuery;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final developerMode = ref.watch(developerModeProvider).valueOrNull;
    final isDeveloperMode = developerMode == DeveloperModeValue.developer;
    final senderLabel = _conversationMessageSenderLabel(message);
    final senderHandleLabel = _senderHandleLabelForScope(
      scope: evidenceScope,
      message: message,
      isDeveloperMode: isDeveloperMode,
    );
    final associatedMessageId = message.associatedMessageId;
    final semanticBadges = <String>[
      if (associatedMessageId != null) 'associated $associatedMessageId',
      ..._messageSemanticBadges(message),
    ];
    final row = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextMessageTile(
          isMe: message.isFromMe,
          text: _messageDisplayText(message.text),
          sender: senderLabel,
          senderHandleLabel: senderHandleLabel,
          sentAt: _messageDate(message.dateUtc),
          messageId: message.messageId,
          highlight: searchQuery,
          layout: MessageLayout.fullWidth,
        ),
        MessageEvidenceBadgeStrip(labels: semanticBadges),
        if (message.attachmentCount > 0) ...[
          const SizedBox(height: 2),
          _MessageAttachments(
            evidenceScope: evidenceScope,
            messageId: message.messageId,
            expectedAttachmentCount: message.attachmentCount,
            isFromMe: message.isFromMe,
            sender: senderLabel,
            senderHandleLabel: senderHandleLabel,
            sentAt: _messageDate(message.dateUtc),
            messageText: message.text,
          ),
        ],
      ],
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: isAnchorMessage
              ? Border.all(color: colors.accents.primary, width: 2)
              : null,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: EdgeInsets.all(isAnchorMessage ? 4 : 0),
          child: row,
        ),
      ),
    );
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
  final direction = message.isFromMe ? 'from me' : 'received';
  return '$direction | ${_messageSenderLabel(message)}';
}

String _messageSenderLabel(MessageEvidenceRowData message) {
  if (message.isFromMe) {
    return 'me';
  }
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

List<String> _messageSemanticBadges(MessageEvidenceRowData message) {
  final badges = <String>[];
  final semanticKind = message.semanticKind?.trim();
  if (semanticKind != null && semanticKind.isNotEmpty) {
    badges.add(semanticKind);
  }
  final itemKind = message.itemKind?.trim();
  if (itemKind != null && itemKind.isNotEmpty) {
    badges.add(itemKind);
  }
  if (message.isSystemMessage) {
    badges.add('system');
  }
  if (message.isSparseArtifact) {
    badges.add('sparse');
  }
  if (message.hasAttributedBodySource) {
    badges.add('attributed body');
  }
  if (message.hasMessageSummaryInfo) {
    badges.add('summary info');
  }
  if (message.hasPayloadDataSource) {
    badges.add('payload');
  }
  if (message.errorCode != null) {
    badges.add('error ${message.errorCode}');
  }
  return badges;
}
