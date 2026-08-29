import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/legacy_tester_install_deletion_presentation.dart';

part 'legacy_tester_install_deletion_presentation_provider.g.dart';

abstract interface class LegacyTesterInstallDeletionPresentationPort {
  int? beginPreparing();

  int? beginRetry({required int expectedOccurrence});

  bool isCurrent(int occurrence);

  void cancel();

  void showDeleting({required int expectedOccurrence});

  void showHandoff({required int expectedOccurrence});

  void showFailure({
    required int expectedOccurrence,
    required LegacyTesterInstallDeletionFailure failure,
  });
}

@Riverpod(keepAlive: true)
class LegacyTesterInstallDeletionPresentationController
    extends _$LegacyTesterInstallDeletionPresentationController
    implements LegacyTesterInstallDeletionPresentationPort {
  @override
  LegacyTesterInstallDeletionPresentation build() {
    return const LegacyTesterInstallDeletionPresentation.awaitingAuthorization();
  }

  @override
  int? beginPreparing() {
    if (state.phase != LegacyTesterInstallDeletionPhase.awaitingAuthorization) {
      return null;
    }
    final occurrence = state.occurrence + 1;
    state = LegacyTesterInstallDeletionPresentation(
      occurrence: occurrence,
      phase: LegacyTesterInstallDeletionPhase.preparing,
    );
    return occurrence;
  }

  @override
  int? beginRetry({required int expectedOccurrence}) {
    if (!isCurrent(expectedOccurrence) ||
        state.phase != LegacyTesterInstallDeletionPhase.failed ||
        state.failure?.canRetry != true) {
      return null;
    }
    final occurrence = state.occurrence + 1;
    state = LegacyTesterInstallDeletionPresentation(
      occurrence: occurrence,
      phase: LegacyTesterInstallDeletionPhase.preparing,
    );
    return occurrence;
  }

  @override
  bool isCurrent(int occurrence) => state.occurrence == occurrence;

  @override
  void cancel() {
    if (state.phase != LegacyTesterInstallDeletionPhase.awaitingAuthorization) {
      return;
    }
    state = LegacyTesterInstallDeletionPresentation(
      occurrence: state.occurrence + 1,
      phase: LegacyTesterInstallDeletionPhase.cancelled,
    );
  }

  @override
  void showDeleting({required int expectedOccurrence}) {
    if (!isCurrent(expectedOccurrence)) {
      return;
    }
    state = LegacyTesterInstallDeletionPresentation(
      occurrence: expectedOccurrence,
      phase: LegacyTesterInstallDeletionPhase.deleting,
    );
  }

  @override
  void showHandoff({required int expectedOccurrence}) {
    if (!isCurrent(expectedOccurrence)) {
      return;
    }
    state = LegacyTesterInstallDeletionPresentation(
      occurrence: expectedOccurrence,
      phase: LegacyTesterInstallDeletionPhase.handingOff,
    );
  }

  @override
  void showFailure({
    required int expectedOccurrence,
    required LegacyTesterInstallDeletionFailure failure,
  }) {
    if (!isCurrent(expectedOccurrence)) {
      return;
    }
    state = LegacyTesterInstallDeletionPresentation(
      occurrence: expectedOccurrence,
      phase: LegacyTesterInstallDeletionPhase.failed,
      failure: failure,
    );
  }
}
