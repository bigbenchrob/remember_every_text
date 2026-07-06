import 'dart:async';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/util/date_label_formatter.dart';
import '../../../../essentials/conversation_graph/application/conversations/conversation.dart';
import '../../../../essentials/conversation_graph/feature_level_providers.dart'
    show
        contactPageGraphHandleMessageByIdProvider,
        contactPageGraphHandleMessagesProvider,
        contactPageGraphHandleMessageTimelineProvider,
        contactPageGraphMessageByIdProvider,
        contactPageGraphMessageIdsMatchingTextProvider,
        contactPageGraphMessagesProvider,
        contactPageGraphMessageTimelineProvider,
        conversationReaderProvider,
        messageAttachmentsProvider,
        messageGraphReaderProvider;
import '../../../../essentials/db/feature_level_providers/message_data_version_provider.dart'
    show messageDataVersionProvider;
import '../../../../essentials/search/application/graph_message_search.dart';
import '../../../../essentials/search/application/search_service.dart';
import '../../../../essentials/search/feature_level_providers.dart'
    show searchServiceProvider;
import '../../../attachments/feature_level_providers.dart'
    show attachmentFileAccessProvider;
import '../../../contacts/feature_level_providers.dart'
    show DisplayIdentityResolver, displayIdentityResolverProvider;
import '../../domain/message_evidence/message_evidence_row_data.dart';
import '../../domain/message_evidence/message_evidence_scope.dart';
import '../../domain/message_evidence/message_evidence_search_mode.dart';
import '../../domain/message_evidence/message_evidence_skeleton.dart';
import '../../domain/message_evidence/recovered_message_evidence.dart';
import 'message_attachment_evidence.dart';
import 'message_evidence_identity.dart';
import 'recovered_message_evidence_provider.dart';

part 'message_evidence_spine_provider.g.dart';

