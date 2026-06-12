import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../essentials/db/feature_level_providers.dart';
import '../../../contacts/infrastructure/repositories/virtual_participants_provider.dart';
import '../../application/settings_cassette_spec/resolver_tools/manual_linking_read_repository.dart';
import 'graph_manual_linking_read_repository.dart';

part 'manual_linking_read_repository_provider.g.dart';

@riverpod
Future<ManualLinkingReadRepository> manualLinkingReadRepository(
  ManualLinkingReadRepositoryRef ref,
) async {
  final graphDb = await ref.watch(
    driftConversationGraphDatabaseProvider.future,
  );
  final overlayDb = await ref.watch(overlayDatabaseProvider.future);
  final virtualContacts = await ref.watch(virtualParticipantsProvider.future);
  return GraphManualLinkingReadRepository(
    graphDb: graphDb,
    overlayDb: overlayDb,
    virtualContacts: virtualContacts,
  );
}
