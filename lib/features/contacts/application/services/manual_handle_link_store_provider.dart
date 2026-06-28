import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../essentials/db/feature_level_providers/persistent_database_providers.dart'
    show overlayDatabaseProvider;
import '../../infrastructure/repositories/overlay_manual_handle_link_store.dart';
import 'manual_handle_link_store.dart';

part 'manual_handle_link_store_provider.g.dart';

@riverpod
Future<ManualHandleLinkStore> manualHandleLinkStore(Ref ref) async {
  final overlayDatabase = await ref.watch(overlayDatabaseProvider.future);
  return OverlayManualHandleLinkStore(overlayDatabase: overlayDatabase);
}
