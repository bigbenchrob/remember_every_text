import 'contact_projection_repository.dart';

export 'contact_projection_repository.dart' show contactHandleKeys;

class ContactProjector {
  const ContactProjector({required this.repository});

  final ContactProjectionRepository repository;

  Future<ContactProjectionResult> projectContacts() =>
      repository.projectContacts();
}
