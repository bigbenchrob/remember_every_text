import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../config/theme/colors/theme_colors.dart';
import '../../../../config/theme/theme_typography.dart';
import '../../application/sidebar_cassette_sectioning.dart';

class SidebarMenuSectionHeader extends ConsumerWidget {
  const SidebarMenuSectionHeader({
    super.key,
    required this.label,
    required this.isFirstInMenu,
  });

  final String label;
  final bool isFirstInMenu;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final typography = ref.watch(themeTypographyProvider);

    return Padding(
      padding: EdgeInsets.only(
        left: sidebarMenuSectionHeaderHorizontalInset,
        right: sidebarMenuSectionHeaderHorizontalInset,
        top: sidebarMenuSectionHeaderTopSpacing(isFirstInMenu: isFirstInMenu),
        bottom: sidebarMenuSectionHeaderBottomSpacing(),
      ),
      child: Text(
        label,
        style: typography.pickerSectionLabel.copyWith(
          fontSize: (typography.pickerSectionLabel.fontSize ?? 10) + 1,
          fontWeight: FontWeight.w500,
          color: colors.content.textTertiary.withValues(
            alpha: colors.isDark ? 0.82 : 0.72,
          ),
        ),
      ),
    );
  }
}
