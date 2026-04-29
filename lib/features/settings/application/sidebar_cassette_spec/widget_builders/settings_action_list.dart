import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../../config/theme/colors/theme_colors.dart';
import '../../../../../config/theme/theme_typography.dart';
import '../../../../../essentials/navigation/domain/sidebar_mode.dart';
import '../../../../../essentials/sidebar/application/sidebar_action_dispatcher.dart';
import '../../../../../essentials/sidebar/domain/sidebar_action_intent.dart';

class SettingsActionList extends ConsumerStatefulWidget {
  const SettingsActionList({
    super.key,
    required this.actions,
    required this.cassetteIndex,
  });

  final List<SidebarActionDescriptor> actions;
  final int cassetteIndex;

  @override
  ConsumerState<SettingsActionList> createState() => _SettingsActionListState();
}

class _SettingsActionListState extends ConsumerState<SettingsActionList> {
  int? _hoveredIndex;
  int? _pendingIndex;

  @override
  Widget build(BuildContext context) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final typography = ref.watch(themeTypographyProvider);
    final dispatcher = ref.read(sidebarActionDispatcherProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var index = 0; index < widget.actions.length; index++) ...[
          MouseRegion(
            cursor: _isInteractable(widget.actions[index])
                ? SystemMouseCursors.click
                : SystemMouseCursors.basic,
            onEnter: (_) {
              if (!_isInteractable(widget.actions[index])) {
                return;
              }
              setState(() {
                _hoveredIndex = index;
              });
            },
            onExit: (_) {
              if (_hoveredIndex != index) {
                return;
              }
              setState(() {
                _hoveredIndex = null;
              });
            },
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () async {
                final action = widget.actions[index];
                if (!_isInteractable(action)) {
                  return;
                }

                setState(() {
                  _pendingIndex = index;
                  _hoveredIndex = null;
                });

                try {
                  await dispatcher.dispatch(
                    intent: action.intent,
                    context: SidebarActionDispatchContext(
                      sidebarMode: SidebarMode.settings,
                      cassetteIndex: widget.cassetteIndex,
                    ),
                  );
                } finally {
                  if (!mounted) {
                    return;
                  }

                  setState(() {
                    _pendingIndex = null;
                  });
                }
              },
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: _actionBackgroundColor(colors: colors, index: index),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Text(
                    _actionLabel(widget.actions[index], index),
                    style: typography.controlValue.copyWith(
                      color: _actionColor(
                        colors: colors,
                        action: widget.actions[index],
                        isPending: _pendingIndex == index,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (index < widget.actions.length - 1)
            SizedBox(
              height: 0.5,
              child: ColoredBox(color: colors.lines.borderSubtle),
            ),
        ],
      ],
    );
  }

  Color _actionColor({
    required ThemeColors colors,
    required SidebarActionDescriptor action,
    required bool isPending,
  }) {
    if (!action.isEnabled) {
      return colors.content.textDisabled;
    }

    if (_pendingIndex != null && !isPending) {
      return colors.content.textDisabled;
    }

    return switch (action.tone) {
      SidebarActionTone.neutral => colors.content.textPrimary,
      SidebarActionTone.primary => colors.accents.primary,
      SidebarActionTone.destructive => colors.buttons.destructiveForeground,
    };
  }

  bool _isInteractable(SidebarActionDescriptor action) {
    return action.isEnabled && _pendingIndex == null;
  }

  Color _actionBackgroundColor({
    required ThemeColors colors,
    required int index,
  }) {
    if (_pendingIndex == index) {
      return colors.surfaces.pressed;
    }

    if (_hoveredIndex == index) {
      return colors.surfaces.hover;
    }

    return const Color(0x00000000);
  }

  String _actionLabel(SidebarActionDescriptor action, int index) {
    if (_pendingIndex == index) {
      return '${action.label} (working...)';
    }

    return action.label;
  }
}
