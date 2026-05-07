import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'message_data_version_provider.dart';
import 'working_projection_readiness_provider.dart';

part 'working_db_populated_provider.g.dart';

/// Whether `working.db` contains a completed projection.
///
/// Watches [messageDataVersionProvider] so it re-evaluates after migration
/// bumps that signal. Used to gate sidebar cascades and the top menu prompt
/// on first launch.
@Riverpod(keepAlive: true)
class WorkingDbPopulated extends _$WorkingDbPopulated {
  @override
  bool build() {
    // Re-evaluate whenever the data-version signal fires (e.g. after migration).
    ref.watch(messageDataVersionProvider);
    final readiness = ref.watch(workingProjectionReadinessProvider);

    return readiness.valueOrNull?.isReady ?? false;
  }
}
