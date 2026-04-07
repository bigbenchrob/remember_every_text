part of '../cassette_spec.dart';

CassetteSpec? resolveContactsChild(ContactsCassetteSpec spec) {
  return spec.when(
    contactChooser: (_) {
      // Terminal node — the chooser sits beneath the picker info card.
      return null;
    },
    contactSelectionControl: (chosenContactId) {
      // Selection control sits below the contextual info card and above
      // the message-scope toggle.
      // Chain: heroSummary → infoCard(chosenContact)
      //     → selectionControl → messageScopeToggle
      //     → handleFilter → heatMap
      return CassetteSpec.contacts(
        ContactsCassetteSpec.messageScopeToggle(contactId: chosenContactId),
      );
    },
    contactHeroSummary: (chosenContactId) {
      // Hero summary cascades to the contextual info card.
      // Chain: heroSummary → infoCard(chosenContact)
      //     → contactSelectionControl → messageScopeToggle
      //     → handleFilter → heatMap
      return CassetteSpec.contactsInfo(
        ContactsInfoCassetteSpec.infoCard(
          key: ContactsInfoKey.chosenContact,
          chosenContactId: chosenContactId,
        ),
      );
    },
    messageScopeToggle: (contactId) {
      return CassetteSpec.contacts(
        ContactsCassetteSpec.handleFilter(contactId: contactId),
      );
    },
    handleFilter: (contactId, _) {
      // Handle filter cascades to messages heat map
      return contactsChildMessagesHeatMap(contactId);
    },
  );
}

extension ContactsCassetteSpecX on ContactsCassetteSpec {
  /// Contacts cascade into a messages heatmap when a contact is selected.
  CassetteSpec? childSpec() {
    return resolveContactsChild(this);
  }
}
