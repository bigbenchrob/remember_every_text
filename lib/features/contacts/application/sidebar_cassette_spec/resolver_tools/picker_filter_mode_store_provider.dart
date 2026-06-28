import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../../../essentials/db/feature_level_providers.dart'
    show overlayDatabaseProvider;
import '../../../infrastructure/repositories/overlay_picker_filter_mode_store.dart';
import 'picker_filter_mode_store.dart';

part 'picker_filter_mode_store_provider.g.dart';

@riverpod
Future<PickerFilterModeStore> pickerFilterModeStore(Ref ref) async {
  final overlayDatabase = await ref.watch(overlayDatabaseProvider.future);
  return OverlayPickerFilterModeStore(overlayDatabase: overlayDatabase);
}