@riverpod
Future<MessageEvidenceTimelineSkeleton> messageEvidenceTimelineSkeleton(
  Ref ref, {
  required MessageEvidenceScope scope,
}) async {
  ref.watch(messageDataVersionProvider);

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
    MessageSearchEvidenceScope(:final query, :final mode) =>
      _globalMessageSearchTimelineSkeleton(ref, query: query, mode: mode),
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
Future<MessageEvidenceRowData?> messageEvidenceRow(
  Ref ref, {
  required MessageEvidenceScope scope,
  required int messageId,
}) async {
  _keepHydratedEvidenceAliveBriefly(ref);

  final message = await switch (scope) {
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
  if (message == null) {
    return null;
  }
  if (scope is RecoveredMessagesEvidenceScope) {
    return _messageEvidenceRowDataFromConversationMessage(message);
  }
  return _resolveGraphMessageSender(ref, message);
}

Future<MessageEvidenceRowData> _resolveGraphMessageSender(
  Ref ref,
  ConversationMessage message,
) async {
  final resolver = await ref.watch(displayIdentityResolverProvider.future);
  return _messageEvidenceRowDataFromGraphMessage(message, resolver);
}

MessageEvidenceRowData _messageEvidenceRowDataFromGraphMessage(
  ConversationMessage message,
  DisplayIdentityResolver resolver,
) {
  final rawHandleLabel =
      message.senderRawHandleLabel ?? message.senderDisplayHandle;
  final senderIdentity = resolver.resolveSender(
    isFromMe: message.isFromMe,
    senderCanonicalHandleId: message.senderCanonicalHandleId,
    senderHandleId: message.senderHandleId,
    rawHandleLabel: rawHandleLabel,
  );

  return MessageEvidenceRowData(
    messageId: message.messageId,
    dateUtc: message.dateUtc,
    isFromMe: message.isFromMe,
    text: message.text,
    associatedMessageId: message.associatedMessageId,
    attachmentCount: message.attachmentCount,
    sourceConversationId: message.conversationId,
    senderHandleId: message.senderHandleId,
    senderCanonicalHandleId: message.senderCanonicalHandleId,
    senderDisplayHandle: senderIdentity.primaryLabel,
    senderRawHandleLabel: senderIdentity.rawHandleLabel,
    semanticKind: message.semanticKind,
    itemKind: message.itemKind,
    isSystemMessage: message.isSystemMessage,
    isSparseArtifact: message.isSparseArtifact,
    hasAttributedBodySource: message.hasAttributedBodySource,
    hasMessageSummaryInfo: message.hasMessageSummaryInfo,
    hasPayloadDataSource: message.hasPayloadDataSource,
    errorCode: message.errorCode,
  );
}

MessageEvidenceRowData _messageEvidenceRowDataFromConversationMessage(
  ConversationMessage message,
) {
  return MessageEvidenceRowData(
    messageId: message.messageId,
    dateUtc: message.dateUtc,
    isFromMe: message.isFromMe,
    text: message.text,
    associatedMessageId: message.associatedMessageId,
    attachmentCount: message.attachmentCount,
    sourceConversationId: message.conversationId,
    senderHandleId: message.senderHandleId,
    senderCanonicalHandleId: message.senderCanonicalHandleId,
    senderDisplayHandle: message.senderDisplayHandle,
    senderRawHandleLabel: message.senderRawHandleLabel,
    semanticKind: message.semanticKind,
    itemKind: message.itemKind,
    isSystemMessage: message.isSystemMessage,
    isSparseArtifact: message.isSparseArtifact,
    hasAttributedBodySource: message.hasAttributedBodySource,
    hasMessageSummaryInfo: message.hasMessageSummaryInfo,
    hasPayloadDataSource: message.hasPayloadDataSource,
    errorCode: message.errorCode,
  );
}

@riverpod
Future<List<MessageAttachmentEvidence>> messageEvidenceAttachments(
  Ref ref, {
  required MessageEvidenceScope scope,
  required int messageId,
}) async {
  _keepHydratedEvidenceAliveBriefly(ref);

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
    SearchResultContextEvidenceScope() => _messageAttachments(
      ref,
      messageId: messageId,
    ),
  };
}

@riverpod
Future<Map<int, MessageEvidenceRowData>> messageEvidenceInitialRows(
  Ref ref, {
  required MessageEvidenceScope scope,
  DateTime? monthAnchor,
  int hydrationLimit = 80,
}) async {
  ref.watch(messageDataVersionProvider);

  final messages = await switch (scope) {
    ContactAllMessagesEvidenceScope(:final contactId) => ref.watch(
      contactPageGraphMessagesProvider(
        contactId: contactId,
        limit: hydrationLimit,
        monthAnchor: monthAnchor,
      ).future,
    ),
    ContactHandleMessagesEvidenceScope(:final contactId, :final handleId) =>
      ref.watch(
        contactPageGraphHandleMessagesProvider(
          contactId: contactId,
          handleId: handleId,
          limit: hydrationLimit,
          monthAnchor: monthAnchor,
        ).future,
      ),
    _ => Future.value(const <ConversationMessage>[]),
  };

  final resolver = await ref.watch(displayIdentityResolverProvider.future);
  final rows = [
    for (final message in messages)
      _messageEvidenceRowDataFromGraphMessage(message, resolver),
  ];
  return {for (final row in rows) row.messageId: row};
}

void _keepHydratedEvidenceAliveBriefly(Ref ref) {
  final link = ref.keepAlive();
  Timer? timer;

  ref.onCancel(() {
    timer = Timer(const Duration(minutes: 2), link.close);
  });
  ref.onResume(() {
    timer?.cancel();
    timer = null;
  });
  ref.onDispose(() {
    timer?.cancel();
  });
}

@riverpod
Future<List<int>> messageEvidenceTextMatchIds(
  Ref ref, {
  required MessageEvidenceScope scope,
  required String query,
  MessageEvidenceSearchMode mode = MessageEvidenceSearchMode.allTerms,
}) async {
  ref.watch(messageDataVersionProvider);

  final normalizedQuery = query.trim();
  if (normalizedQuery.isEmpty) {
    return const <int>[];
  }
  final matchAnyTerm = mode == MessageEvidenceSearchMode.anyTerm;

  return switch (scope) {
    ConversationEvidenceScope(:final conversationId) =>
      _conversationMessageIdsMatchingText(
        ref,
        conversationId: conversationId,
        query: normalizedQuery,
        matchAnyTerm: matchAnyTerm,
      ),
    GlobalMessagesEvidenceScope() => _globalMessageIdsMatchingText(
      ref,
      query: normalizedQuery,
      matchAnyTerm: matchAnyTerm,
    ),
    MessageSearchEvidenceScope() => _globalMessageIdsMatchingText(
      ref,
      query: normalizedQuery,
      matchAnyTerm: matchAnyTerm,
    ),
    ContactAllMessagesEvidenceScope(:final contactId) =>
      _contactMessageIdsMatchingText(
        ref,
        contactId: contactId,
        query: normalizedQuery,
        matchAnyTerm: matchAnyTerm,
      ),
    ContactHandleMessagesEvidenceScope(:final contactId, :final handleId) =>
      _contactMessageIdsMatchingText(
        ref,
        contactId: contactId,
        query: normalizedQuery,
        handleId: handleId,
        matchAnyTerm: matchAnyTerm,
      ),
    ContactMessageSearchEvidenceScope(:final contactId, :final handleId) =>
      _contactMessageIdsMatchingText(
        ref,
        contactId: contactId,
        query: normalizedQuery,
        handleId: handleId,
        matchAnyTerm: matchAnyTerm,
      ),
    HandleMessagesEvidenceScope(:final handleId) =>
      _handleMessageIdsMatchingText(
        ref,
        handleId: handleId,
        query: normalizedQuery,
        matchAnyTerm: matchAnyTerm,
      ),
    SearchResultContextEvidenceScope(
      :final messageId,
      :final chatId,
      :final beforeCount,
      :final afterCount,
    ) =>
      _searchResultContextMessageIdsMatchingText(
        ref,
        messageId: messageId,
        chatId: chatId,
        beforeCount: beforeCount,
        afterCount: afterCount,
        query: normalizedQuery,
        matchAnyTerm: matchAnyTerm,
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
        matchAnyTerm: matchAnyTerm,
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
  required bool matchAnyTerm,
}) async {
  return _graphSearchMessageIds(
    ref,
    scope: GraphMessageSearchScope.conversation(conversationId),
    query: query,
    matchAnyTerm: matchAnyTerm,
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
  required MessageEvidenceSearchMode mode,
}) async {
  final normalizedQuery = query.trim();
  if (normalizedQuery.isEmpty) {
    return const MessageEvidenceTimelineSkeleton(entries: []);
  }
  final skeleton = await _globalMessagesTimelineSkeleton(ref);
  final matchingIds = await _globalMessageIdsMatchingText(
    ref,
    query: normalizedQuery,
    matchAnyTerm: mode == MessageEvidenceSearchMode.anyTerm,
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
  required bool matchAnyTerm,
}) async {
  return _graphSearchMessageIds(
    ref,
    scope: const GraphMessageSearchScope.global(),
    query: query,
    matchAnyTerm: matchAnyTerm,
  );
}

Future<List<int>> _handleMessageIdsMatchingText(
  Ref ref, {
  required int handleId,
  required String query,
  required bool matchAnyTerm,
}) async {
  return _graphSearchMessageIds(
    ref,
    scope: GraphMessageSearchScope.handle(handleId),
    query: query,
    matchAnyTerm: matchAnyTerm,
  );
}

Future<List<int>> _graphSearchMessageIds(
  Ref ref, {
  required GraphMessageSearchScope scope,
  required String query,
  required bool matchAnyTerm,
}) async {
  final searchService = ref.watch(searchServiceProvider);
  return searchService.searchGraphMessageIds(
    scope: scope,
    query: query,
    mode: matchAnyTerm ? SearchMode.anyTerm : SearchMode.allTerms,
  );
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
    initialAnchorMessageId: canonicalMessageEvidenceId(messageId),
  );
}

Future<List<int>> _searchResultContextMessageIdsMatchingText(
  Ref ref, {
  required int messageId,
  required int chatId,
  required int beforeCount,
  required int afterCount,
  required String query,
  required bool matchAnyTerm,
}) async {
  final skeleton = await _searchResultContextSkeleton(
    ref,
    messageId: messageId,
    chatId: chatId,
    beforeCount: beforeCount,
    afterCount: afterCount,
  );
  if (skeleton.isEmpty) {
    return const <int>[];
  }

  final matchingIds = await _globalMessageIdsMatchingText(
    ref,
    query: query,
    matchAnyTerm: matchAnyTerm,
  );
  return skeleton
      .filteredByMessageIds(matchingIds)
      .entries
      .map((entry) {
        return entry.messageId;
      })
      .toList(growable: false);
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
    matchAnyTerm: false,
    handleId: handleId,
  );
  return baseSkeleton.filteredByMessageIds(matchingIds);
}

