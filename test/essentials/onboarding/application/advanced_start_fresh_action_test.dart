import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import 'package:remember_this_text/essentials/onboarding/application/advanced_start_fresh_action.dart';
import 'package:remember_this_text/essentials/onboarding/application/advanced_start_fresh_presentation_provider.dart';
import 'package:remember_this_text/essentials/onboarding/application/start_fresh_service.dart';
import 'package:remember_this_text/essentials/onboarding/domain/advanced_start_fresh_presentation.dart';
import 'package:remember_this_text/essentials/onboarding/domain/message_lens_installation_state.dart';

void main() {
  test(
    'completed installation requires authorization before advanced Start Fresh',
    () async {
      final service = _FakeStartFreshService();
      final presentation = _FakePresentationPort();
      final framePainted = Completer<void>();
      var authorizationRequests = 0;
      final action = AdvancedStartFreshActionImpl(
        readInstallationState: () async => _completedState,
        requestAuthorization: () async {
          authorizationRequests += 1;
          return true;
        },
        readStartFreshService: () async => service,
        presentation: presentation,
        waitForPresentationFrame: () => framePainted.future,
        reportFailure: (_, _) {},
      );

      final resultFuture = action.request();
      await Future<void>.delayed(Duration.zero);

      expect(
        presentation.state.phase,
        AdvancedStartFreshPresentationPhase.preparing,
      );
      expect(service.entryPoints, isEmpty);

      framePainted.complete();
      final result = await resultFuture;

      expect(result, AdvancedStartFreshActionResult.startedFresh);
      expect(authorizationRequests, 1);
      expect(service.entryPoints, [
        StartFreshEntryPoint.completedInstallationAdvancedReset,
      ]);
      expect(
        presentation.state.phase,
        AdvancedStartFreshPresentationPhase.verifiedVirgin,
      );
    },
  );

  test('cancelled authorization performs no Start Fresh mutation', () async {
    final service = _FakeStartFreshService();
    final action = AdvancedStartFreshActionImpl(
      readInstallationState: () async => _completedState,
      requestAuthorization: () async => false,
      readStartFreshService: () async => service,
      presentation: _FakePresentationPort(),
      waitForPresentationFrame: () async {},
      reportFailure: (_, _) {},
    );

    final result = await action.request();

    expect(result, AdvancedStartFreshActionResult.cancelled);
    expect(service.entryPoints, isEmpty);
  });

  test(
    'advanced reset rejects a non-completed installation before authorization',
    () async {
      var authorizationRequested = false;
      final service = _FakeStartFreshService();
      final action = AdvancedStartFreshActionImpl(
        readInstallationState: () async {
          return const MessageLensInstallationState(
            kind: MessageLensInstallationStateKind.abandoned,
            reason: 'incomplete test installation',
          );
        },
        requestAuthorization: () async {
          authorizationRequested = true;
          return true;
        },
        readStartFreshService: () async => service,
        presentation: _FakePresentationPort(),
        waitForPresentationFrame: () async {},
        reportFailure: (_, _) {},
      );

      await expectLater(action.request(), throwsStateError);

      expect(authorizationRequested, isFalse);
      expect(service.entryPoints, isEmpty);
    },
  );

  test(
    'typed failure remains visible and can retry from abandoned state',
    () async {
      final service = _FakeStartFreshService()..failure = StateError('disk');
      final presentation = _FakePresentationPort();
      var stateReadCount = 0;
      final action = AdvancedStartFreshActionImpl(
        readInstallationState: () async {
          stateReadCount += 1;
          return stateReadCount == 1 ? _completedState : _abandonedState;
        },
        requestAuthorization: () async => true,
        readStartFreshService: () async => service,
        presentation: presentation,
        waitForPresentationFrame: () async {},
        reportFailure: (_, _) {},
      );

      expect(await action.request(), AdvancedStartFreshActionResult.failed);
      final failedOccurrence = presentation.state.occurrence;
      expect(
        presentation.state.phase,
        AdvancedStartFreshPresentationPhase.failed,
      );
      expect(presentation.state.failure?.canRetry, isTrue);

      service.failure = null;
      expect(
        await action.retry(occurrence: failedOccurrence),
        AdvancedStartFreshActionResult.startedFresh,
      );
      expect(service.entryPoints, [
        StartFreshEntryPoint.completedInstallationAdvancedReset,
        StartFreshEntryPoint.incompleteInstallation,
      ]);
    },
  );

  test('virgin verification failure is a typed visible outcome', () async {
    final service = _FakeStartFreshService()
      ..failure = const StartFreshVirginVerificationException(
        verifiedState: MessageLensInstallationState(
          kind: MessageLensInstallationStateKind.remediationRequired,
          reason: 'derived evidence remains',
        ),
      );
    final presentation = _FakePresentationPort();
    var stateReadCount = 0;
    final action = AdvancedStartFreshActionImpl(
      readInstallationState: () async {
        stateReadCount += 1;
        return stateReadCount == 1 ? _completedState : _remediationState;
      },
      requestAuthorization: () async => true,
      readStartFreshService: () async => service,
      presentation: presentation,
      waitForPresentationFrame: () async {},
      reportFailure: (_, _) {},
    );

    expect(await action.request(), AdvancedStartFreshActionResult.failed);
    expect(
      presentation.state.failure?.kind,
      AdvancedStartFreshFailureKind.virginVerificationFailed,
    );
    expect(presentation.state.failure?.canRetry, isFalse);
  });

  test('older async completion cannot replace a newer occurrence', () async {
    final service = _ControlledStartFreshService();
    final presentation = _FakePresentationPort();
    final action = AdvancedStartFreshActionImpl(
      readInstallationState: () async => _completedState,
      requestAuthorization: () async => true,
      readStartFreshService: () async => service,
      presentation: presentation,
      waitForPresentationFrame: () async {},
      reportFailure: (_, _) {},
    );

    final first = action.request();
    await Future<void>.delayed(Duration.zero);
    final second = action.request();
    await Future<void>.delayed(Duration.zero);
    expect(presentation.state.occurrence, 2);

    service.completions[0].complete(_virginResult);
    expect(await first, AdvancedStartFreshActionResult.superseded);
    expect(
      presentation.state.phase,
      AdvancedStartFreshPresentationPhase.preparing,
    );

    service.completions[1].complete(_virginResult);
    expect(await second, AdvancedStartFreshActionResult.startedFresh);
    expect(
      presentation.state.phase,
      AdvancedStartFreshPresentationPhase.verifiedVirgin,
    );
  });
}

