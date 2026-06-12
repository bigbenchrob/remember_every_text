import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../db/feature_level_providers.dart';
import '../../application/sidebar_flow_preference_store.dart';
import 'overlay_sidebar_flow_preference_store.dart';

part 'sidebar_flow_preference_store_provider.g.dart';

@riverpod
Future<SidebarFlowPreferenceStore> sidebarFlowPreferenceStore(
  SidebarFlowPreferenceStoreRef ref,
) async {
  final overlayDatabase = await ref.watch(overlayDatabaseProvider.future);
  return OverlaySidebarFlowPreferenceStore(overlayDatabase: overlayDatabase);
}
