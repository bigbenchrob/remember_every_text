import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../essentials/debug/feature_level_providers.dart'
    show
        DeveloperModeValue,
        columnBandDebugMarginsProvider,
        developerModeProvider;

/// Diagnostic interface for vertical column alignment bands.
///
/// The page-level layout experiment uses only two fixed wrappers:
/// title identity and context. Content starts immediately after them.
abstract class VerticalColumnBand extends ConsumerWidget {
  const VerticalColumnBand({
    required this.child,
    required this.height,
    required this.padding,
    required this.borderColor,
    required this.childPlacement,
    required this.allowBandExpansion,
    this.overflowWarning = false,
    super.key,
  });

  final Widget child;
  final double height;
  final EdgeInsets padding;
  final Color borderColor;
  final ColumnBandChildPlacement childPlacement;
  final bool allowBandExpansion;
  final bool overflowWarning;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDeveloperMode =
        ref.watch(developerModeProvider).valueOrNull ==
        DeveloperModeValue.developer;
    final showDiagnosticMargins =
        isDeveloperMode && ref.watch(columnBandDebugMarginsProvider);

    return DecoratedBox(
      decoration: BoxDecoration(
        border: showDiagnosticMargins
            ? Border.all(
                color: overflowWarning ? const Color(0xFFFFA000) : borderColor,
              )
            : null,
      ),
      child: allowBandExpansion
          ? ConstrainedBox(
              constraints: BoxConstraints(minHeight: height),
              child: Padding(
                padding: padding,
                child: Align(alignment: childPlacement.alignment, child: child),
              ),
            )
          : SizedBox(
              height: height,
              child: Padding(
                padding: padding,
                child: Align(alignment: childPlacement.alignment, child: child),
              ),
            ),
    );
  }
}

class ColumnBandChildPlacement {
  const ColumnBandChildPlacement._(this.alignment);

  const ColumnBandChildPlacement.topLeft() : this._(Alignment.topLeft);

  const ColumnBandChildPlacement.centerLeft() : this._(Alignment.centerLeft);

  const ColumnBandChildPlacement.bottomLeft() : this._(Alignment.bottomLeft);

  ColumnBandChildPlacement.custom({required double x, required double y})
    : alignment = Alignment(x, y);

  final AlignmentGeometry alignment;
}

class TitleColumnBand extends VerticalColumnBand {
  const TitleColumnBand({
    required super.child,
    super.height = 72,
    super.padding = const EdgeInsets.fromLTRB(32, 24, 32, 0),
    super.borderColor = const Color(0xFFFF2D2D),
    super.childPlacement = const ColumnBandChildPlacement.topLeft(),
    super.allowBandExpansion = true,
    super.overflowWarning = false,
    super.key,
  });
}

class ContextColumnBand extends VerticalColumnBand {
  const ContextColumnBand({
    required super.child,
    super.height = 166,
    super.padding = const EdgeInsets.fromLTRB(32, 10, 32, 0),
    super.borderColor = const Color(0xFF006CFF),
    super.childPlacement = const ColumnBandChildPlacement.topLeft(),
    super.allowBandExpansion = false,
    super.overflowWarning = false,
    super.key,
  });
}
