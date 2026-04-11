import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../resolver_tools/contact_chooser_snapshot_provider.dart';

part 'contact_chooser_cassette_state_provider.g.dart';

@riverpod
ContactChooserSnapshot contactChooserCassetteState(Ref ref) {
  return ref.watch(contactChooserSnapshotProvider);
}
