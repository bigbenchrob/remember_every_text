import 'package:flutter/scheduler.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../logging/feature_level_providers.dart' show appLoggerProvider;
import '../../navigation/application/app_navigator_key.dart';
import '../presentation/start_fresh_authorization_dialog.dart';
import 'advanced_start_fresh_action.dart';
import 'advanced_start_fresh_presentation_provider.dart';
import 'message_lens_installation_state_provider.dart';
import 'start_fresh_service_provider.dart';

part 'advanced_start_fresh_action_provider.g.dart';

@Riverpod(keepAlive: true)
AdvancedStartFreshAction advancedStartFreshAction(Ref ref) {
  return AdvancedStartFreshActionImpl(
    readInstallationState: () {
      ref.invalidate(messageLensInstallationStateProvider);
      return ref.read(messageLensInstallationStateProvider.future);
    },
    requestAuthorization: () async {
      final context = appNavigatorKey.currentContext;
      if (context == null || !context.mounted) {
        throw StateError(
          'Start Fresh authorization requires an active navigator context.',
        );
      }
      return showStartFreshAuthorizationDialog(context);
    },
    readStartFreshService: () {
      return ref.read(startFreshServiceProvider.future);
    },
    presentation: ref.read(
      advancedStartFreshPresentationControllerProvider.notifier,
    ),
    waitForPresentationFrame: () => SchedulerBinding.instance.endOfFrame,
    reportFailure: (error, stackTrace) {
      ref
          .read(appLoggerProvider.notifier)
          .error(
            'Advanced Start Fresh failed: $error',
            source: 'AdvancedStartFresh',
            context: {'stack': stackTrace.toString()},
          );
    },
  );
}
