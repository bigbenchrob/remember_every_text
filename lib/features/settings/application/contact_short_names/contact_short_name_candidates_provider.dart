import 'package:drift/drift.dart' as drift;
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../essentials/db/feature_level_providers.dart';

part 'contact_short_name_candidates_provider.g.dart';

final _alphabeticPattern = RegExp(r'[A-Za-z]');

class SettingsContactIdentity {
  const SettingsContactIdentity({
    required this.identityId,
    required this.displayName,
    required this.normalizedAddress,
    required this.service,
  });

  final int identityId;
  final String? displayName;
  final String? normalizedAddress;
  final String service;
}

class SettingsContactEntry {
  const SettingsContactEntry({
    required this.contactKey,
    required this.displayName,
    required this.identities,
  });

  final String contactKey;
  final String displayName;
  final List<SettingsContactIdentity> identities;
}

String _deriveDisplayName(Iterable<SettingsContactIdentity> identities) {
  String? fallbackDisplayName;
  String? fallbackHandle;

  bool looksLikePersonName(String value) {
    return _alphabeticPattern.hasMatch(value);
  }

  for (final identity in identities) {
    final name = identity.displayName?.trim();
    if (name != null && name.isNotEmpty) {
      if (looksLikePersonName(name)) {
        return name;
      }
      fallbackDisplayName ??= name;
    }

    final handle = identity.normalizedAddress?.trim();
    if (handle != null && handle.isNotEmpty && fallbackHandle == null) {
      fallbackHandle = handle;
    }
  }

  if (fallbackDisplayName != null) {
    return fallbackDisplayName;
  }

  if (fallbackHandle != null) {
    return fallbackHandle;
  }

  return 'Unknown Contact';
}

@riverpod
Future<List<SettingsContactEntry>> contactShortNameCandidates(Ref ref) async {
  final db = await ref.watch(driftWorkingDatabaseProvider.future);
  final rows =
      await (db.select(db.workingParticipants)..orderBy([
            (tbl) => drift.OrderingTerm(expression: tbl.displayName),
            (tbl) => drift.OrderingTerm(expression: tbl.normalizedAddress),
          ]))
          .get();

  final groups = <String, List<SettingsContactIdentity>>{};

  for (final participant in rows) {
    if (participant.isSystem) {
      continue;
    }
    final contactRef = participant.contactRef?.trim();
    final key = contactRef != null && contactRef.isNotEmpty
        ? 'contact:$contactRef'
        : 'participant:${participant.id}';

    final participantEntry = SettingsContactIdentity(
      identityId: participant.id,
      displayName: participant.displayName,
      normalizedAddress: participant.normalizedAddress,
      service: participant.service,
    );

    groups
        .putIfAbsent(key, () => <SettingsContactIdentity>[])
        .add(participantEntry);
  }

  final entries = groups.entries.map((entry) {
    final displayName = _deriveDisplayName(entry.value);
    return SettingsContactEntry(
      contactKey: entry.key,
      displayName: displayName,
      identities: List<SettingsContactIdentity>.unmodifiable(entry.value),
    );
  }).toList();

  entries.sort(
    (a, b) =>
        a.displayName.toLowerCase().compareTo(b.displayName.toLowerCase()),
  );

  return entries;
}
