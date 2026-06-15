import '../../../../../essentials/conversation_graph/application/contacts/contact_graph_provider.dart';

bool isSameContactContext(int? selectedContactId, int cassetteContactId) {
  if (selectedContactId == null) {
    return false;
  }

  final selectedGraphContactId = graphContactIdForContactPage(
    selectedContactId,
  );
  final cassetteGraphContactId = graphContactIdForContactPage(
    cassetteContactId,
  );

  return selectedContactId == cassetteContactId ||
      selectedGraphContactId == cassetteContactId ||
      cassetteGraphContactId == selectedContactId ||
      selectedGraphContactId == cassetteGraphContactId;
}
