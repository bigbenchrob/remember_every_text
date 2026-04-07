import 'package:flutter/cupertino.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../../config/theme/colors/theme_colors.dart';
import '../../../../../config/theme/spacing/app_spacing.dart';
import '../../../../../config/theme/theme_typography.dart';
import '../../../../../constants/domain/contact_constants.dart';
import '../payloads/contact_chooser_cassette_payload.dart';
import '../resolver_tools/contact_chooser_snapshot_provider.dart';
import 'contact_flat_list_widget.dart';
import 'contact_grouped_picker_widget.dart';

/// Render-edge chooser body that upgrades a loading payload using the
/// feature-owned chooser snapshot without invalidating the shared sidebar
/// coordinator.
class ContactChooserWidget extends ConsumerWidget {
  const ContactChooserWidget({super.key, required this.payload});

  final ContactChooserCassettePayload payload;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snapshot = payload.loadState == ContactChooserLoadState.loading
        ? ref.watch(contactChooserSnapshotProvider)
        : null;
    final effectiveLoadState = snapshot?.loadState ?? payload.loadState;

    return switch (effectiveLoadState) {
      ContactChooserLoadState.loading => const _ContactChooserLoadingState(),
      ContactChooserLoadState.error => const _ContactChooserErrorState(),
      ContactChooserLoadState.ready => switch (_resolveReadyPayload(
        snapshot: snapshot,
      ).pickerMode!) {
        ContactPickerMode.flat => ContactFlatListWidget(
          payload: _resolveReadyPayload(snapshot: snapshot),
        ),
        ContactPickerMode.grouped => ContactGroupedPickerWidget(
          payload: _resolveReadyPayload(snapshot: snapshot),
        ),
      },
    };
  }

  ContactChooserCassettePayload _resolveReadyPayload({
    required ContactChooserSnapshot? snapshot,
  }) {
    if (snapshot == null ||
        snapshot.loadState != ContactChooserLoadState.ready) {
      return payload;
    }

    return ContactChooserCassettePayload(
      loadState: snapshot.loadState,
      pickerMode: snapshot.pickerMode,
      pickerFilterMode: snapshot.pickerFilterMode,
      filteredSections: snapshot.filteredSections,
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
