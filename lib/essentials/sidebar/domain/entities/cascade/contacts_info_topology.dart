part of '../cassette_spec.dart';

// TOPOLOGY RULE:
// Determine ONLY the immediate next child of this spec.
// May consult flow state, but must not plan or assemble a chain.
// See cassette_child_resolver.dart for full contract.

CassetteSpec? resolveContactsInfoChild(ContactsInfoCassetteSpec spec) {
  return spec.when(
    infoCard: (key, chosenContactId) {
      switch (key) {
        case ContactsInfoKey.pickerContentSources:
          // No contact chosen yet — show the contact picker.
          return const CassetteSpec.contacts(
            ContactsCassetteSpec.contactChooser(),
          );
        case ContactsInfoKey.chosenContact:
          // Seeded topology fallback for any explicitly seeded
          // selected-contact info cassette. The default selected-contact chain
          // now goes directly from heroSummary to messageScopeToggle.
          return CassetteSpec.contacts(
            ContactsCassetteSpec.messageScopeToggle(
              contactId: chosenContactId!,
            ),
          );
      }
    },
  );
}

extension ContactsInfoCassetteSpecX on ContactsInfoCassetteSpec {
  CassetteSpec? childSpec() {
    return resolveContactsInfoChild(this);
  }
}
