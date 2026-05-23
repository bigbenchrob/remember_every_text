import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../essentials/conversation_graph/application/contacts/contact_projector.dart';
import '../../../../essentials/db/feature_level_providers.dart';
import '../../../contacts/infrastructure/repositories/participant_merge_utils.dart';

part 'contact_handle_label_provider.g.dart';

class ContactHandleLabel {
  const ContactHandleLabel({required this.handle, required this.displayName});

  final String handle;
  final String displayName;
}

@riverpod
Future<Map<String, ContactHandleLabel>> contactHandleLabels(Ref ref) async {
  final graphDb = await ref.watch(
    driftConversationGraphDatabaseProvider.future,
  );
  final overlayDb = await ref.watch(overlayDatabaseProvider.future);
  final nameOverrides = await displayNameOverridesMap(overlayDb);
  final labels = <String, ContactHandleLabel>{};

  final graphContactRows = await graphDb.selectRows('''
    SELECT
      c.contact_id AS participant_id,
      c.display_name AS participant_display_name,
      h.id AS handle_value,
      cth.handle_value AS contact_handle_value
    FROM contacts c
    JOIN contact_to_handle cth ON cth.contact_id = c.contact_id
    JOIN handles h ON h.ss_id = cth.handle_ss_id
    ORDER BY c.display_name ASC, h.id ASC
    ''');

  for (final row in graphContactRows) {
    final participantId = row['participant_id'] as int?;
    final participantDisplayName = (row['participant_display_name'] as String?)
        ?.trim();
    final handleValue = (row['handle_value'] as String?)?.trim();
    final contactHandleValue = (row['contact_handle_value'] as String?)?.trim();
    if (participantId == null ||
        participantDisplayName == null ||
        participantDisplayName.isEmpty ||
        handleValue == null ||
        handleValue.isEmpty) {
      continue;
    }

    final displayName = nameOverrides[participantId] ?? participantDisplayName;
    final label = ContactHandleLabel(
      handle: handleValue,
      displayName: displayName,
    );
    _putLabel(labels, handleValue, label);
    if (contactHandleValue != null && contactHandleValue.isNotEmpty) {
      _putLabel(labels, contactHandleValue, label);
    }
  }

  return labels;
}

String contactHandleLabelKeyForTesting(String handle) => _handleKey(handle);

List<String> contactHandleLabelKeysForTesting(String handle) =>
    contactHandleKeys(handle);

String _handleKey(String handle) {
  return handle.trim().toLowerCase();
}

void _putLabel(
  Map<String, ContactHandleLabel> labels,
  String handle,
  ContactHandleLabel label,
) {
  for (final key in contactHandleKeys(handle)) {
    labels.putIfAbsent(key, () => label);
  }
}
