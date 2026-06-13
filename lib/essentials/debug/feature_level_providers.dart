// =============================================================================
// DEBUG ESSENTIAL — PUBLIC PROVIDER BOUNDARY
// =============================================================================

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../db/feature_level_providers.dart';
import 'application/developer_mode_store.dart';
import 'infrastructure/persistence/overlay_developer_mode_store.dart';

part 'feature_level_providers.g.dart';

@riverpod
Future<DeveloperModeStore> developerModeStore(Ref ref) async {
  final overlayDatabase = await ref.watch(overlayDatabaseProvider.future);
  return OverlayDeveloperModeStore(overlayDatabase: overlayDatabase);
}
