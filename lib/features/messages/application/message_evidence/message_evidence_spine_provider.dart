import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../essentials/conversation_graph/application/chat_summaries/chat_summary_provider.dart';
import '../../../../essentials/conversation_graph/application/contacts/contact_graph_provider.dart';
import '../../../../essentials/conversation_graph/application/conversations/conversation.dart';
import '../../../../essentials/conversation_graph/application/conversations/conversation_reader_provider.dart';
import '../../../../essentials/conversation_graph/application/messages/message_graph_reader_provider.dart';
import '../../../../essentials/source_scoped_import/domain/known_sources.dart';
import '../../../../essentials/source_scoped_import/domain/source_scoped_row_key.dart';
import '../../domain/message_evidence/message_evidence_scope.dart';
import '../../domain/message_evidence/message_evidence_skeleton.dart';
import '../../infrastructure/repositories/recovered_unlinked_messages_provider.dart';
import 'graph_attachment_evidence.dart';

part 'message_evidence_spine_provider.g.dart';

@riverpod
Future<MessageEvidenceTimelineSkeleton> messageEvidenceTimelineSkeleton(
  Ref ref, {
  required MessageEvidenceScope scope,
}) async {
  return switch (scope) {
    ContactAllMessagesEvidenceScope(:final contactId) =>
      _contactAllMessagesTimelineSkeleton(ref, contactId: contactId),
    ContactHandleMessagesEvidenceScope(:final contactId, :final handleId) =>
      _contactHandleMessagesTimelineSkeleton(
        ref,
        contactId: contactId,
        handleId: handleId,
      ),
    ContactMessageSearchEvidenceScope(
      :final contactId,
      :final query,
      :final handleId,
    ) =>
      _contactMessageSearchTimelineSkeleton(
        ref,
        contactId: contactId,
        query: query,
        handleId: handleId,
      ),
    GlobalMessagesEvidenceScope() => _globalMessagesTimelineSkeleton(ref),
    MessageSearchEvidenceScope(:final query) =>
      _globalMessageSearchTimelineSkeleton(ref, query: query),
    HandleMessagesEvidenceScope(:final handleId) =>
      _handleMessagesTimelineSkeleton(ref, handleId: handleId),
    ConversationEvidenceScope(:final conversationId) =>
      _conversationTimelineSkeleton(ref, conversationId: conversationId),
    SearchResultContextEvidenceScope(
      :final messageId,
      :final chatId,
      :final beforeCount,
      :final afterCount,
    ) =>
      _searchResultContextSkeleton(
        ref,
        messageId: messageId,
        chatId: chatId,
        beforeCount: beforeCount,
        afterCount: afterCount,
      ),
    RecoveredMessagesEvidenceScope(
      :final contactId,
      :final onlyNoHandleFromMe,
    ) =>
      _recoveredMessagesTimelineSkeleton(
        ref,
        contactId: contactId,
        onlyNoHandleFromMe: onlyNoHandleFromMe,
      ),
  };
}

@riverpod
Future<ConversationMessage?> graphMessageEvidenceRow(
  Ref ref, {
  required MessageEvidenceScope scope,
  required int messageId,
}) async {
  return switch (scope) {
    ContactAllMessagesEvidenceScope(:final contactId) => ref.watch(
      contactPageGraphMessageByIdProvider(
        contactId: contactId,
        messageId: messageId,
      ).future,
    ),
    ContactHandleMessagesEvidenceScope(:final contactId, :final handleId) =>
      ref.watch(
        contactPageGraphHandleMessageByIdProvider(
          contactId: contactId,
          handleId: handleId,
          messageId: messageId,
        ).future,
      ),
    ContactMessageSearchEvidenceScope(:final contactId, :final handleId) =>
      handleId == null
          ? ref.watch(
              contactPageGraphMessageByIdProvider(
                contactId: contactId,
                messageId: messageId,
              ).future,
            )
          : ref.watch(
              contactPageGraphHandleMessageByIdProvider(
                contactId: contactId,
                handleId: handleId,
                messageId: messageId,
              ).future,
            ),
    MessageSearchEvidenceScope() || GlobalMessagesEvidenceScope() =>
      _globalMessageById(ref, messageId: messageId),
    HandleMessagesEvidenceScope(:final handleId) => _handleMessageById(
      ref,
      handleId: handleId,
      messageId: messageId,
    ),
    ConversationEvidenceScope(:final conversationId) =>
      _conversationMessageById(
        ref,
        conversationId: conversationId,
        messageId: messageId,
      ),
    SearchResultContextEvidenceScope() => _globalMessageById(
      ref,
      messageId: messageId,
    ),
    RecoveredMessagesEvidenceScope(
      :final contactId,
      :final onlyNoHandleFromMe,
    ) =>
      _recoveredMessageById(
        ref,
        contactId: contactId,
        onlyNoHandleFromMe: onlyNoHandleFromMe,
        messageId: messageId,
      ),
  };
}

