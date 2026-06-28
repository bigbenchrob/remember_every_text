import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../../essentials/db/feature_level_providers/persistent_database_providers.dart'
    show overlayDatabaseProvider;
import '../../../infrastructure/repositories/overlay_handle_visibility_store.dart';
import 'handle_visibility_store.dart';

part 'handle_visibility_store_provider.g.dart';

@riverpod
Future<HandleVisibilityStore> handleVisibilityStore(Ref ref) async {
  final overlayDatabase = await ref.watch(overlayDatabaseProvider.future);
  return OverlayHandleVisibilityStore(overlayDatabase: overlayDatabase);
}
