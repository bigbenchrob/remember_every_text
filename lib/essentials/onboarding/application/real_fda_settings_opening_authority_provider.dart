import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'fda_settings_opening_adapter.dart';
import 'full_disk_access_provider.dart';

part 'real_fda_settings_opening_authority_provider.g.dart';

@Riverpod(keepAlive: true)
FdaSettingsOpeningAdapter realFdaSettingsOpeningAuthority(Ref ref) {
  return FdaSettingsOpeningAdapter(
    fullDiskAccess: ref.watch(fullDiskAccessProvider),
  );
}
