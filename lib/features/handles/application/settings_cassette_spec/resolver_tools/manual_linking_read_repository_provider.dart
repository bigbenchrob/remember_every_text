import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../../essentials/db/feature_level_providers.dart'
    show driftConversationGraphDatabaseProvider, overlayDatabaseProvider;
import '../../../../contacts/feature_level_providers.dart'
    show displayIdentityResolverProvider, virtualParticipantsProvider;
import '../../../infrastructure/repositories/graph_manual_linking_read_repository.dart';
import 'manual_linking_read_repository.dart';

part 'manual_linking_read_repository_provider.g.dart';

@riverpod
Future<ManualLinkingReadRepository> manualLinkingReadRepository(Ref ref) async {
  final graphDb = await ref.watch(
    driftConversationGraphDatabaseProvider.future,
  );
  final overlayDb = await ref.watch(overlayDatabaseProvider.future);
  final virtualContacts = await ref.watch(virtualParticipantsProvider.future);
  final displayIdentityResolver = await ref.watch(
    displayIdentityResolverProvider.future,
  );
  return GraphManualLinkingReadRepository(
    graphDb: graphDb,
    overlayDb: overlayDb,
    virtualContacts: virtualContacts,
    displayIdentityResolver: displayIdentityResolver,
  );
}
