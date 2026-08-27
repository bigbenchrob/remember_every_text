import '../domain/message_lens_installation_state.dart';
import '../domain/onboarding_operation_snapshot.dart';
import 'message_lens_installation_evidence_reader.dart';
import 'message_lens_installation_state_classifier.dart';

final class CompleteInstallationEraseVirginVerificationException
    implements Exception {
  const CompleteInstallationEraseVirginVerificationException({
    required this.verifiedState,
  });

  final MessageLensInstallationState verifiedState;

  @override
  String toString() {
    return 'Complete installation erase did not establish the virgin '
        'installation contract: ${verifiedState.kind.name} '
        '(${verifiedState.reason})';
  }
}

final class CompleteInstallationEraseVirginVerifier {
  const CompleteInstallationEraseVirginVerifier({
    required this.evidenceReader,
    this.classifier = const MessageLensInstallationStateClassifier(),
  });

  final MessageLensInstallationEvidenceReader evidenceReader;
  final MessageLensInstallationStateClassifier classifier;

  Future<MessageLensInstallationState> verify({
    required String archiveRootPath,
  }) async {
    final verifiedState = classifier.classify(
      await evidenceReader.read(
        archiveRootPath: archiveRootPath,
        operationSnapshot: const OnboardingOperationSnapshot.idle(),
      ),
    );
    if (verifiedState.kind != MessageLensInstallationStateKind.virgin) {
      throw CompleteInstallationEraseVirginVerificationException(
        verifiedState: verifiedState,
      );
    }
    return verifiedState;
  }
}
