import 'package:flutter/cupertino.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../../config/theme/colors/theme_colors.dart';
import '../../../../../config/theme/spacing/app_spacing.dart';
import '../../../../../config/theme/theme_typography.dart';
import '../../../../../constants/domain/contact_constants.dart';
import '../../../infrastructure/repositories/contacts_list_repository.dart';
import '../payloads/contact_chooser_cassette_payload.dart';
import '../resolver_tools/filtered_picker_sections_provider.dart';
import '../resolver_tools/picker_filter_mode_provider.dart';
import '../resolver_tools/picker_mode_decision.dart';
import 'contact_flat_list_widget.dart';
import 'contact_grouped_picker_widget.dart';

/// Render-edge chooser body that resolves contact data without blocking the
/// entire sidebar coordinator during startup.
class ContactChooserWidget extends ConsumerWidget {
  const ContactChooserWidget({super.key, required this.payload});

  final ContactChooserCassettePayload payload;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contactsAsync = ref.watch(contactsListRepositoryProvider);
    final pickerFilterMode = ref.watch(pickerFilterProvider);
    final filteredSectionsAsync = ref.watch(filteredPickerSectionsProvider);

    if (contactsAsync.isLoading || filteredSectionsAsync.isLoading) {
      return const _ContactChooserLoadingState();
    }

    if (contactsAsync.hasError || filteredSectionsAsync.hasError) {
      return const _ContactChooserErrorState();
    }

    final contacts = contactsAsync.requireValue;
    final filteredSections = filteredSectionsAsync.requireValue;
    final resolvedPayload = ContactChooserCassettePayload(
      pickerMode: determinePickerMode(contacts.length),
      pickerFilterMode: pickerFilterMode,
      filteredSections: filteredSections,
      chosenContactId: payload.chosenContactId,
      cassetteIndex: payload.cassetteIndex,
      title: payload.title,
      subtitle: payload.subtitle,
      sectionTitle: payload.sectionTitle,
      footerText: payload.footerText,
      placementMode: payload.placementMode,
      contentAlignment: payload.contentAlignment,
      layoutStyle: payload.layoutStyle,
      isNaked: payload.isNaked,
      shouldExpand: payload.shouldExpand,
      role: payload.role,
      topSpacing: payload.topSpacing,
    );

    return switch (resolvedPayload.pickerMode!) {
      ContactPickerMode.flat => ContactFlatListWidget(payload: resolvedPayload),
      ContactPickerMode.grouped => ContactGroupedPickerWidget(
        payload: resolvedPayload,
      ),
    };
  }
}

class _ContactChooserLoadingState extends StatelessWidget {
  const _ContactChooserLoadingState();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
      child: Center(child: CupertinoActivityIndicator()),
    );
  }
}

class _ContactChooserErrorState extends ConsumerWidget {
  const _ContactChooserErrorState();

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
      child: Text(
        'Unable to load contacts right now.',
        style: typography.body.copyWith(color: colors.content.textTertiary),
      ),
    );
  }
}
