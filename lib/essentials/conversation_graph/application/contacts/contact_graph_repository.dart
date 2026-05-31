import '../conversations/conversation.dart';
import 'contact_graph.dart';

abstract interface class ContactGraphRepository {
  Future<ContactGraphSnapshot> readContactGraph({required int contactId});

  Future<ContactGraphSnapshot> readContactPageGraph({
    required int contactId,
    required int graphContactId,
  });

  Future<List<ConversationMessage>> readContactMessages({
    required int contactId,
    int limit = 500,
    DateTime? monthAnchor,
  });

  Future<List<ConversationMessage>> readContactPageMessages({
    required int contactId,
    required int graphContactId,
    int limit = 500,
    DateTime? monthAnchor,
  });

  Future<List<ContactGraphMessageTimelineEntry>>
  readContactPageMessageTimeline({
    required int contactId,
    required int graphContactId,
  });

  Future<ConversationMessage?> readContactPageMessageById({
    required int contactId,
    required int graphContactId,
    required int messageId,
  });

  Future<List<ContactGraphMessageTimelineEntry>>
  readContactPageHandleMessageTimeline({
    required int contactId,
    required int graphContactId,
    required int handleId,
  });

  Future<ConversationMessage?> readContactPageHandleMessageById({
    required int contactId,
    required int graphContactId,
    required int handleId,
    required int messageId,
  });

  Future<List<int>> readContactPageMessageIdsMatchingText({
    required int contactId,
    required int graphContactId,
    required String query,
    bool matchAnyTerm = false,
    int? handleId,
  });
}
