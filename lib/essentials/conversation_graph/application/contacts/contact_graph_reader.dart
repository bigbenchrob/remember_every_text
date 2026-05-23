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
}
