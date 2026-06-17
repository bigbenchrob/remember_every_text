import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../../config/theme/colors/theme_colors.dart';
import '../../../../../config/theme/spacing/app_spacing.dart';
import '../../../../../config/theme/theme_typography.dart';
import '../../../../../essentials/navigation/domain/sidebar_mode.dart';
import '../../../../../essentials/sidebar/domain/sidebar_action_intent.dart';
import '../../../../../essentials/sidebar/feature_level_providers.dart';
import '../../../../messages/feature_level_providers.dart' as messages_feature;
import '../../../feature_level_providers.dart';
import '../../../presentation/widgets/contact_initial_badge.dart';
import '../../../presentation/widgets/picker_filter_toggle.dart';
import '../payloads/contact_chooser_cassette_payload.dart';

/// Widget builder for the flat contact list display.
///
/// This widget builder assembles a simple scrollable list of contacts
/// for use when the contact count is below the grouping threshold.
///
/// ## Contract (from 00-cross-surface-spec-system.md)
///
/// Widget builders:
/// - Accept fully-decided inputs (not specs)
/// - May use `ref.watch()` for reactive updates
/// - Dispatch semantic actions on user interaction; do not construct panel specs
/// - Never make branching decisions about which UI to show
class ContactFlatListWidget extends HookConsumerWidget {
  const ContactFlatListWidget({super.key, required this.payload});

  final ContactChooserCassettePayload payload;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredSections = payload.filteredSections!;
    final pickerFilterMode = payload.pickerFilterMode!;
    final displayContacts = filteredSections.sections
        .expand((section) => section.contacts)
        .toList(growable: false);

    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final typography = ref.watch(themeTypographyProvider);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        PickerFilterToggle(mode: pickerFilterMode),
        if (displayContacts.isEmpty)
          const _EmptyState()
        else
          SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: displayContacts.map((contact) {
                final isSelected =
                    contact.participantId == payload.chosenContactId;

                return _ContactRow(
                  displayName: contact.displayName,
                  isSelected: isSelected,
                  onHoverStart: () {
                    _prewarmContactInvestigation(ref, contact.participantId);
                  },
                  onTap: () =>
                      _handleContactSelection(ref, contact.participantId),
                  colors: colors,
                  typography: typography,
                );
              }).toList(),
            ),
          ),
      ],
    );
  }

  Future<void> _handleContactSelection(WidgetRef ref, int contactId) async {
    _prewarmContactInvestigation(ref, contactId);
    ref
        .read(sidebarActionDispatcherProvider.notifier)
        .dispatch(
          intent: ContactChosen(contactId: contactId),
          context: SidebarActionDispatchContext(
            sidebarMode: SidebarMode.messages,
            cassetteIndex: payload.cassetteIndex,
          ),
        );
  }

  void _prewarmContactInvestigation(WidgetRef ref, int contactId) {
    unawaited(ref.read(contactProfileProvider(contactId: contactId).future));
    unawaited(
      ref.read(
        messages_feature
            .prewarmContactMessagesProvider(contactId: contactId)
            .future,
      ),
    );
  }
}

class _EmptyState extends ConsumerWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final typography = ref.watch(themeTypographyProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.md,
      ),
      child: Center(
        child: Text(
          'No contacts available',
          style: typography.body.copyWith(color: colors.content.textTertiary),
        ),
      ),
    );
  }
}

class _ContactRow extends StatelessWidget {
  const _ContactRow({
    required this.displayName,
    required this.isSelected,
    required this.onHoverStart,
    required this.onTap,
    required this.colors,
    required this.typography,
  });

  final String displayName;
  final bool isSelected;
  final VoidCallback onHoverStart;
  final VoidCallback onTap;
  final ThemeColors colors;
  final ThemeTypography typography;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) {
        onHoverStart();
      },
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? colors.accents.primary.withValues(alpha: 0.12)
                : Colors.transparent,
            border: Border(
              bottom: BorderSide(color: colors.lines.borderSubtle, width: 0.5),
            ),
          ),
          child: Row(
            children: [
              ContactInitialBadge(displayName: displayName),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  displayName,
                  style: typography.body.copyWith(
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (isSelected) ...[
                const SizedBox(width: 8),
                Icon(
                  CupertinoIcons.checkmark_alt,
                  size: 14,
                  color: colors.accents.primary,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
