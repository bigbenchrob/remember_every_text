import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:macos_ui/macos_ui.dart';

import '../../../../../config/theme/spacing/app_spacing.dart';
import '../../../../../config/theme/theme_typography.dart';
import '../../../../../essentials/navigation/domain/entities/view_spec.dart';
import '../../../../../essentials/navigation/domain/navigation_constants.dart';
import '../../../../../essentials/navigation/domain/sidebar_mode.dart';
import '../../../../../essentials/navigation/feature_level_providers.dart';
import '../../../../../essentials/sidebar/application/cassette_rack_state_provider.dart';
import '../../../../../essentials/sidebar/domain/entities/cassette_spec.dart';
import '../../../../sidebar_utilities/domain/sidebar_utilities_constants.dart';
import '../../../domain/spec_classes/messages_view_spec.dart';

/// Sidebar cassette content for the no-handle/from-me recovered bucket.
class RecoveredNoHandleFromMeNavigatorWidget extends HookConsumerWidget {
  const RecoveredNoHandleFromMeNavigatorWidget({
    required this.cassetteIndex,
    super.key,
  });

  final int cassetteIndex;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final typography = ref.watch(themeTypographyProvider);

    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final rack = ref.read(cassetteRackStateProvider(SidebarMode.messages));
        final topChoice = _currentTopMenuChoice(rack);
        if (topChoice != TopChatMenuChoice.recoveredNoHandleFromMeMessages) {
          return;
        }

        ref
            .read(panelsViewStateProvider(SidebarMode.messages).notifier)
            .show(
              panel: WindowPanel.center,
              spec: const ViewSpec.messages(
                MessagesSpec.recoveredNoHandleFromMeMessages(),
              ),
            );
      });

      return null;
    }, const []);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Experimental slice of recovered orphaned records that are mostly outgoing and no longer retain handle linkage. Useful for inspecting the large no-handle bucket separately from the rest of recovered messages.',
          style: typography.cassetteCardSubtitle,
        ),
        const SizedBox(height: AppSpacing.sm),
        PushButton(
          controlSize: ControlSize.small,
          onPressed: () {
            ref
                .read(panelsViewStateProvider(SidebarMode.messages).notifier)
                .show(
                  panel: WindowPanel.center,
                  spec: const ViewSpec.messages(
                    MessagesSpec.recoveredNoHandleFromMeMessages(),
                  ),
                );
          },
          child: Text(
            'Open Recovered No-Handle Messages',
            style: typography.body.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}

TopChatMenuChoice? _currentTopMenuChoice(CassetteRack rack) {
  if (rack.cassettes.isEmpty) {
    return null;
  }

  return rack.cassettes.first.mapOrNull(
    sidebarUtility: (cassette) {
      final selectedChoice = cassette.spec.selectedChoice;
      if (selectedChoice is TopChatMenuChoice) {
        return selectedChoice;
      }

      return null;
    },
  );
}
