import '../domain/message_lens_installation_state.dart';
import '../domain/onboarding_operation_snapshot.dart';

abstract interface class MessageLensInstallationEvidenceReader {
  MessageLensInstallationEvidence read({
    required String archiveRootPath,
    required OnboardingOperationSnapshot operationSnapshot,
  });
}
