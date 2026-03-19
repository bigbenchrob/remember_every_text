part of '../../cassette_spec.dart';

CassetteSpec contactsChildMessagesHeatMap(int contactId) {
  return CassetteSpec.messages(
    MessagesCassetteSpec.heatMap(contactId: contactId),
  );
}