const _completedState = MessageLensInstallationState(
  kind: MessageLensInstallationStateKind.completed,
  reason: 'healthy completed test installation',
);

const _abandonedState = MessageLensInstallationState(
  kind: MessageLensInstallationStateKind.abandoned,
  reason: 'retryable partial reset',
);

const _remediationState = MessageLensInstallationState(
  kind: MessageLensInstallationStateKind.remediationRequired,
  reason: 'manual inspection required',
);

const _virginResult = StartFreshResult(
  verifiedState: MessageLensInstallationState(
    kind: MessageLensInstallationStateKind.virgin,
    reason: 'verified test reset',
  ),
);

final class _FakeStartFreshService implements StartFreshService {
  final entryPoints = <StartFreshEntryPoint>[];
  Object? failure;

  @override
  Future<StartFreshResult> startFresh({
    StartFreshEntryPoint entryPoint =
        StartFreshEntryPoint.incompleteInstallation,
  }) async {
    entryPoints.add(entryPoint);
    if (failure case final currentFailure?) {
      throw currentFailure;
    }
    return _virginResult;
  }
}

final class _ControlledStartFreshService implements StartFreshService {
  final completions = <Completer<StartFreshResult>>[];

  @override
  Future<StartFreshResult> startFresh({
    StartFreshEntryPoint entryPoint =
        StartFreshEntryPoint.incompleteInstallation,
  }) {
    final completer = Completer<StartFreshResult>();
    completions.add(completer);
    return completer.future;
  }
}

final class _FakePresentationPort
    implements AdvancedStartFreshPresentationPort {
  AdvancedStartFreshPresentation state =
      const AdvancedStartFreshPresentation.idle();

  @override
  int beginPreparing() {
    final occurrence = state.occurrence + 1;
    state = AdvancedStartFreshPresentation(
      occurrence: occurrence,
      phase: AdvancedStartFreshPresentationPhase.preparing,
    );
    return occurrence;
  }

  @override
  int? beginRetry({required int expectedOccurrence}) {
    if (!isCurrent(expectedOccurrence) ||
        state.phase != AdvancedStartFreshPresentationPhase.failed ||
        state.failure?.canRetry != true) {
      return null;
    }
    return beginPreparing();
  }

  @override
  void dismiss({required int expectedOccurrence}) {
    if (!isCurrent(expectedOccurrence)) {
      return;
    }
    state = AdvancedStartFreshPresentation(
      occurrence: expectedOccurrence,
      phase: AdvancedStartFreshPresentationPhase.idle,
    );
  }

  @override
  bool isCurrent(int occurrence) => state.occurrence == occurrence;

  @override
  void showFailure({
    required int expectedOccurrence,
    required AdvancedStartFreshFailure failure,
  }) {
    if (!isCurrent(expectedOccurrence)) {
      return;
    }
    state = AdvancedStartFreshPresentation(
      occurrence: expectedOccurrence,
      phase: AdvancedStartFreshPresentationPhase.failed,
      failure: failure,
    );
  }

  @override
  void showVerifiedVirgin({required int expectedOccurrence}) {
    if (!isCurrent(expectedOccurrence)) {
      return;
    }
    state = AdvancedStartFreshPresentation(
      occurrence: expectedOccurrence,
      phase: AdvancedStartFreshPresentationPhase.verifiedVirgin,
    );
  }
}
