import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../essentials/db/feature_level_providers.dart'
    show driftConversationGraphDatabaseProvider, overlayDatabaseProvider;
import '../../../contacts/feature_level_providers.dart'
    show displayIdentityResolverProvider;
import '../../infrastructure/repositories/graph_handle_display_name_reader.dart';
import 'handle_display_name_reader.dart';

part 'handle_display_name_provider.g.dart';

@riverpod
Future<HandleDisplayNameReader> handleDisplayNameReader(Ref ref) async {
  final graphDb = await ref.watch(
    driftConversationGraphDatabaseProvider.future,
  );
  final overlayDb = await ref.watch(overlayDatabaseProvider.future);
  final displayIdentityResolver = await ref.watch(
    displayIdentityResolverProvider.future,
  );
  return GraphHandleDisplayNameReader(
    graphDb: graphDb,
    overlayDb: overlayDb,
    displayIdentityResolver: displayIdentityResolver,
  );
}

@riverpod
Future<String> handleDisplayName(Ref ref, {required int handleId}) async {
  final reader = await ref.watch(handleDisplayNameReaderProvider.future);
  return reader.readHandleDisplayName(handleId: handleId);
}
