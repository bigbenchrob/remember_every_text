import 'package:flutter/cupertino.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../../config/theme/colors/theme_colors.dart';
import '../../../../../config/theme/theme_typography.dart';
import '../../../../../essentials/sidebar/application/sidebar_flow_state_provider.dart';
import '../resolver_tools/contact_message_scope_actions_provider.dart';

/// Segmented control that toggles between regular contact messages and
/// recovered deleted messages for the selected contact.
class ContactMessageScopeToggleWidget extends ConsumerWidget {
  const ContactMessageScopeToggleWidget({
    required this.contactId,
    required this.cassetteIndex,
    super.key,
  });

  final int contactId;
  final int cassetteIndex;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final flowState = ref.watch(sidebarFlowProvider);
    final currentScope = flowState.messageScope;
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final typography = ref.watch(themeTypographyProvider);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final segmentLabelWidth =
              ((constraints.maxWidth - _segmentedControlGap) / 2).clamp(
                0.0,
                double.infinity,
              );

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Show messages belonging to:', style: typography.caption),
              const SizedBox(height: 6),
              SizedBox(
                width: double.infinity,
                child:
                    CupertinoSlidingSegmentedControl<SidebarFlowMessageScope>(
                      thumbColor: colors.accents.primary,
                      groupValue: currentScope,
                      children: {
                        SidebarFlowMessageScope.regular: _SegmentLabel(
                          'Current chats',
                          width: segmentLabelWidth,
                          isSelected:
                              currentScope == SidebarFlowMessageScope.regular,
                          selectedColor: colors.buttons.primaryForeground,
                        ),
                        SidebarFlowMessageScope.recoveredDeleted: _SegmentLabel(
                          'Recovered pool',
                          width: segmentLabelWidth,
                          isSelected:
                              currentScope ==
                              SidebarFlowMessageScope.recoveredDeleted,
                          selectedColor: colors.buttons.primaryForeground,
                        ),
                      },
                      onValueChanged: (value) {
                        if (value == null) {
                          return;
                        }

                        ref
                            .read(contactMessageScopeActionsProvider.notifier)
                            .selectScope(
                              contactId: contactId,
                              cassetteIndex: cassetteIndex,
                              scope: switch (value) {
                                SidebarFlowMessageScope.regular =>
                                  ContactMessageScopeChoice.regular,
                                SidebarFlowMessageScope.recoveredDeleted =>
                                  ContactMessageScopeChoice.recoveredDeleted,
                              },
                            );
                      },
                    ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SegmentLabel extends StatelessWidget {
  const _SegmentLabel(
    this.text, {
    required this.width,
    required this.isSelected,
    this.selectedColor,
  });

  final String text;
  final double width;
  final bool isSelected;
  final Color? selectedColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          softWrap: false,
          textAlign: TextAlign.center,
          style: isSelected ? TextStyle(color: selectedColor) : null,
        ),
      ),
    );
  }
}

const double _segmentedControlGap = 8;
