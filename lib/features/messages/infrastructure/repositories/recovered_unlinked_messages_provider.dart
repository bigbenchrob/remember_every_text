import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../essentials/db/feature_level_providers.dart';
import '../../../contacts/infrastructure/repositories/handles_for_contact_provider.dart';
import '../../domain/message_evidence/recovered_message_evidence.dart';
import 'graph_recovered_message_evidence_repository.dart';

part 'recovered_unlinked_messages_provider.g.dart';

@riverpod
Stream<List<RecoveredUnlinkedMessageItem>> recoveredUnlinkedMessages(
  Ref ref, {
  int? contactId,
}) async* {
  final readiness = await ref.watch(conversationGraphReadinessProvider.future);
  if (!readiness.isReady) {
    yield const <RecoveredUnlinkedMessageItem>[];
    return;
  }

  final db = await ref.watch(driftConversationGraphDatabaseProvider.future);
  final scopedHandleIds = contactId == null
      ? null
      : (await ref.watch(
          handlesForContactProvider(contactId: contactId).future,
        )).map((handle) => handle.handleId).toSet();
  final repository = GraphRecoveredMessageEvidenceRepository(graphDb: db);
  yield* repository.watchMessages(
    contactId: contactId,
    scopedHandleIds: scopedHandleIds,
  );
}
