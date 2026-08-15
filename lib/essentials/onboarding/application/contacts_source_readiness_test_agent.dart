import '../../../features/address_book_folders/infrastructure/repositories/address_book_folder_repository.dart';
import '../../presence/domain/services/test_agent.dart';

/// Establishes Contacts-source readiness through the Address Book specialist.
final class ContactsSourceReadinessTestAgent implements TestAgent {
  const ContactsSourceReadinessTestAgent({
    required AddressBookFolderRepository repository,
  }) : _repository = repository;

  final AddressBookFolderRepository _repository;

  @override
  Future<bool> evaluate() async {
    final result = await _repository.getFinalFolderAggregate();
    return result.isRight();
  }
}
