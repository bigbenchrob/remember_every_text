import '../../archive_environment/domain/archive_access_authority.dart';
import '../../archive_environment/domain/archive_mutation_denied_exception.dart';
import '../domain/legacy_tester_install_deletion_presentation.dart';
import 'complete_installation_erase_virgin_verifier.dart';
import 'legacy_tester_install_deletion_presentation_provider.dart';

enum LegacyTesterInstallDeletionActionResult {
  cancelled,
  deleted,
  failed,
  superseded,
}

abstract interface class LegacyTesterInstallDeletionAction {
  void cancel();

  Future<LegacyTesterInstallDeletionActionResult> confirmDeletion();

  Future<LegacyTesterInstallDeletionActionResult> retry({
    required int occurrence,
  });
}

final class LegacyTesterInstallDeletionActionImpl
    implements LegacyTesterInstallDeletionAction {
  const LegacyTesterInstallDeletionActionImpl({
    required this.admittedAuthority,
    required this.readCurrentAuthority,
    required this.executeDeletion,
    required this.presentation,
    required this.waitForPresentationFrame,
    required this.reportFailure,
  });

  final ArchiveAccessAuthority admittedAuthority;
  final ArchiveAccessAuthority Function() readCurrentAuthority;
  final Future<void> Function() executeDeletion;
  final LegacyTesterInstallDeletionPresentationPort presentation;
  final Future<void> Function() waitForPresentationFrame;
  final void Function(Object error, StackTrace stackTrace) reportFailure;

  @override
  void cancel() {
    presentation.cancel();
  }

  @override
  Future<LegacyTesterInstallDeletionActionResult> confirmDeletion() {
    _requireExactLegacyAuthority(admittedAuthority);
    final occurrence = presentation.beginPreparing();
    if (occurrence == null) {
      return Future.value(LegacyTesterInstallDeletionActionResult.superseded);
    }
    return _execute(occurrence: occurrence);
  }

  @override
  Future<LegacyTesterInstallDeletionActionResult> retry({
    required int occurrence,
  }) {
    final nextOccurrence = presentation.beginRetry(
      expectedOccurrence: occurrence,
    );
    if (nextOccurrence == null) {
      return Future.value(LegacyTesterInstallDeletionActionResult.superseded);
    }
    return _execute(occurrence: nextOccurrence);
  }

  Future<LegacyTesterInstallDeletionActionResult> _execute({
    required int occurrence,
  }) async {
    await waitForPresentationFrame();
    if (!presentation.isCurrent(occurrence) ||
        !_sameAuthority(readCurrentAuthority(), admittedAuthority)) {
      return LegacyTesterInstallDeletionActionResult.superseded;
    }

    presentation.showDeleting(expectedOccurrence: occurrence);
    try {
      await executeDeletion();
      presentation.showHandoff(expectedOccurrence: occurrence);
      return presentation.isCurrent(occurrence)
          ? LegacyTesterInstallDeletionActionResult.deleted
          : LegacyTesterInstallDeletionActionResult.superseded;
    } catch (error, stackTrace) {
      reportFailure(error, stackTrace);
      presentation.showFailure(
        expectedOccurrence: occurrence,
        failure: LegacyTesterInstallDeletionFailure(
          kind: switch (error) {
            ArchiveMutationDeniedException() =>
              LegacyTesterInstallDeletionFailureKind.mutationUnavailable,
            CompleteInstallationEraseVirginVerificationException() =>
              LegacyTesterInstallDeletionFailureKind.virginVerificationFailed,
            _ => LegacyTesterInstallDeletionFailureKind.executionFailed,
          },
          summary: switch (error) {
            ArchiveMutationDeniedException() =>
              'Another MessageLens data operation is still active.',
            CompleteInstallationEraseVirginVerificationException() =>
              'MessageLens could not verify a clean setup after removing the '
                  'old test data.',
            _ => 'MessageLens could not finish removing the old test setup.',
          },
          canRetry: _sameAuthority(readCurrentAuthority(), admittedAuthority),
        ),
      );
      return presentation.isCurrent(occurrence)
          ? LegacyTesterInstallDeletionActionResult.failed
          : LegacyTesterInstallDeletionActionResult.superseded;
    }
  }

  void _requireExactLegacyAuthority(ArchiveAccessAuthority authority) {
    if (authority.mode != ArchiveAccessMode.legacyTesterInstallDetected) {
      throw StateError(
        'Legacy tester deletion requires exact legacy startup admission.',
      );
    }
  }

  bool _sameAuthority(
    ArchiveAccessAuthority current,
    ArchiveAccessAuthority admitted,
  ) {
    return current.mode == ArchiveAccessMode.legacyTesterInstallDetected &&
        current.mode == admitted.mode &&
        current.rootPath == admitted.rootPath &&
        current.identity.environment == admitted.identity.environment &&
        current.identity.buildIdentity == admitted.identity.buildIdentity &&
        current.identity.archiveInstanceId ==
            admitted.identity.archiveInstanceId &&
        current.identity.bundleIdentifier == admitted.identity.bundleIdentifier;
  }
}
