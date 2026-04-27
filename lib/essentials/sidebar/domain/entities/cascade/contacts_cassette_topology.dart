part of '../cassette_spec.dart';

// TOPOLOGY RULE:
// Determine ONLY the immediate next child of this spec.
// May consult flow state, but must not plan or assemble a chain.
// See cassette_child_resolver.dart for full contract.

CassetteSpec? resolveContactsChild(
  ContactsCassetteSpec spec, {
  StableCassetteTopologyContext? context,
}) {
  return spec.when(
    contactChooser: (_) {
      // Terminal node — the chooser sits beneath the picker info card.
      return null;
    },
    contactSelectionControl: (chosenContactId) {
      // Selection control sits directly beneath the top-menu selector and
      // above the resolved hero card.
      // Chain: selectionControl → heroSummary → infoCard(chosenContact)
      //     → messageScopeToggle → handleFilter → heatMap
      return CassetteSpec.contacts(
        ContactsCassetteSpec.contactHeroSummary(
          chosenContactId: chosenContactId,
        ),
      );
    },
    contactHeroSummary: (chosenContactId) {
      // Hero summary cascades to the contextual info card.
      // Chain: selectionControl → heroSummary → infoCard(chosenContact)
      //     → handleFilter → heatMap
      return CassetteSpec.contactsInfo(
        ContactsInfoCassetteSpec.infoCard(
          key: ContactsInfoKey.chosenContact,
          chosenContactId: chosenContactId,
        ),
      );
    },
    messageScopeToggle: (contactId) {
      switch (context?.messageScope) {
        case StableCascadeMessageScope.recoveredDeleted:
          return const CassetteSpec.messagesInfo(
            MessagesInfoCassetteSpec.infoCard(
              key: MessagesInfoKey.recoveredDeletedMessages,
            ),
          );
        case StableCascadeMessageScope.regular:
        case null:
          return CassetteSpec.contacts(
            ContactsCassetteSpec.handleFilter(contactId: contactId),
          );
      }
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
