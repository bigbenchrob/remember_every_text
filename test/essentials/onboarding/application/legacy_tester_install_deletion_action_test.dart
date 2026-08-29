import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/archive_environment/domain.dart';
import 'package:remember_this_text/essentials/onboarding/application/legacy_tester_install_deletion_action.dart';
import 'package:remember_this_text/essentials/onboarding/application/legacy_tester_install_deletion_presentation_provider.dart';
import 'package:remember_this_text/essentials/onboarding/domain/legacy_tester_install_deletion_presentation.dart';

void main() {
  test('cancel is presentation-only and performs zero mutation', () {
    final presentation = _RecordingPresentation();
    var executions = 0;
    final action = _action(
      presentation: presentation,
      executeDeletion: () async {
        executions += 1;
      },
    );

    action.cancel();

    expect(presentation.cancelled, isTrue);
    expect(executions, 0);
  });

  test('confirmation paints preparing before deletion begins', () async {
    final presentation = _RecordingPresentation();
    var frameReached = false;
    var executions = 0;
    final action = _action(
      presentation: presentation,
      waitForPresentationFrame: () async {
        expect(presentation.phase, LegacyTesterInstallDeletionPhase.preparing);
        expect(executions, 0);
        frameReached = true;
      },
      executeDeletion: () async {
        expect(frameReached, isTrue);
        expect(presentation.phase, LegacyTesterInstallDeletionPhase.deleting);
        executions += 1;
      },
    );

    final result = await action.confirmDeletion();

    expect(result, LegacyTesterInstallDeletionActionResult.deleted);
    expect(executions, 1);
    expect(presentation.phase, LegacyTesterInstallDeletionPhase.handingOff);
  });

  test('stale startup authority cannot delete after confirmation', () async {
    final presentation = _RecordingPresentation();
    var currentAuthority = _legacyAuthority();
    var executions = 0;
    final action = _action(
      presentation: presentation,
      readCurrentAuthority: () => currentAuthority,
      waitForPresentationFrame: () async {
        currentAuthority = _fullAuthority();
      },
      executeDeletion: () async {
        executions += 1;
      },
    );

    final result = await action.confirmDeletion();

    expect(result, LegacyTesterInstallDeletionActionResult.superseded);
    expect(executions, 0);
  });

  test('non-legacy authority cannot begin the action', () async {
    final presentation = _RecordingPresentation();
    final action = LegacyTesterInstallDeletionActionImpl(
      admittedAuthority: _fullAuthority(),
      readCurrentAuthority: _fullAuthority,
      executeDeletion: () async {},
      presentation: presentation,
      waitForPresentationFrame: () async {},
      reportFailure: (_, __) {},
    );

    expect(action.confirmDeletion, throwsA(isA<StateError>()));
    expect(
      presentation.phase,
      LegacyTesterInstallDeletionPhase.awaitingAuthorization,
    );
  });

  test(
    'execution failure remains typed and retry is authority-bound',
    () async {
      final presentation = _RecordingPresentation();
      var currentAuthority = _legacyAuthority();
      var executions = 0;
      final action = _action(
        presentation: presentation,
        readCurrentAuthority: () => currentAuthority,
        executeDeletion: () async {
          executions += 1;
          throw const FileSystemException('fixture deletion failed');
        },
      );

      expect(
        await action.confirmDeletion(),
        LegacyTesterInstallDeletionActionResult.failed,
      );
      final failedOccurrence = presentation.occurrence;
      expect(presentation.phase, LegacyTesterInstallDeletionPhase.failed);
      expect(
        presentation.failure?.kind,
        LegacyTesterInstallDeletionFailureKind.executionFailed,
      );
      expect(presentation.failure?.canRetry, isTrue);

      currentAuthority = _fullAuthority();
      expect(
        await action.retry(occurrence: failedOccurrence),
        LegacyTesterInstallDeletionActionResult.superseded,
      );
      expect(executions, 1);
    },
  );
}

LegacyTesterInstallDeletionActionImpl _action({
  required _RecordingPresentation presentation,
  ArchiveAccessAuthority Function()? readCurrentAuthority,
  Future<void> Function()? executeDeletion,
  Future<void> Function()? waitForPresentationFrame,
}) {
  return LegacyTesterInstallDeletionActionImpl(
    admittedAuthority: _legacyAuthority(),
    readCurrentAuthority: readCurrentAuthority ?? _legacyAuthority,
    executeDeletion: executeDeletion ?? () async {},
    presentation: presentation,
    waitForPresentationFrame: waitForPresentationFrame ?? () async {},
    reportFailure: (_, __) {},
  );
}

ArchiveAccessAuthority _legacyAuthority() => ArchiveAccessAuthority(
  identity: _identity(),
  mode: ArchiveAccessMode.legacyTesterInstallDetected,
);

ArchiveAccessAuthority _fullAuthority() =>
    ArchiveAccessAuthority(identity: _identity());

ResolvedArchiveIdentity _identity() => ResolvedArchiveIdentity(
  environment: ArchiveEnvironment.production,
  buildIdentity: ArchiveBuildIdentity.productionRelease,
  archiveInstanceId: ArchiveInstanceId('11111111-1111-4111-8111-111111111111'),
  canonicalRootPath: '/tmp/legacy-tester-action-test',
  bundleIdentifier: 'com.bigbenchsoftware.MessageLens',
  productName: 'MessageLens',
);

final class _RecordingPresentation
    implements LegacyTesterInstallDeletionPresentationPort {
  var phase = LegacyTesterInstallDeletionPhase.awaitingAuthorization;
  var occurrence = 0;
  LegacyTesterInstallDeletionFailure? failure;
  var cancelled = false;

  @override
  int? beginPreparing() {
    if (phase != LegacyTesterInstallDeletionPhase.awaitingAuthorization) {
      return null;
    }
    occurrence += 1;
    phase = LegacyTesterInstallDeletionPhase.preparing;
    return occurrence;
  }

  @override
  int? beginRetry({required int expectedOccurrence}) {
    if (!isCurrent(expectedOccurrence) ||
        phase != LegacyTesterInstallDeletionPhase.failed ||
        failure?.canRetry != true) {
      return null;
    }
    occurrence += 1;
    phase = LegacyTesterInstallDeletionPhase.preparing;
    return occurrence;
  }

  @override
  void cancel() {
    cancelled = true;
    occurrence += 1;
    phase = LegacyTesterInstallDeletionPhase.cancelled;
  }

  @override
  bool isCurrent(int occurrence) => this.occurrence == occurrence;

  @override
  void showDeleting({required int expectedOccurrence}) {
    if (isCurrent(expectedOccurrence)) {
      phase = LegacyTesterInstallDeletionPhase.deleting;
    }
  }

  @override
  void showFailure({
    required int expectedOccurrence,
    required LegacyTesterInstallDeletionFailure failure,
  }) {
    if (isCurrent(expectedOccurrence)) {
      phase = LegacyTesterInstallDeletionPhase.failed;
      this.failure = failure;
    }
  }

  @override
  void showHandoff({required int expectedOccurrence}) {
    if (isCurrent(expectedOccurrence)) {
      phase = LegacyTesterInstallDeletionPhase.handingOff;
    }
  }
}
