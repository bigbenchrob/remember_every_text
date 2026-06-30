import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../presentation/widgets/grouped_contact_selector.dart';
import '../payloads/contact_chooser_cassette_payload.dart';
import '../resolver_tools/contact_picker_actions_provider.dart';

/// Widget builder for the grouped contact picker display.
///
/// This widget builder assembles the full grouped/alphabetical contact picker
/// for use when the contact count is at or above the grouping threshold.
///
/// ## Contract (from 00-cross-surface-spec-system.md)
///
/// Widget builders:
/// - Accept fully-decided inputs (not specs)
/// - May use `ref.watch()` for reactive updates
/// - Dispatch semantic actions on user interaction; do not construct panel specs
/// - Never make branching decisions about which UI to show
class ContactGroupedPickerWidget extends HookConsumerWidget {
  const ContactGroupedPickerWidget({super.key, required this.payload});

  final ContactChooserCassettePayload payload;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pickerFilterMode = payload.pickerFilterMode!;
    final filteredSections = payload.filteredSections!;

    return FullContactPicker(
      selectedParticipantId: payload.chosenContactId,
      onContactSelected: (contactId) => _handleContactSelection(ref, contactId),
      onContactHovered: (contactId) {
        _prewarmContact(ref, contactId);
      },
      currentMode: pickerFilterMode,
      unifiedSections: filteredSections,
    );
  }

  Future<void> _handleContactSelection(WidgetRef ref, int contactId) async {
    await ref
        .read(contactPickerActionsProvider.notifier)
        .chooseContact(
          contactId: contactId,
          cassetteIndex: payload.cassetteIndex,
        );
  }

  void _prewarmContact(WidgetRef ref, int contactId) {
    ref
        .read(contactPickerActionsProvider.notifier)
        .prewarmContact(contactId: contactId);
  }
}
