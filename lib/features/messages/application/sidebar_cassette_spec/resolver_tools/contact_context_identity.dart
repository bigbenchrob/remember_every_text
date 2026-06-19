import '../../../../../essentials/conversation_graph/application/identity/contact_page_graph_identity.dart';

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
