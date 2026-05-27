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
}
