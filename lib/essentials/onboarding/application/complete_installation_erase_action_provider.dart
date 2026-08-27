import 'package:flutter/scheduler.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../config/theme/colors/theme_colors.dart';
import '../../navigation/application/app_navigator_key.dart';
import '../domain/complete_installation_erase_presentation.dart';
import '../domain/message_lens_installation_state.dart';
import '../presentation/complete_installation_erase_authorization_dialog.dart';
import 'complete_installation_erase_service_provider.dart';
import 'message_lens_installation_state_provider.dart';

part 'complete_installation_erase_action_provider.g.dart';

@Riverpod(keepAlive: true)
class CompleteInstallationEraseAction
    extends _$CompleteInstallationEraseAction {
  @override
  CompleteInstallationErasePresentation build() {
    return const CompleteInstallationErasePresentation.idle();
  }

  Future<bool> request({bool eraseOnlyAdmission = false}) async {
    if (!eraseOnlyAdmission) {
      final installation = await ref.read(
        messageLensInstallationStateProvider.future,
      );
      if (installation.kind != MessageLensInstallationStateKind.completed) {
        throw StateError(
          'Complete erase from Settings requires a completed installation.',
        );
      }
    }

    final context = appNavigatorKey.currentContext;
    if (context == null || !context.mounted) {
      throw StateError(
        'Complete erase authorization requires an active navigator context.',
      );
    }
    final colors = ref.read(themeColorsProvider.notifier);
    if (!await showCompleteInstallationEraseAuthorizationDialog(
      context,
      barrierColor: colors.surfaces.canvas,
    )) {
      return false;
    }

    final occurrence = state.occurrence + 1;
    state = CompleteInstallationErasePresentation(
      occurrence: occurrence,
      phase: CompleteInstallationErasePhase.preparing,
    );
    await SchedulerBinding.instance.endOfFrame;
    if (state.occurrence != occurrence) {
      return false;
    }
    state = CompleteInstallationErasePresentation(
      occurrence: occurrence,
      phase: CompleteInstallationErasePhase.erasing,
    );
    try {
      await ref
          .read(completeInstallationEraseServiceProvider)
          .eraseAndRelaunch();
      return true;
    } catch (error) {
      if (state.occurrence == occurrence) {
        state = CompleteInstallationErasePresentation(
          occurrence: occurrence,
          phase: CompleteInstallationErasePhase.failed,
          failureSummary:
              'MessageLens could not safely erase this setup. No external '
              'Messages, Contacts, archive source, or recovery donor was '
              'targeted. Failure category: ${error.runtimeType}.',
        );
      }
      return false;
    }
  }

  void dismissFailure({required int occurrence}) {
    if (state.occurrence == occurrence &&
        state.phase == CompleteInstallationErasePhase.failed) {
      state = CompleteInstallationErasePresentation(
        occurrence: occurrence,
        phase: CompleteInstallationErasePhase.idle,
      );
    }
  }
}
