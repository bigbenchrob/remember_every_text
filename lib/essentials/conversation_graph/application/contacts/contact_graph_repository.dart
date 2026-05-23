import 'contact_graph.dart';

abstract interface class ContactGraphRepository {
  Future<ContactGraphSnapshot> readContactGraph({required int contactId});

  Future<ContactGraphSnapshot> readContactPageGraph({
    required int contactId,
    required int graphContactId,
  });
}
