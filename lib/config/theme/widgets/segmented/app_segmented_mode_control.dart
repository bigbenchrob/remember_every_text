import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../colors/theme_colors.dart';
import '../../theme_typography.dart';

class AppSegmentedModeControl<T extends Object> extends ConsumerWidget {
  const AppSegmentedModeControl({
    required this.options,
    required this.selectedOption,
    required this.onSelected,
    required this.labelBuilder,
    this.isOptionEnabled,
    this.labelMaxLines = 1,
    this.padding = const EdgeInsets.all(3),
    this.segmentPadding = const EdgeInsets.symmetric(
      horizontal: 8,
      vertical: 5,
    ),
    this.borderRadius = const BorderRadius.all(Radius.circular(8)),
    this.segmentBorderRadius = const BorderRadius.all(Radius.circular(6)),
    super.key,
  }) : assert(options.length > 1, 'At least two options are required.');

  final List<T> options;
  final T selectedOption;
  final ValueChanged<T> onSelected;
  final String Function(T option) labelBuilder;
  final bool Function(T option)? isOptionEnabled;
  final int labelMaxLines;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry segmentPadding;
  final BorderRadius borderRadius;
  final BorderRadius segmentBorderRadius;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surfaces.control,
        border: Border.all(color: colors.lines.borderSubtle),
        borderRadius: borderRadius,
      ),
      child: Padding(
        padding: padding,
        child: Row(
          children: [
            for (final option in options)
              Expanded(
                child: _SegmentedModeControlSegment<T>(
                  option: option,
                  label: labelBuilder(option),
                  isSelected: option == selectedOption,
                  isEnabled: isOptionEnabled?.call(option) ?? true,
                  onSelected: onSelected,
                  borderRadius: segmentBorderRadius,
                  padding: segmentPadding,
                  labelMaxLines: labelMaxLines,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SegmentedModeControlSegment<T extends Object>
    extends ConsumerStatefulWidget {
  const _SegmentedModeControlSegment({
    required this.option,
    required this.label,
    required this.isSelected,
    required this.isEnabled,
    required this.onSelected,
    required this.borderRadius,
    required this.padding,
    required this.labelMaxLines,
  });

  final T option;
  final String label;
  final bool isSelected;
  final bool isEnabled;
  final ValueChanged<T> onSelected;
  final BorderRadius borderRadius;
  final EdgeInsetsGeometry padding;
  final int labelMaxLines;

  @override
  ConsumerState<_SegmentedModeControlSegment<T>> createState() =>
      _SegmentedModeControlSegmentState<T>();
}

class _SegmentedModeControlSegmentState<T extends Object>
    extends ConsumerState<_SegmentedModeControlSegment<T>> {
  var _isHovered = false;

  @override
  Widget build(BuildContext context) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final typography = ref.watch(themeTypographyProvider);
    final isSelected = widget.isSelected;
    final backgroundColor = isSelected
        ? colors.accents.primary
        : !widget.isEnabled
        ? colors.surfaces.surface.withValues(alpha: 0)
        : _isHovered
        ? colors.surfaces.hover
        : colors.surfaces.surface.withValues(alpha: 0);
    final borderColor = isSelected
        ? colors.accents.primary
        : !widget.isEnabled
        ? colors.lines.borderSubtle.withValues(alpha: 0)
        : _isHovered
        ? colors.lines.borderSubtle
        : colors.lines.borderSubtle.withValues(alpha: 0);
    final contentColor = isSelected
        ? colors.buttons.primaryForeground
        : !widget.isEnabled
        ? colors.content.textDisabled
        : colors.content.textSecondary;

    return Semantics(
      button: true,
      enabled: widget.isEnabled,
      selected: isSelected,
      label: widget.label,
      excludeSemantics: true,
      child: MouseRegion(
        cursor: widget.isEnabled
            ? SystemMouseCursors.click
            : SystemMouseCursors.basic,
        onEnter: widget.isEnabled
            ? (_) {
                setState(() {
                  _isHovered = true;
                });
              }
            : null,
        onExit: (_) {
          if (!_isHovered) {
            return;
          }
          setState(() {
            _isHovered = false;
          });
        },
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.isEnabled
              ? () {
                  widget.onSelected(widget.option);
                }
              : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            curve: Curves.easeOutCubic,
            decoration: BoxDecoration(
              color: backgroundColor,
              border: Border.all(color: borderColor),
              borderRadius: widget.borderRadius,
            ),
            child: Padding(
              padding: widget.padding,
              child: Center(
                child: AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 120),
                  curve: Curves.easeOutCubic,
                  style: typography.caption.copyWith(
                    color: contentColor,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                  ),
                  child: Text(
                    widget.label,
                    maxLines: widget.labelMaxLines,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
