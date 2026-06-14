import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../config/theme/colors/theme_colors.dart';
import '../../../../config/theme/theme_typography.dart';
import '../../../../config/theme/widgets/theme_widgets.dart';
import '../../../navigation/domain/sidebar_mode.dart';
import '../../application/sidebar_action_dispatcher.dart';
import '../../domain/sidebar_body_model.dart';
import '../../domain/sidebar_body_option.dart';

class SidebarBodyModelContent extends ConsumerWidget {
  const SidebarBodyModelContent({
    super.key,
    required this.bodyModel,
    required this.sidebarMode,
    required this.cassetteIndex,
  });

  final SidebarBodyModel bodyModel;
  final SidebarMode sidebarMode;
  final int cassetteIndex;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return switch (bodyModel) {
      SidebarDropdownBodyModel() => _SidebarDropdownBody(
        model: bodyModel as SidebarDropdownBodyModel,
        sidebarMode: sidebarMode,
        cassetteIndex: cassetteIndex,
      ),
      _ => throw StateError(
        'Unsupported sidebar body model: ${bodyModel.runtimeType}.',
      ),
    };
  }
}

class _SidebarDropdownBody extends ConsumerWidget {
  const _SidebarDropdownBody({
    required this.model,
    required this.sidebarMode,
    required this.cassetteIndex,
  });

  final SidebarDropdownBodyModel model;
  final SidebarMode sidebarMode;
  final int cassetteIndex;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final typography = ref.watch(themeTypographyProvider);
    final dispatcher = ref.read(sidebarActionDispatcherProvider.notifier);
    final selectedOption = _selectedOption(model);
    final options = model.options.cast<SidebarDropdownOption?>();

    Future<void> handleSelection(SidebarDropdownOption? option) async {
      if (option == null || option.isDisabled) {
        return;
      }

      await dispatcher.dispatch(
        intent: option.selectionIntent,
        context: SidebarActionDispatchContext(
          sidebarMode: sidebarMode,
          cassetteIndex: cassetteIndex,
        ),
      );
    }

    return AppThemeWidgets.dropdownMenu<SidebarDropdownOption?>(
      options: options,
      selectedOption: selectedOption,
      onSelected: handleSelection,
      optionLabelBuilder: (option) => option?.label ?? '',
      leadingLabel: model.promptLabel.isEmpty ? null : model.promptLabel,
      outerPadding: EdgeInsets.zero,
      triggerPadding: const EdgeInsets.only(
        left: 12.0,
        right: 16.0,
        top: 10.0,
        bottom: 10.0,
      ),
      selectedValueStyle: typography.controlValue,
      chevronColor: colors.accents.primary,
      chevronBackgroundColor: colors.accents.primary.withValues(alpha: 0.12),
    );
  }

  SidebarDropdownOption? _selectedOption(SidebarDropdownBodyModel model) {
    final selectedOptionId = model.selectedOptionId;
    if (selectedOptionId == null) {
      return null;
    }

    for (final option in model.options) {
      if (option.id == selectedOptionId) {
        return option;
      }
    }

    return null;
  }
}
