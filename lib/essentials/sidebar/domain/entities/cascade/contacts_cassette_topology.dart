part of '../cassette_spec.dart';

CassetteSpec? resolveContactsChild(ContactsCassetteSpec spec) {
  return spec.when(
    contactChooser: (_) {
      // Terminal node — the info card above handles the transition
      // to contactSelectionControl when a contact is chosen.
      return null;
    },
    contactSelectionControl: (chosenContactId) {
      // Selection control sits below info card, cascades to hero summary.
      // Chain: infoCard(chosenContact) → selectionControl → heroSummary → handleFilter → heatMap
      return CassetteSpec.contacts(
        ContactsCassetteSpec.contactHeroSummary(
          chosenContactId: chosenContactId,
        ),
      );
    },
    contactHeroSummary: (chosenContactId) {
      // Hero summary cascades to the contextual info card.
      // Chain: heroSummary → infoCard(chosenContact) → messageScopeToggle
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
