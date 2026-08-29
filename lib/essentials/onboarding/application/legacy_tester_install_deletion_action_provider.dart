import 'package:flutter/scheduler.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../archive_environment/feature_level_providers.dart'
    show archiveAccessAuthorityProvider;
import '../../logging/feature_level_providers.dart' show appLoggerProvider;
import 'legacy_tester_install_deletion_action.dart';
import 'legacy_tester_install_deletion_presentation_provider.dart';
import 'legacy_tester_install_deletion_service_provider.dart';

part 'legacy_tester_install_deletion_action_provider.g.dart';

@Riverpod(keepAlive: true)
LegacyTesterInstallDeletionAction legacyTesterInstallDeletionAction(Ref ref) {
  final admittedAuthority = ref.watch(archiveAccessAuthorityProvider);
  return LegacyTesterInstallDeletionActionImpl(
    admittedAuthority: admittedAuthority,
    readCurrentAuthority: () => ref.read(archiveAccessAuthorityProvider),
    executeDeletion: () {
      return ref
          .read(legacyTesterInstallDeletionServiceProvider)
          .deleteAndRelaunch();
    },
    presentation: ref.read(
      legacyTesterInstallDeletionPresentationControllerProvider.notifier,
    ),
    waitForPresentationFrame: () => SchedulerBinding.instance.endOfFrame,
    reportFailure: (error, stackTrace) {
      ref
          .read(appLoggerProvider.notifier)
          .error(
            'Legacy tester installation deletion failed: $error',
            source: 'LegacyTesterInstallDeletion',
            context: {'stack': stackTrace.toString()},
          );
    },
  );
}