@riverpod
Future<List<GraphAttachmentEvidence>> messageEvidenceAttachments(
  Ref ref, {
  required MessageEvidenceScope scope,
  required int messageId,
}) async {
  return switch (scope) {
    RecoveredMessagesEvidenceScope(
      :final contactId,
      :final onlyNoHandleFromMe,
    ) =>
      _recoveredMessageAttachments(
        ref,
        contactId: contactId,
        onlyNoHandleFromMe: onlyNoHandleFromMe,
        messageId: messageId,
      ),
    ContactAllMessagesEvidenceScope() ||
    ContactHandleMessagesEvidenceScope() ||
    ContactMessageSearchEvidenceScope() ||
    MessageSearchEvidenceScope() ||
    GlobalMessagesEvidenceScope() ||
    HandleMessagesEvidenceScope() ||
    ConversationEvidenceScope() ||
    SearchResultContextEvidenceScope() => _graphMessageAttachments(
      ref,
      messageId: messageId,
    ),
  };
}

@riverpod
Future<List<int>> messageEvidenceTextMatchIds(
  Ref ref, {
  required MessageEvidenceScope scope,
  required String query,
}) async {
  final normalizedQuery = query.trim();
  if (normalizedQuery.isEmpty) {
    return const <int>[];
  }

  return switch (scope) {
    ConversationEvidenceScope(:final conversationId) =>
      _conversationMessageIdsMatchingText(
        ref,
        conversationId: conversationId,
        query: normalizedQuery,
      ),
    GlobalMessagesEvidenceScope() => _globalMessageIdsMatchingText(
      ref,
      query: normalizedQuery,
    ),
    MessageSearchEvidenceScope() => _globalMessageIdsMatchingText(
      ref,
      query: normalizedQuery,
    ),
    ContactAllMessagesEvidenceScope(:final contactId) =>
      _contactMessageIdsMatchingText(
        ref,
        contactId: contactId,
        query: normalizedQuery,
      ),
    ContactHandleMessagesEvidenceScope(:final contactId, :final handleId) =>
      _contactMessageIdsMatchingText(
        ref,
        contactId: contactId,
        query: normalizedQuery,
        handleId: handleId,
      ),
    ContactMessageSearchEvidenceScope(:final contactId, :final handleId) =>
      _contactMessageIdsMatchingText(
        ref,
        contactId: contactId,
        query: normalizedQuery,
        handleId: handleId,
      ),
    HandleMessagesEvidenceScope() => throw UnimplementedError(
      'Handle evidence text matches are not part of this slice.',
    ),
    SearchResultContextEvidenceScope() => throw UnimplementedError(
      'Search result context text matches are not part of this slice.',
    ),
    RecoveredMessagesEvidenceScope(
      :final contactId,
      :final onlyNoHandleFromMe,
    ) =>
      _recoveredMessageIdsMatchingText(
        ref,
        contactId: contactId,
        onlyNoHandleFromMe: onlyNoHandleFromMe,
        query: normalizedQuery,
      ),
  };
}

