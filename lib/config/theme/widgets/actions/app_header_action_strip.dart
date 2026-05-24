import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../colors/theme_colors.dart';

/// Compact strip for header metadata and secondary actions.
class AppHeaderActionStrip extends ConsumerWidget {
  const AppHeaderActionStrip({
    required this.children,
    this.padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
    this.spacing = 8,
    this.runSpacing = 8,
    this.borderRadius = 7,
    super.key,
  });

  final List<Widget> children;
  final EdgeInsetsGeometry padding;
  final double spacing;
  final double runSpacing;
  final double borderRadius;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surfaces.surface,
        border: Border.all(color: colors.lines.borderSubtle),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Padding(
        padding: padding,
        child: Wrap(
          spacing: spacing,
          runSpacing: runSpacing,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: children,
        ),
      ),
    );
  }
}
