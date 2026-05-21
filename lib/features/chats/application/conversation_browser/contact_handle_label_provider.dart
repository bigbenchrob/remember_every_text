import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

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
  final workingDb = await ref.watch(driftWorkingDatabaseProvider.future);
  final importDb = await ref.watch(sqfliteImportDatabaseProvider.future);
  final overlayDb = await ref.watch(overlayDatabaseProvider.future);
  final nameOverrides = await displayNameOverridesMap(overlayDb);

  final rows = await workingDb.customSelect('''
    SELECT
      h.raw_identifier AS raw_identifier,
      h.display_name AS handle_display_name,
      p.id AS participant_id,
      p.display_name AS participant_display_name
    FROM handles_canonical h
    JOIN handle_to_participant htp ON htp.handle_id = h.id
    JOIN participants p ON p.id = htp.participant_id
    ORDER BY p.display_name ASC, h.raw_identifier ASC
    ''').get();

  final labels = <String, ContactHandleLabel>{};
  for (final row in rows) {
    final rawIdentifier = row.read<String?>('raw_identifier')?.trim();
    final handleDisplayName = row.read<String?>('handle_display_name')?.trim();
    final participantId = row.read<int?>('participant_id');
    final participantDisplayName = row
        .read<String?>('participant_display_name')
        ?.trim();

    if (participantId == null ||
        rawIdentifier == null ||
        rawIdentifier.isEmpty ||
        participantDisplayName == null ||
        participantDisplayName.isEmpty) {
      continue;
    }

    final displayName = nameOverrides[participantId] ?? participantDisplayName;
    final label = ContactHandleLabel(
      handle: rawIdentifier,
      displayName: displayName,
    );

    _putLabel(labels, rawIdentifier, label);
    if (handleDisplayName != null && handleDisplayName.isNotEmpty) {
      _putLabel(labels, handleDisplayName, label);
    }
  }

  final contactChannelRows = await (await importDb.database).rawQuery('''
    SELECT
      c.Z_PK AS participant_id,
      c.display_name AS participant_display_name,
      cpe.value AS handle_value
    FROM contacts c
    JOIN contact_phone_email cpe ON cpe.ZOWNER = c.Z_PK
    WHERE cpe.value IS NOT NULL
      AND cpe.value != ''
    ORDER BY c.display_name ASC, cpe.value ASC
    ''');

  for (final row in contactChannelRows) {
    final participantId = row['participant_id'] as int?;
    final participantDisplayName = (row['participant_display_name'] as String?)
        ?.trim();
    final handleValue = (row['handle_value'] as String?)?.trim();
    if (participantId == null ||
        participantDisplayName == null ||
        participantDisplayName.isEmpty ||
        handleValue == null ||
        handleValue.isEmpty) {
      continue;
    }

    final displayName = nameOverrides[participantId] ?? participantDisplayName;
    _putLabel(
      labels,
      handleValue,
      ContactHandleLabel(handle: handleValue, displayName: displayName),
    );
  }

  return labels;
}

String contactHandleLabelKeyForTesting(String handle) => _handleKey(handle);

List<String> contactHandleLabelKeysForTesting(String handle) =>
    _handleKeys(handle);

String _handleKey(String handle) {
  return handle.trim().toLowerCase();
}

void _putLabel(
  Map<String, ContactHandleLabel> labels,
  String handle,
  ContactHandleLabel label,
) {
  for (final key in _handleKeys(handle)) {
    labels.putIfAbsent(key, () => label);
  }
}

List<String> _handleKeys(String handle) {
  final normalized = _handleKey(handle);
  if (normalized.isEmpty) {
    return const <String>[];
  }

  final keys = <String>{normalized};
  final digits = normalized.replaceAll(RegExp(r'[^0-9]'), '');
  if (digits.isNotEmpty) {
    keys.add(digits);
    if (digits.length == 10) {
      keys.add('1$digits');
    } else if (digits.length == 11 && digits.startsWith('1')) {
      keys.add(digits.substring(1));
    }
  }

  return keys.toList(growable: false);
}
