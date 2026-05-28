import 'package:freezed_annotation/freezed_annotation.dart';

enum MessageEvidenceScopeKind { timeline, contextWindow }

@immutable
sealed class MessageEvidenceScope {
  const MessageEvidenceScope({required this.kind});

  final MessageEvidenceScopeKind kind;

  String get stableKey;

  bool get isTimelineLike => kind == MessageEvidenceScopeKind.timeline;
}

@immutable
final class ContactAllMessagesEvidenceScope extends MessageEvidenceScope {
  const ContactAllMessagesEvidenceScope({required this.contactId})
    : super(kind: MessageEvidenceScopeKind.timeline);

  final int contactId;

  @override
  String get stableKey => 'contact-all-messages:$contactId';

  @override
  bool operator ==(Object other) {
    return other is ContactAllMessagesEvidenceScope &&
        other.contactId == contactId;
  }

  @override
  int get hashCode => Object.hash(runtimeType, contactId);

  @override
  String toString() {
    return 'ContactAllMessagesEvidenceScope(contactId: $contactId)';
  }
}

@immutable
final class ContactHandleMessagesEvidenceScope extends MessageEvidenceScope {
  const ContactHandleMessagesEvidenceScope({
    required this.contactId,
    required this.handleId,
  }) : super(kind: MessageEvidenceScopeKind.timeline);

  final int contactId;
  final int handleId;

  @override
  String get stableKey => 'contact-handle-messages:$contactId:$handleId';

  @override
  bool operator ==(Object other) {
    return other is ContactHandleMessagesEvidenceScope &&
        other.contactId == contactId &&
        other.handleId == handleId;
  }

  @override
  int get hashCode => Object.hash(runtimeType, contactId, handleId);

  @override
  String toString() {
    return 'ContactHandleMessagesEvidenceScope('
        'contactId: $contactId, '
        'handleId: $handleId'
        ')';
  }
}

@immutable
final class ContactMessageSearchEvidenceScope extends MessageEvidenceScope {
  const ContactMessageSearchEvidenceScope({
    required this.contactId,
    required this.query,
    this.handleId,
  }) : super(kind: MessageEvidenceScopeKind.timeline);

  final int contactId;
  final String query;
  final int? handleId;

  @override
  String get stableKey =>
      'contact-message-search:$contactId:${handleId ?? 'all'}:'
      '${query.trim().toLowerCase()}';

  @override
  bool operator ==(Object other) {
    return other is ContactMessageSearchEvidenceScope &&
        other.contactId == contactId &&
        other.handleId == handleId &&
        other.query.trim().toLowerCase() == query.trim().toLowerCase();
  }

  @override
  int get hashCode {
    return Object.hash(
      runtimeType,
      contactId,
      handleId,
      query.trim().toLowerCase(),
    );
  }

  @override
  String toString() {
    return 'ContactMessageSearchEvidenceScope('
        'contactId: $contactId, '
        'handleId: $handleId, '
        'query: $query'
        ')';
  }
}

@immutable
final class GlobalMessagesEvidenceScope extends MessageEvidenceScope {
  const GlobalMessagesEvidenceScope()
    : super(kind: MessageEvidenceScopeKind.timeline);

  @override
  String get stableKey => 'global-messages';

  @override
  bool operator ==(Object other) {
    return other is GlobalMessagesEvidenceScope;
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'GlobalMessagesEvidenceScope()';
  }
}

@immutable
final class MessageSearchEvidenceScope extends MessageEvidenceScope {
  const MessageSearchEvidenceScope({required this.query})
    : super(kind: MessageEvidenceScopeKind.timeline);

  final String query;

  @override
  String get stableKey => 'message-search:${query.trim().toLowerCase()}';

  @override
  bool operator ==(Object other) {
    return other is MessageSearchEvidenceScope &&
        other.query.trim().toLowerCase() == query.trim().toLowerCase();
  }

  @override
  int get hashCode => Object.hash(runtimeType, query.trim().toLowerCase());

  @override
  String toString() {
    return 'MessageSearchEvidenceScope(query: $query)';
  }
}

@immutable
final class HandleMessagesEvidenceScope extends MessageEvidenceScope {
  const HandleMessagesEvidenceScope({required this.handleId})
    : super(kind: MessageEvidenceScopeKind.timeline);

  final int handleId;

  @override
  String get stableKey => 'handle-messages:$handleId';

  @override
  bool operator ==(Object other) {
    return other is HandleMessagesEvidenceScope && other.handleId == handleId;
  }

  @override
  int get hashCode => Object.hash(runtimeType, handleId);

  @override
  String toString() {
    return 'HandleMessagesEvidenceScope(handleId: $handleId)';
  }
}

@immutable
final class ConversationEvidenceScope extends MessageEvidenceScope {
  const ConversationEvidenceScope({required this.conversationId})
    : super(kind: MessageEvidenceScopeKind.timeline);

  final int conversationId;

  @override
  String get stableKey => 'conversation:$conversationId';

  @override
  bool operator ==(Object other) {
    return other is ConversationEvidenceScope &&
        other.conversationId == conversationId;
  }

  @override
  int get hashCode => Object.hash(runtimeType, conversationId);

  @override
  String toString() {
    return 'ConversationEvidenceScope(conversationId: $conversationId)';
  }
}

@immutable
final class SearchResultContextEvidenceScope extends MessageEvidenceScope {
  const SearchResultContextEvidenceScope({
    required this.messageId,
    required this.chatId,
    required this.beforeCount,
    required this.afterCount,
  }) : super(kind: MessageEvidenceScopeKind.contextWindow);

  final int messageId;
  final int chatId;
  final int beforeCount;
  final int afterCount;

  @override
  String get stableKey =>
      'search-context:$chatId:$messageId:$beforeCount:$afterCount';

  @override
  bool operator ==(Object other) {
    return other is SearchResultContextEvidenceScope &&
        other.messageId == messageId &&
        other.chatId == chatId &&
        other.beforeCount == beforeCount &&
        other.afterCount == afterCount;
  }

  @override
  int get hashCode {
    return Object.hash(runtimeType, messageId, chatId, beforeCount, afterCount);
  }

  @override
  String toString() {
    return 'SearchResultContextEvidenceScope('
        'messageId: $messageId, '
        'chatId: $chatId, '
        'beforeCount: $beforeCount, '
        'afterCount: $afterCount'
        ')';
  }
}

@immutable
final class RecoveredMessagesEvidenceScope extends MessageEvidenceScope {
  const RecoveredMessagesEvidenceScope({
    required this.contactId,
    required this.onlyNoHandleFromMe,
  }) : super(kind: MessageEvidenceScopeKind.timeline);

  final int? contactId;
  final bool onlyNoHandleFromMe;

  @override
  String get stableKey =>
      'recovered-messages:${contactId ?? 'global'}:$onlyNoHandleFromMe';

  @override
  bool operator ==(Object other) {
    return other is RecoveredMessagesEvidenceScope &&
        other.contactId == contactId &&
        other.onlyNoHandleFromMe == onlyNoHandleFromMe;
  }

  @override
  int get hashCode {
    return Object.hash(runtimeType, contactId, onlyNoHandleFromMe);
  }

  @override
  String toString() {
    return 'RecoveredMessagesEvidenceScope('
        'contactId: $contactId, '
        'onlyNoHandleFromMe: $onlyNoHandleFromMe'
        ')';
  }
}
