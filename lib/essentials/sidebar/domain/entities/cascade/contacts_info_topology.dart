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
          // Contact chosen — this info card provides contextual guidance.
          // The lightweight "change contact" control is a separate inert
          // cassette immediately below it.
          // Chain: heroSummary → infoCard(chosenContact)
          //     → contactSelectionControl → messageScopeToggle
          //     → handleFilter → heatMap
          return CassetteSpec.contacts(
            ContactsCassetteSpec.contactSelectionControl(
              chosenContactId: chosenContactId!,
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
