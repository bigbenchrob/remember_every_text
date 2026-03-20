import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:macos_ui/macos_ui.dart';

import '../../../../../config/theme/colors/theme_colors.dart';
import '../../../../../config/theme/spacing/app_spacing.dart';
import '../../../../../config/theme/theme_typography.dart';
import '../../../../../essentials/db/feature_level_providers.dart';
import '../../../../../essentials/sidebar/feature_level_providers.dart';
import '../../../../messages/feature_level_providers.dart' as messages_feature;
import '../../../infrastructure/repositories/contact_profile_provider.dart';
import '../../../infrastructure/repositories/contacts_list_repository.dart';
import '../../../infrastructure/repositories/recent_contacts_repository.dart';
import '../../../presentation/widgets/contact_initial_badge.dart';
import '../../../presentation/widgets/picker_filter_toggle.dart';
import '../resolver_tools/favorite_contacts_provider.dart';
import '../resolver_tools/picker_filter_mode_provider.dart';

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
/// - Construct specs only on user interaction (output, not interpretation)
/// - Never make branching decisions about which UI to show
class ContactFlatListWidget extends HookConsumerWidget {
  const ContactFlatListWidget({
    super.key,
    required this.chosenContactId,
    required this.cassetteIndex,
  });

  /// Currently selected contact ID, if any.
  final int? chosenContactId;

  /// Position in the cassette rack (for updates via replaceAtIndexAndCascade).
  final int cassetteIndex;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    useEffect(() {
      unawaited(ref.read(driftWorkingDatabaseProvider.future));
      unawaited(ref.read(overlayDatabaseProvider.future));
      return null;
    }, const []);

    final filterMode = ref.watch(pickerFilterProvider);
    final contactsAsync = ref.watch(contactsListRepositoryProvider);
    final favoritesAsync = ref.watch(favoriteContactsProvider);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const PickerFilterToggle(),
        contactsAsync.when(
          data: (contacts) {
            final favoriteIds =
                favoritesAsync.valueOrNull
                    ?.map((f) => f.contact.participantId)
                    .toSet() ??
                <int>{};

            final displayContacts = switch (filterMode) {
              PickerFilterMode.all => contacts,
              PickerFilterMode.favouritesOnly =>
                contacts
                    .where((c) => favoriteIds.contains(c.participantId))
                    .toList(growable: false),
            };

            if (displayContacts.isEmpty) {
              return const _EmptyState();
            }

            ref.watch(themeColorsProvider);
            final colors = ref.read(themeColorsProvider.notifier);
            final typography = ref.watch(themeTypographyProvider);

            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: displayContacts.map((contact) {
                  final isSelected = contact.participantId == chosenContactId;

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
            );
          },
          loading: () => const Center(child: ProgressCircle()),
          error: (error, _) => Center(
            child: Text(
              'Error loading contacts: $error',
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _handleContactSelection(WidgetRef ref, int contactId) async {
    final infoCardIndex = cassetteIndex - 1;
    _prewarmContactInvestigation(ref, contactId);
    ref
        .read(sidebarFlowProvider.notifier)
        .contactChosen(contactId: contactId, infoCardIndex: infoCardIndex);

    // Track contact as recently accessed (persists to overlay.db)
    final overlayDb = await ref.read(overlayDatabaseProvider.future);
    await overlayDb.trackContactAccess(contactId);
    ref.invalidate(recentContactsProvider);
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
