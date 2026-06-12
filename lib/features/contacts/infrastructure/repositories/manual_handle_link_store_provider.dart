import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../essentials/db/feature_level_providers.dart';
import '../../application/services/manual_handle_link_store.dart';
import 'overlay_manual_handle_link_store.dart';

part 'manual_handle_link_store_provider.g.dart';

@riverpod
Future<ManualHandleLinkStore> manualHandleLinkStore(
  ManualHandleLinkStoreRef ref,
) async {
  final overlayDatabase = await ref.watch(overlayDatabaseProvider.future);
  return OverlayManualHandleLinkStore(overlayDatabase: overlayDatabase);
}
