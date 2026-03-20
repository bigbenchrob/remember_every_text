import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../../config/theme/colors/theme_colors.dart';
import '../../../../../config/theme/theme_typography.dart';
import '../../../../../config/theme/widgets/theme_widgets.dart';
import '../../../../../essentials/sidebar/feature_level_providers.dart';
import '../../../application/services/manual_handle_link_service.dart';
import '../../../infrastructure/repositories/handles_for_contact_provider.dart';

/// Widget builder for the handle-filter cassette.
///
/// Displays a "From phone # / email:" dropdown listing every handle linked
/// to the given contact. The default "All" selection shows messages for the
/// full contact; selecting a specific handle narrows the center panel to that
/// handle's messages and exposes an "Unlink" action.
class HandleFilterWidget extends ConsumerWidget {
  const HandleFilterWidget({
    super.key,
    required this.contactId,
    required this.selectedHandleId,
    required this.cassetteIndex,
  });

  final int contactId;
  final int? selectedHandleId;
  final int cassetteIndex;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final typography = ref.watch(themeTypographyProvider);
    final handlesAsync = ref.watch(
      handlesForContactProvider(contactId: contactId),
    );

    return handlesAsync.when(
      data: (handles) {
        // If there's only one handle (or none), no filter dropdown is useful.
        if (handles.length <= 1) {
          return const SizedBox.shrink();
        }

        return _HandleFilterDropdown(
          contactId: contactId,
          handles: handles,
          selectedHandleId: selectedHandleId,
          cassetteIndex: cassetteIndex,
          colors: colors,
          typography: typography,
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

class _HandleFilterDropdown extends ConsumerWidget {
  const _HandleFilterDropdown({
    required this.contactId,
    required this.handles,
    required this.selectedHandleId,
    required this.cassetteIndex,
    required this.colors,
    required this.typography,
  });

  final int contactId;
  final List<LinkedHandle> handles;
  final int? selectedHandleId;
  final int cassetteIndex;
  final ThemeColors colors;
  final ThemeTypography typography;

  void _onHandleSelected(WidgetRef ref, int? handleId) {
    ref
        .read(sidebarFlowProvider.notifier)
        .handleSelected(
          contactId: contactId,
          handleId: handleId,
          cassetteIndex: cassetteIndex,
        );
  }

  Future<void> _onUnlink(WidgetRef ref) async {
    if (selectedHandleId == null) {
      return;
    }

    final result = await ref
        .read(manualHandleLinkServiceProvider.notifier)
        .unlinkHandle(handleId: selectedHandleId!);

    result.fold(
      (failure) {
        // Failures are unlikely here; silently ignore.
      },
      (contactDeleted) {
        // Invalidate handles list so the dropdown rebuilds.
        ref.invalidate(handlesForContactProvider(contactId: contactId));

        if (contactDeleted) {
          ref
              .read(sidebarFlowProvider.notifier)
              .chooseAnotherContact(infoCardIndex: 1);
        } else {
          // Still has other handles — reset to "All".
          _onHandleSelected(ref, null);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final options = [
      const _HandleMenuOption(handleId: null, label: 'No, show all'),
      ...handles.map(
        (handle) => _HandleMenuOption(
          handleId: handle.handleId,
          label: _handleMenuLabel(handle),
        ),
      ),
    ];
    final selectedOption = options.firstWhere(
      (option) => option.handleId == selectedHandleId,
      orElse: () => options.first,
    );

    // Find the selected handle to check if it's an override link.
    final selectedHandle = selectedHandleId != null
        ? handles.where((h) => h.handleId == selectedHandleId).firstOrNull
        : null;
    final canUnlink = selectedHandle?.isOverrideLink ?? false;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('From specific phone # or email?', style: typography.caption),
          const SizedBox(height: 6),
          AppThemeWidgets.dropdownMenu<_HandleMenuOption>(
            options: options,
            selectedOption: selectedOption,
            onSelected: (option) {
              _onHandleSelected(ref, option.handleId);
            },
            optionLabelBuilder: (option) => option.label,
            itemBuilder: (context, option, {required isSelected}) {
              return _HandleDropdownRow(
                text: option.label,
                isSelected: isSelected,
                colors: colors,
                typography: typography,
              );
            },
            equals: (a, b) => a.handleId == b.handleId,
            outerPadding: EdgeInsets.zero,
            triggerPadding: const EdgeInsets.only(
              left: 12.0,
              right: 16.0,
              top: 10.0,
              bottom: 10.0,
            ),
            selectedValueStyle: typography.controlValue,
            chevronColor: colors.dropdownMenu(DropdownMenu.chevronIcon),
            chevronBackgroundColor: colors.dropdownMenu(DropdownMenu.chevronBg),
          ),
          if (canUnlink) ...[
            const SizedBox(height: 6),
            GestureDetector(
              onTap: () => _onUnlink(ref),
              child: Text(
                'Unlink this number from contact',
                style: typography.caption1.copyWith(
                  color: colors.buttons.destructiveForeground,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

String _handleMenuLabel(LinkedHandle handle) {
  return '${handle.displayValue} (${handle.service})';
}

class _HandleMenuOption {
  const _HandleMenuOption({required this.handleId, required this.label});

  final int? handleId;
  final String label;
}

class _HandleDropdownRow extends StatelessWidget {
  const _HandleDropdownRow({
    required this.text,
    required this.isSelected,
    required this.colors,
    required this.typography,
  });

  final String text;
  final bool isSelected;
  final ThemeColors colors;
  final ThemeTypography typography;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: isSelected ? colors.dropdownMenu(DropdownMenu.selectedBg) : null,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          softWrap: false,
          style: typography.callout.copyWith(
            color: isSelected
                ? colors.dropdownMenu(DropdownMenu.selectedText)
                : colors.content.textPrimary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
