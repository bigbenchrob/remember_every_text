import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../essentials/db/feature_level_providers.dart';
import '../../application/settings_cassette_spec/resolver_tools/handle_visibility_store.dart';
import 'overlay_handle_visibility_store.dart';

part 'handle_visibility_store_provider.g.dart';

@riverpod
Future<HandleVisibilityStore> handleVisibilityStore(
  HandleVisibilityStoreRef ref,
) async {
  final overlayDatabase = await ref.watch(overlayDatabaseProvider.future);
  return OverlayHandleVisibilityStore(overlayDatabase: overlayDatabase);
}
