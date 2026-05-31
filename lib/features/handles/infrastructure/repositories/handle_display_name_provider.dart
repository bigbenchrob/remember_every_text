import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../essentials/db/feature_level_providers.dart';
import '../../../contacts/feature_level_providers.dart';

part 'handle_display_name_provider.g.dart';

/// Resolves the display name for a handle, checking overlay overrides first.
///
/// Priority: virtual participant name > real participant name > raw handle value.
@riverpod
Future<String> handleDisplayName(Ref ref, {required int handleId}) async {
  final overlayDb = await ref.watch(overlayDatabaseProvider.future);
  final graphDb = await ref.watch(
    driftConversationGraphDatabaseProvider.future,
  );

  // Check overlay for a linked virtual or real participant.
  final override = await overlayDb.getHandleOverride(handleId);
  if (override != null) {
    // Virtual participant link?
    if (override.virtualParticipantId != null) {
      final vp = await overlayDb.getVirtualParticipant(
        override.virtualParticipantId!,
      );
      if (vp != null) {
        return vp.displayName;
      }
    }

    // Real participant link?
    if (override.participantId != null) {
      final resolver = await ref.watch(displayIdentityResolverProvider.future);
      final identity = resolver.resolveContact(override.participantId!);
      if (identity.isKnownContact) {
        return identity.primaryLabel;
      }
    }
  }

  final resolver = await ref.watch(displayIdentityResolverProvider.future);
  final graphIdentity = resolver.identitiesByHandleId[handleId];
  if (graphIdentity != null) {
    return graphIdentity.primaryLabel;
  }

  final graphRows = await graphDb.selectRows(
    '''
    SELECT
      COALESCE(ch.display_handle, h.id) AS display_value
    FROM handles h
    LEFT JOIN handle_aliases ha ON ha.handle_ss_id = h.ss_id
    LEFT JOIN canonical_handles ch
      ON ch.canonical_handle_ss_id =
        COALESCE(ha.canonical_handle_ss_id, h.ss_id)
    WHERE h.ss_id = ?
       OR ch.canonical_handle_ss_id = ?
    LIMIT 1
    ''',
    <Object?>[handleId, handleId],
  );
  if (graphRows.isNotEmpty) {
    final displayValue = (graphRows.single['display_value'] as String?)?.trim();
    if (displayValue != null && displayValue.isNotEmpty) {
      return displayValue;
    }
  }

  return 'Handle #$handleId';
}
