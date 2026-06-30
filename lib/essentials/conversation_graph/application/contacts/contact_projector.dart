import 'contact_projection_repository.dart';

class ContactProjector {
  const ContactProjector({required this.repository});

  final ContactProjectionRepository repository;

  Future<ContactProjectionResult> projectContacts() =>
      repository.projectContacts();
}
