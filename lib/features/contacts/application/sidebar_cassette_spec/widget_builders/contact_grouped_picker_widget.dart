import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../../essentials/navigation/domain/sidebar_mode.dart';
import '../../../../../essentials/sidebar/domain/sidebar_action_intent.dart';
import '../../../../../essentials/sidebar/feature_level_providers.dart';
import '../../../../messages/feature_level_providers.dart' as messages_feature;
import '../../../feature_level_providers.dart';
import '../../../presentation/widgets/grouped_contact_selector.dart';
import '../payloads/contact_chooser_cassette_payload.dart';

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
/// - Construct specs only on user interaction (output, not interpretation)
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
        _prewarmContactInvestigation(ref, contactId);
      },
      currentMode: pickerFilterMode,
      unifiedSections: filteredSections,
    );
  }

  Future<void> _handleContactSelection(WidgetRef ref, int contactId) async {
    _prewarmContactInvestigation(ref, contactId);
    ref
        .read(sidebarActionDispatcherProvider.notifier)
        .dispatch(
          intent: ContactChosen(contactId: contactId),
          context: SidebarActionDispatchContext(
            sidebarMode: SidebarMode.messages,
            cassetteIndex: payload.cassetteIndex,
          ),
        );
  }

  void _prewarmContactInvestigation(WidgetRef ref, int contactId) {
    unawaited(ref.read(contactProfileProvider(contactId: contactId).future));
    unawaited(
      ref.read(
        messages_feature
            .prewarmContactMessagesProvider(contactId: contactId)
            .future,
      ),
    );
  }
}
