import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../db/feature_level_providers.dart';
import '../../application/developer_mode_store.dart';
import 'overlay_developer_mode_store.dart';

part 'developer_mode_store_provider.g.dart';

@riverpod
Future<DeveloperModeStore> developerModeStore(DeveloperModeStoreRef ref) async {
  final overlayDatabase = await ref.watch(overlayDatabaseProvider.future);
  return OverlayDeveloperModeStore(overlayDatabase: overlayDatabase);
}
