import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../../config/theme/colors/theme_colors.dart';
import '../../../../../config/theme/theme_typography.dart';
import '../../../../../essentials/sidebar/feature_level_providers.dart';

/// Segmented control that toggles between regular contact messages and
/// recovered deleted messages for the selected contact.
class ContactMessageScopeToggleWidget extends ConsumerWidget {
  const ContactMessageScopeToggleWidget({required this.contactId, super.key});

  final int contactId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final flowState = ref.watch(sidebarFlowProvider);
    final currentScope = flowState.messageScope;
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final typography = ref.watch(themeTypographyProvider);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Show messages belonging to:', style: typography.caption),
          const SizedBox(height: 6),
          SizedBox(
            width: double.infinity,
            child: CupertinoSlidingSegmentedControl<SidebarFlowMessageScope>(
              thumbColor: colors.accents.primary,
              groupValue: currentScope,
              children: {
                SidebarFlowMessageScope.regular: _SegmentLabel(
                  'Current chats',
                  isSelected: currentScope == SidebarFlowMessageScope.regular,
                  selectedColor: colors.buttons.primaryForeground,
                ),
                SidebarFlowMessageScope.recoveredDeleted: _SegmentLabel(
                  'Recovered pool',
                  isSelected:
                      currentScope == SidebarFlowMessageScope.recoveredDeleted,
                  selectedColor: colors.buttons.primaryForeground,
                ),
              },
              onValueChanged: (value) {
                if (value == null) {
                  return;
                }

                ref
                    .read(sidebarFlowProvider.notifier)
                    .setContactMessageScope(
                      contactId: contactId,
                      messageScope: value,
                    );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SegmentLabel extends StatelessWidget {
  const _SegmentLabel(
    this.text, {
    required this.isSelected,
    this.selectedColor,
  });

  final String text;
  final bool isSelected;
  final Color? selectedColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Text(
        text,
        style: isSelected ? TextStyle(color: selectedColor) : null,
      ),
    );
  }
}
