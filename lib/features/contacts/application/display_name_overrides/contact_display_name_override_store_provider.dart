import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../essentials/db/feature_level_providers.dart'
    show overlayDatabaseProvider;
import '../../infrastructure/repositories/overlay_contact_display_name_override_store.dart';
import 'contact_display_name_override_store.dart';

part 'contact_display_name_override_store_provider.g.dart';

@riverpod
Future<ContactDisplayNameOverrideStore> contactDisplayNameOverrideStore(
  Ref ref,
) async {
  final overlayDatabase = await ref.watch(overlayDatabaseProvider.future);
  return OverlayContactDisplayNameOverrideStore(
    overlayDatabase: overlayDatabase,
  );
}