Future<MessageEvidenceTimelineSkeleton> _conversationTimelineSkeleton(
  Ref ref, {
  required int conversationId,
}) async {
  final reader = await ref.watch(conversationReaderProvider.future);
  final entries = await reader.readMessageTimeline(
    conversationId: conversationId,
  );
  return MessageEvidenceTimelineSkeleton(
    entries: [
      for (final entry in entries)
        MessageEvidenceSkeletonEntry(
          messageId: entry.messageId,
          dateUtc: entry.dateUtc,
          monthKey: entry.monthKey,
        ),
    ],
  );
}

Future<List<int>> _conversationMessageIdsMatchingText(
  Ref ref, {
  required int conversationId,
  required String query,
}) async {
  final reader = await ref.watch(conversationReaderProvider.future);
  return reader.readMessageIdsMatchingText(
    conversationId: conversationId,
    query: query,
  );
}

Future<ConversationMessage?> _conversationMessageById(
  Ref ref, {
  required int conversationId,
  required int messageId,
}) async {
  final reader = await ref.watch(conversationReaderProvider.future);
  return reader.readMessageById(
    conversationId: conversationId,
    messageId: messageId,
  );
}

Future<MessageEvidenceTimelineSkeleton> _globalMessagesTimelineSkeleton(
  Ref ref,
) async {
  final reader = await ref.watch(messageGraphReaderProvider.future);
  final entries = await reader.readGlobalMessageTimeline();
  return MessageEvidenceTimelineSkeleton(
    entries: [
      for (final entry in entries)
        MessageEvidenceSkeletonEntry(
          messageId: entry.messageId,
          dateUtc: entry.dateUtc,
          monthKey: entry.monthKey,
        ),
    ],
  );
}

Future<MessageEvidenceTimelineSkeleton> _globalMessageSearchTimelineSkeleton(
  Ref ref, {
  required String query,
}) async {
  final normalizedQuery = query.trim();
  if (normalizedQuery.isEmpty) {
    return const MessageEvidenceTimelineSkeleton(entries: []);
  }
  final skeleton = await _globalMessagesTimelineSkeleton(ref);
  final matchingIds = await _globalMessageIdsMatchingText(
    ref,
    query: normalizedQuery,
  );
  return skeleton.filteredByMessageIds(matchingIds);
}

Future<ConversationMessage?> _globalMessageById(
  Ref ref, {
  required int messageId,
}) async {
  final reader = await ref.watch(messageGraphReaderProvider.future);
  return reader.readGlobalMessageById(messageId: messageId);
}

Future<List<int>> _globalMessageIdsMatchingText(
  Ref ref, {
  required String query,
}) async {
  final reader = await ref.watch(messageGraphReaderProvider.future);
  return reader.readGlobalMessageIdsMatchingText(query: query);
}

Future<MessageEvidenceTimelineSkeleton> _handleMessagesTimelineSkeleton(
  Ref ref, {
  required int handleId,
}) async {
  final reader = await ref.watch(messageGraphReaderProvider.future);
  final entries = await reader.readHandleMessageTimeline(handleId: handleId);
  return MessageEvidenceTimelineSkeleton(
    entries: [
      for (final entry in entries)
        MessageEvidenceSkeletonEntry(
          messageId: entry.messageId,
          dateUtc: entry.dateUtc,
          monthKey: entry.monthKey,
        ),
    ],
  );
}

Future<ConversationMessage?> _handleMessageById(
  Ref ref, {
  required int handleId,
  required int messageId,
}) async {
  final reader = await ref.watch(messageGraphReaderProvider.future);
  return reader.readHandleMessageById(handleId: handleId, messageId: messageId);
}

Future<MessageEvidenceTimelineSkeleton> _searchResultContextSkeleton(
  Ref ref, {
  required int messageId,
  required int chatId,
  required int beforeCount,
  required int afterCount,
}) async {
  final reader = await ref.watch(messageGraphReaderProvider.future);
  final entries = await reader.readMessageContextTimeline(
    messageId: messageId,
    chatId: chatId,
    beforeCount: beforeCount,
    afterCount: afterCount,
  );
  return MessageEvidenceTimelineSkeleton(
    entries: [
      for (final entry in entries)
        MessageEvidenceSkeletonEntry(
          messageId: entry.messageId,
          dateUtc: entry.dateUtc,
          monthKey: entry.monthKey,
        ),
    ],
    initialAnchorMessageId: _liveChatGraphId(messageId),
  );
}

