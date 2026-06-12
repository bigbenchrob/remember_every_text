import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../essentials/db/feature_level_providers.dart';
import '../../application/display_name_overrides/contact_display_name_override_store.dart';
import 'overlay_contact_display_name_override_store.dart';

part 'contact_display_name_override_store_provider.g.dart';

@riverpod
Future<ContactDisplayNameOverrideStore> contactDisplayNameOverrideStore(
  ContactDisplayNameOverrideStoreRef ref,
) async {
  final overlayDatabase = await ref.watch(overlayDatabaseProvider.future);
  return OverlayContactDisplayNameOverrideStore(
    overlayDatabase: overlayDatabase,
  );
}
