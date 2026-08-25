import '../../archive_environment/domain/archive_mutation_denied_exception.dart';
import '../domain/advanced_start_fresh_presentation.dart';
import '../domain/message_lens_installation_state.dart';
import 'advanced_start_fresh_presentation_provider.dart';
import 'start_fresh_service.dart';

enum AdvancedStartFreshActionResult {
  cancelled,
  startedFresh,
  failed,
  superseded,
}

abstract interface class AdvancedStartFreshAction {
  Future<AdvancedStartFreshActionResult> request();

  Future<AdvancedStartFreshActionResult> retry({required int occurrence});

  void dismissFailure({required int occurrence});
}

final class AdvancedStartFreshActionImpl implements AdvancedStartFreshAction {
  const AdvancedStartFreshActionImpl({
    required this.readInstallationState,
    required this.requestAuthorization,
    required this.readStartFreshService,
    required this.presentation,
    required this.waitForPresentationFrame,
    required this.reportFailure,
  });

  final Future<MessageLensInstallationState> Function() readInstallationState;
  final Future<bool> Function() requestAuthorization;
  final Future<StartFreshService> Function() readStartFreshService;
  final AdvancedStartFreshPresentationPort presentation;
  final Future<void> Function() waitForPresentationFrame;
  final void Function(Object error, StackTrace stackTrace) reportFailure;

  @override
  Future<AdvancedStartFreshActionResult> request() async {
    final installationState = await readInstallationState();
    if (installationState.kind != MessageLensInstallationStateKind.completed) {
      throw StateError(
        'The advanced Start Fresh action requires a completed installation, '
        'but found ${installationState.kind.name}: '
        '${installationState.reason}',
      );
    }

    if (!await requestAuthorization()) {
      return AdvancedStartFreshActionResult.cancelled;
    }

    final occurrence = presentation.beginPreparing();
    return _execute(
      occurrence: occurrence,
      entryPoint: StartFreshEntryPoint.completedInstallationAdvancedReset,
    );
  }

  @override
  Future<AdvancedStartFreshActionResult> retry({
    required int occurrence,
  }) async {
    final nextOccurrence = presentation.beginRetry(
      expectedOccurrence: occurrence,
    );
    if (nextOccurrence == null) {
      return AdvancedStartFreshActionResult.superseded;
    }

    return _execute(occurrence: nextOccurrence);
  }

  @override
  void dismissFailure({required int occurrence}) {
    presentation.dismiss(expectedOccurrence: occurrence);
  }

  Future<AdvancedStartFreshActionResult> _execute({
    required int occurrence,
    StartFreshEntryPoint? entryPoint,
  }) async {
    await waitForPresentationFrame();
    if (!presentation.isCurrent(occurrence)) {
      return AdvancedStartFreshActionResult.superseded;
    }

    try {
      final resolvedEntryPoint = entryPoint ?? await _resolveRetryEntryPoint();
      final service = await readStartFreshService();
      await service.startFresh(entryPoint: resolvedEntryPoint);
      presentation.showVerifiedVirgin(expectedOccurrence: occurrence);
      return presentation.isCurrent(occurrence)
          ? AdvancedStartFreshActionResult.startedFresh
          : AdvancedStartFreshActionResult.superseded;
    } catch (error, stackTrace) {
      reportFailure(error, stackTrace);
      final failure = await _failureFor(error);
      presentation.showFailure(
        expectedOccurrence: occurrence,
        failure: failure,
      );
      return presentation.isCurrent(occurrence)
          ? AdvancedStartFreshActionResult.failed
          : AdvancedStartFreshActionResult.superseded;
    }
  }

  Future<StartFreshEntryPoint> _resolveRetryEntryPoint() async {
    final installationState = await readInstallationState();
    return switch (installationState.kind) {
      MessageLensInstallationStateKind.completed =>
        StartFreshEntryPoint.completedInstallationAdvancedReset,
      MessageLensInstallationStateKind.resumable ||
      MessageLensInstallationStateKind.abandoned =>
        StartFreshEntryPoint.incompleteInstallation,
      _ => throw StateError(
        'Start Fresh retry is unavailable for '
        '${installationState.kind.name}: ${installationState.reason}',
      ),
    };
  }

  Future<AdvancedStartFreshFailure> _failureFor(Object error) async {
    final kind = switch (error) {
      ArchiveMutationDeniedException() =>
        AdvancedStartFreshFailureKind.mutationUnavailable,
      StartFreshVirginVerificationException() =>
        AdvancedStartFreshFailureKind.virginVerificationFailed,
      _ => AdvancedStartFreshFailureKind.executionFailed,
    };
    var canRetry = false;
    try {
      final installationState = await readInstallationState();
      canRetry =
          installationState.kind ==
              MessageLensInstallationStateKind.completed ||
          installationState.mayStartFresh;
    } catch (error, stackTrace) {
      reportFailure(error, stackTrace);
      canRetry = false;
    }

    final summary = switch (kind) {
      AdvancedStartFreshFailureKind.mutationUnavailable =>
        'Another MessageLens data operation is still active.',
      AdvancedStartFreshFailureKind.virginVerificationFailed =>
        'MessageLens could not verify a clean onboarding state.',
      AdvancedStartFreshFailureKind.executionFailed =>
        'MessageLens could not finish starting fresh.',
    };
    return AdvancedStartFreshFailure(
      kind: kind,
      summary: summary,
      canRetry: canRetry,
    );
  }
}