Future<MessageEvidenceTimelineSkeleton> _contactAllMessagesTimelineSkeleton(
  Ref ref, {
  required int contactId,
}) async {
  final entries = await ref.watch(
    contactPageGraphMessageTimelineProvider(contactId: contactId).future,
  );
  return MessageEvidenceTimelineSkeleton(
    entries: [
      for (final entry in entries)
        MessageEvidenceSkeletonEntry(
          messageId: entry.messageId,
          dateUtc: entry.dateUtc,
          monthKey: entry.monthKey,
        ),
    ],
  );
}

int _liveChatGraphId(int value) {
  if (value > SourceScopedRowKey.maxSourceRowId) {
    return value;
  }
  return SourceScopedRowKey.pack(
    sourceId: liveChatDbSourceId,
    sourceRowId: value,
  );
}

Future<MessageEvidenceTimelineSkeleton> _contactHandleMessagesTimelineSkeleton(
  Ref ref, {
  required int contactId,
  required int handleId,
}) async {
  final entries = await ref.watch(
    contactPageGraphHandleMessageTimelineProvider(
      contactId: contactId,
      handleId: handleId,
    ).future,
  );
  return MessageEvidenceTimelineSkeleton(
    entries: [
      for (final entry in entries)
        MessageEvidenceSkeletonEntry(
          messageId: entry.messageId,
          dateUtc: entry.dateUtc,
          monthKey: entry.monthKey,
        ),
    ],
  );
}

Future<MessageEvidenceTimelineSkeleton> _contactMessageSearchTimelineSkeleton(
  Ref ref, {
  required int contactId,
  required String query,
  required int? handleId,
}) async {
  final normalizedQuery = query.trim();
  if (normalizedQuery.isEmpty) {
    return const MessageEvidenceTimelineSkeleton(entries: []);
  }
  final baseSkeleton = handleId == null
      ? await _contactAllMessagesTimelineSkeleton(ref, contactId: contactId)
      : await _contactHandleMessagesTimelineSkeleton(
          ref,
          contactId: contactId,
          handleId: handleId,
        );
  final matchingIds = await _contactMessageIdsMatchingText(
    ref,
    contactId: contactId,
    query: normalizedQuery,
    handleId: handleId,
  );
  return baseSkeleton.filteredByMessageIds(matchingIds);
}

Future<List<int>> _contactMessageIdsMatchingText(
  Ref ref, {
  required int contactId,
  required String query,
  int? handleId,
}) {
  return ref.watch(
    contactPageGraphMessageIdsMatchingTextProvider(
      contactId: contactId,
      query: query,
      handleId: handleId,
    ).future,
  );
}

Future<MessageEvidenceTimelineSkeleton> _recoveredMessagesTimelineSkeleton(
  Ref ref, {
  required int? contactId,
  required bool onlyNoHandleFromMe,
}) async {
  final messages = await _recoveredMessagesForScope(
    ref,
    contactId: contactId,
    onlyNoHandleFromMe: onlyNoHandleFromMe,
  );
  return MessageEvidenceTimelineSkeleton(
    entries: [
      for (final message in messages)
        MessageEvidenceSkeletonEntry(
          messageId: message.id,
          dateUtc: _dateUtcString(message.sentAt),
          monthKey: _monthKey(message.sentAt),
        ),
    ],
  );
}

Future<ConversationMessage?> _recoveredMessageById(
  Ref ref, {
  required int? contactId,
  required bool onlyNoHandleFromMe,
  required int messageId,
}) async {
  final messages = await _recoveredMessagesForScope(
    ref,
    contactId: contactId,
    onlyNoHandleFromMe: onlyNoHandleFromMe,
  );
  final message = messages.where((item) {
    return item.id == messageId;
  }).firstOrNull;
  if (message == null) {
    return null;
  }
  return ConversationMessage(
    messageId: message.id,
    dateUtc: _dateUtcString(message.sentAt),
    isFromMe: message.isFromMe,
    text: message.text,
    associatedMessageId: null,
    attachmentCount: message.attachmentCount,
    senderHandleId: message.senderHandleId,
    senderDisplayHandle: _recoveredSenderLabel(message),
    semanticKind: message.isInferred
        ? '${message.semanticKind} (best guess)'
        : message.semanticKind,
    itemKind: message.itemType,
    isSparseArtifact: message.isSparseArtifact,
  );
}

