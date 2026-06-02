import '../conversations/conversation.dart';
import 'contact_graph.dart';
import 'contact_graph_repository.dart';

class ContactGraphReader {
  const ContactGraphReader({required this.repository});

  final ContactGraphRepository repository;

  Future<ContactGraphSnapshot> readContactGraph({required int contactId}) {
    return repository.readContactGraph(contactId: contactId);
  }

  Future<ContactGraphSnapshot> readContactPageGraph({
    required int contactId,
    required int graphContactId,
  }) {
    return repository.readContactPageGraph(
      contactId: contactId,
      graphContactId: graphContactId,
    );
  }

  Future<List<ConversationMessage>> readContactMessages({
    required int contactId,
    int limit = 500,
    DateTime? monthAnchor,
  }) {
    return repository.readContactMessages(
      contactId: contactId,
      limit: limit,
      monthAnchor: monthAnchor,
    );
  }

  Future<List<ConversationMessage>> readContactPageMessages({
    required int contactId,
    required int graphContactId,
    int limit = 500,
    DateTime? monthAnchor,
  }) {
    return repository.readContactPageMessages(
      contactId: contactId,
      graphContactId: graphContactId,
      limit: limit,
      monthAnchor: monthAnchor,
    );
  }

  Future<List<ContactGraphMessageTimelineEntry>>
  readContactPageMessageTimeline({
    required int contactId,
    required int graphContactId,
  }) {
    return repository.readContactPageMessageTimeline(
      contactId: contactId,
      graphContactId: graphContactId,
    );
  }

  Future<ConversationMessage?> readContactPageMessageById({
    required int contactId,
    required int graphContactId,
    required int messageId,
  }) {
    return repository.readContactPageMessageById(
      contactId: contactId,
      graphContactId: graphContactId,
      messageId: messageId,
    );
  }

  Future<List<ContactGraphMessageTimelineEntry>>
  readContactPageHandleMessageTimeline({
    required int contactId,
    required int graphContactId,
    required int handleId,
  }) {
    return repository.readContactPageHandleMessageTimeline(
      contactId: contactId,
      graphContactId: graphContactId,
      handleId: handleId,
    );
  }

  Future<ConversationMessage?> readContactPageHandleMessageById({
    required int contactId,
    required int graphContactId,
    required int handleId,
    required int messageId,
  }) {
    return repository.readContactPageHandleMessageById(
      contactId: contactId,
      graphContactId: graphContactId,
      handleId: handleId,
      messageId: messageId,
    );
  }

  Future<List<ConversationMessage>> readContactPageHandleMessages({
    required int contactId,
    required int graphContactId,
    required int handleId,
    int limit = 500,
    DateTime? monthAnchor,
  }) {
    return repository.readContactPageHandleMessages(
      contactId: contactId,
      graphContactId: graphContactId,
      handleId: handleId,
      limit: limit,
      monthAnchor: monthAnchor,
    );
  }

  Future<List<int>> readContactPageMessageIdsMatchingText({
    required int contactId,
    required int graphContactId,
    required String query,
    bool matchAnyTerm = false,
    int? handleId,
  }) {
    return repository.readContactPageMessageIdsMatchingText(
      contactId: contactId,
      graphContactId: graphContactId,
      query: query,
      matchAnyTerm: matchAnyTerm,
      handleId: handleId,
    );
  }
}
