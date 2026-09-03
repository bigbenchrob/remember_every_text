import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../archive_environment/feature_level_providers.dart'
    show archiveAccessAuthorityProvider;
import '../domain/message_lens_installation_state.dart';
import '../infrastructure/persistence/sqlite_message_lens_installation_evidence_reader.dart';
import 'message_lens_installation_state_classifier.dart';

part 'message_lens_installation_state_provider.g.dart';

@Riverpod(keepAlive: true)
Future<MessageLensInstallationState> messageLensInstallationState(
  Ref ref,
) async {
  final authority = ref.watch(archiveAccessAuthorityProvider);
  final evidence = await const SqliteMessageLensInstallationEvidenceReader()
      .read(archiveRootPath: authority.rootPath);
  return const MessageLensInstallationStateClassifier().classify(evidence);
}
