import 'package:flutter/cupertino.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../../config/theme/colors/theme_colors.dart';
import '../../../../../config/theme/spacing/app_spacing.dart';
import '../../../../../config/theme/theme_typography.dart';
import '../../../../../constants/domain/contact_constants.dart';
import '../payloads/contact_chooser_cassette_payload.dart';
import 'contact_flat_list_widget.dart';
import 'contact_grouped_picker_widget.dart';

/// Render-edge chooser body built directly from the inert chooser payload.
class ContactChooserWidget extends StatelessWidget {
  const ContactChooserWidget({super.key, required this.payload});

  final ContactChooserCassettePayload payload;

  @override
  Widget build(BuildContext context) {
    return switch (payload.loadState) {
      ContactChooserLoadState.loading => const _ContactChooserLoadingState(),
      ContactChooserLoadState.error => const _ContactChooserErrorState(),
      ContactChooserLoadState.ready => switch (payload.pickerMode!) {
        ContactPickerMode.flat => ContactFlatListWidget(payload: payload),
        ContactPickerMode.grouped => ContactGroupedPickerWidget(
          payload: payload,
        ),
      },
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
