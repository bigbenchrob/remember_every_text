part of '../cassette_spec.dart';

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
          // Contact chosen — this info card provides contextual guidance and
          // the change-contact action below the hero summary.
          // Chain: heroSummary → infoCard(chosenContact) → messageScopeToggle
          //     → handleFilter → heatMap
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
