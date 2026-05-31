import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../essentials/db/feature_level_providers.dart';
import '../../../contacts/infrastructure/repositories/handles_for_contact_provider.dart';
import '../../domain/message_evidence/recovered_message_evidence.dart';
import 'legacy_working_recovered_message_evidence_repository.dart';

part 'recovered_unlinked_messages_provider.g.dart';

@riverpod
Stream<List<RecoveredUnlinkedMessageItem>> recoveredUnlinkedMessages(
  Ref ref, {
  int? contactId,
}) async* {
  final readiness = await ref.watch(workingProjectionReadinessProvider.future);
  if (!readiness.isReady) {
    yield const <RecoveredUnlinkedMessageItem>[];
    return;
  }

  final db = await ref.watch(driftWorkingDatabaseProvider.future);
  final overlayDb = await ref.watch(overlayDatabaseProvider.future);
  final scopedHandleIds = contactId == null
      ? null
      : (await ref.watch(
          handlesForContactProvider(contactId: contactId).future,
        )).map((handle) => handle.handleId).toSet();
  final repository = LegacyWorkingRecoveredMessageEvidenceRepository(
    db: db,
    overlayDb: overlayDb,
  );
  yield* repository.watchMessages(
    contactId: contactId,
    scopedHandleIds: scopedHandleIds,
  );
}
