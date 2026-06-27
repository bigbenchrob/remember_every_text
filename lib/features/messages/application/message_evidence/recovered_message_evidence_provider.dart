import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../essentials/db/feature_level_providers.dart'
    show
        conversationGraphReadinessProvider,
        driftConversationGraphDatabaseProvider;
import '../../../contacts/feature_level_providers.dart'
    show displayIdentityResolverProvider, handlesForContactProvider;
import '../../domain/message_evidence/recovered_message_evidence.dart';
import '../../infrastructure/repositories/graph_recovered_message_evidence_repository.dart';

part 'recovered_message_evidence_provider.g.dart';

@riverpod
Future<RecoveredMessageEvidenceRepository> recoveredMessageEvidenceRepository(
  Ref ref,
) async {
  final graphDb = await ref.watch(
    driftConversationGraphDatabaseProvider.future,
  );
  final displayIdentityResolver = await ref.watch(
    displayIdentityResolverProvider.future,
  );
  return GraphRecoveredMessageEvidenceRepository(
    graphDb: graphDb,
    displayIdentityResolver: displayIdentityResolver,
  );
}

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

  final scopedHandleIds = contactId == null
      ? null
      : (await ref.watch(
          handlesForContactProvider(contactId: contactId).future,
        )).map((handle) => handle.handleId).toSet();
  final repository = await ref.watch(
    recoveredMessageEvidenceRepositoryProvider.future,
  );
  yield* repository.watchMessages(
    contactId: contactId,
    scopedHandleIds: scopedHandleIds,
  );
}
