part of '../cassette_spec.dart';

CassetteSpec? resolveMessagesInfoChild(MessagesInfoCassetteSpec spec) {
  return spec.when(
    infoCard: (key) {
      switch (key) {
        case MessagesInfoKey.searchAllMessages:
          return const CassetteSpec.messages(
            MessagesCassetteSpec.heatMap(contactId: null),
          );
        case MessagesInfoKey.recoveredDeletedMessages:
        case MessagesInfoKey.recoveredNoHandleMessages:
          return null;
      }
    },
  );
}

extension MessagesInfoCassetteSpecX on MessagesInfoCassetteSpec {
  /// Messages info cassettes currently have no children.
  CassetteSpec? childSpec() {
    return resolveMessagesInfoChild(this);
  }
}
