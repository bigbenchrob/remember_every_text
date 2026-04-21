part of '../cassette_spec.dart';

// TOPOLOGY RULE:
// Determine ONLY the immediate next child of this spec.
// May consult flow state, but must not plan or assemble a chain.
// See cassette_child_resolver.dart for full contract.

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
