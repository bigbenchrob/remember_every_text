import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../essentials/db/feature_level_providers.dart';
import '../../application/sidebar_cassette_spec/resolver_tools/picker_filter_mode_store.dart';
import 'overlay_picker_filter_mode_store.dart';

part 'picker_filter_mode_store_provider.g.dart';

@riverpod
Future<PickerFilterModeStore> pickerFilterModeStore(
  PickerFilterModeStoreRef ref,
) async {
  final overlayDatabase = await ref.watch(overlayDatabaseProvider.future);
  return OverlayPickerFilterModeStore(overlayDatabase: overlayDatabase);
}
