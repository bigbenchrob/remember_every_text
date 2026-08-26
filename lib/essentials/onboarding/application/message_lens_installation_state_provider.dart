import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../archive_environment/feature_level_providers.dart'
    show archiveAccessAuthorityProvider;
import '../../logging/feature_level_providers.dart' show appLoggerProvider;
import '../domain/message_lens_installation_state.dart';
import '../infrastructure/persistence/sqlite_message_lens_installation_evidence_reader.dart';
import 'message_lens_installation_state_classifier.dart';
import 'onboarding_operation_snapshot_provider.dart';

part 'message_lens_installation_state_provider.g.dart';

@Riverpod(keepAlive: true)
Future<MessageLensInstallationState> messageLensInstallationState(
  Ref ref,
) async {
  final operationController = await ref.watch(
    onboardingOperationControllerProvider.future,
  );
  final authority = ref.watch(archiveAccessAuthorityProvider);
  final stopwatch = Stopwatch()..start();
  final evidence = await const SqliteMessageLensInstallationEvidenceReader()
      .read(
        archiveRootPath: authority.rootPath,
        operationSnapshot: operationController.current,
      );
  stopwatch.stop();
  ref
      .read(appLoggerProvider.notifier)
      .info(
        'Installation evidence inspection completed',
        source: 'InstallationState',
        context: {'durationMs': stopwatch.elapsedMilliseconds.toString()},
      );
  return const MessageLensInstallationStateClassifier().classify(evidence);
}