Future<List<int>> _contactMessageIdsMatchingText(
  Ref ref, {
  required int contactId,
  required String query,
  required bool matchAnyTerm,
  int? handleId,
}) {
  return ref.watch(
    contactPageGraphMessageIdsMatchingTextProvider(
      contactId: contactId,
      query: query,
      matchAnyTerm: matchAnyTerm,
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

Future<List<MessageAttachmentEvidence>> _messageAttachments(
  Ref ref, {
  required int messageId,
}) async {
  final attachments = await ref.watch(
    messageAttachmentsProvider(messageId).future,
  );
  final fileAccess = ref.watch(attachmentFileAccessProvider);
  return messageAttachmentEvidenceFromMessageAttachments(
    attachments,
    fileAccess,
  );
}

Future<List<MessageAttachmentEvidence>> _recoveredMessageAttachments(
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
    return const <MessageAttachmentEvidence>[];
  }
  final fileAccess = ref.watch(attachmentFileAccessProvider);
  return [
    for (final attachment in message.attachments)
      messageAttachmentEvidenceFromRecoveredAttachment(attachment, fileAccess),
  ];
}

Future<List<int>> _recoveredMessageIdsMatchingText(
  Ref ref, {
  required int? contactId,
  required bool onlyNoHandleFromMe,
  required String query,
  required bool matchAnyTerm,
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
      if (_recoveredMessageMatchesTerms(
        message: message,
        terms: terms,
        matchAnyTerm: matchAnyTerm,
      ))
        message.id,
  ];
}

bool _recoveredMessageMatchesTerms({
  required RecoveredUnlinkedMessageItem message,
  required List<String> terms,
  required bool matchAnyTerm,
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

  return matchAnyTerm
      ? terms.any(haystack.contains)
      : terms.every(haystack.contains);
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
  return DateLabelFormatter.monthKeyOrNull(value);
}