Future<List<GraphAttachmentEvidence>> _graphMessageAttachments(
  Ref ref, {
  required int messageId,
}) async {
  final attachments = await ref.watch(
    messageAttachmentsProvider(messageId).future,
  );
  return graphAttachmentEvidenceFromMessageAttachments(attachments);
}

Future<List<GraphAttachmentEvidence>> _recoveredMessageAttachments(
  Ref ref, {
  required int? contactId,
  required bool onlyNoHandleFromMe,
  required int messageId,
}) async {
  final messages = await _recoveredMessagesForScope(
    ref,
    contactId: contactId,
    onlyNoHandleFromMe: onlyNoHandleFromMe,
  );
  final message = messages.where((item) {
    return item.id == messageId;
  }).firstOrNull;
  if (message == null) {
    return const <GraphAttachmentEvidence>[];
  }
  return [
    for (final attachment in message.attachments)
      graphAttachmentEvidenceFromRecoveredAttachment(attachment),
  ];
}

Future<List<int>> _recoveredMessageIdsMatchingText(
  Ref ref, {
  required int? contactId,
  required bool onlyNoHandleFromMe,
  required String query,
}) async {
  final terms = query
      .trim()
      .toLowerCase()
      .split(RegExp(r'\s+'))
      .where((term) {
        return term.isNotEmpty;
      })
      .toList(growable: false);
  if (terms.isEmpty) {
    return const <int>[];
  }

  final messages = await _recoveredMessagesForScope(
    ref,
    contactId: contactId,
    onlyNoHandleFromMe: onlyNoHandleFromMe,
  );

  return [
    for (final message in messages)
      if (_recoveredMessageMatchesTerms(message: message, terms: terms))
        message.id,
  ];
}

bool _recoveredMessageMatchesTerms({
  required RecoveredUnlinkedMessageItem message,
  required List<String> terms,
}) {
  final attachmentText = message.attachments
      .map((attachment) {
        return attachment.transferName?.trim();
      })
      .whereType<String>()
      .where((name) {
        return name.isNotEmpty;
      })
      .join(' ');
  final haystack = [
    message.senderLabel,
    message.contactName,
    message.service,
    message.itemType,
    message.semanticKind,
    message.text,
    attachmentText,
  ].whereType<String>().join(' ').toLowerCase();

  return terms.every(haystack.contains);
}

Future<List<RecoveredUnlinkedMessageItem>> _recoveredMessagesForScope(
  Ref ref, {
  required int? contactId,
  required bool onlyNoHandleFromMe,
}) async {
  final asyncMessages = ref.watch(
    recoveredUnlinkedMessagesProvider(contactId: contactId),
  );
  final messages =
      asyncMessages.valueOrNull ??
      await ref.watch(
        recoveredUnlinkedMessagesProvider(contactId: contactId).future,
      ) ??
      const <RecoveredUnlinkedMessageItem>[];

  return filterRecoveredTimelineMessages(
    messages: messages,
    onlyNoHandleFromMe: onlyNoHandleFromMe,
  );
}

String _recoveredSenderLabel(RecoveredUnlinkedMessageItem message) {
  if (message.isFromMe) {
    return 'You';
  }
  final contactName = message.contactName?.trim();
  if (contactName != null && contactName.isNotEmpty) {
    return contactName;
  }
  final senderLabel = message.senderLabel.trim();
  if (senderLabel.isNotEmpty) {
    return senderLabel;
  }
  return 'Unknown sender';
}

String? _dateUtcString(DateTime? value) {
  if (value == null) {
    return null;
  }
  return value.toUtc().toIso8601String();
}

String? _monthKey(DateTime? value) {
  if (value == null) {
    return null;
  }
  return '${value.year.toString().padLeft(4, '0')}-'
      '${value.month.toString().padLeft(2, '0')}';
}
