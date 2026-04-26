import 'package:flutter/widgets.dart';

enum PanelSectionLayoutStyle {
  fullWidth,
  compactFullWidth,
  twoColumn,
  twoColumnEqualHeight,
}

final class PanelSection<T> {
  factory PanelSection({
    required PanelSectionLayoutStyle layoutStyle,
    required List<T> children,
  }) {
    final expectedChildCount = switch (layoutStyle) {
      PanelSectionLayoutStyle.fullWidth ||
      PanelSectionLayoutStyle.compactFullWidth => 1,
      PanelSectionLayoutStyle.twoColumn ||
      PanelSectionLayoutStyle.twoColumnEqualHeight => 2,
    };

    if (children.length != expectedChildCount) {
      throw ArgumentError.value(
        children.length,
        'children',
        'PanelSectionLayoutStyle.${layoutStyle.name} requires exactly '
            '$expectedChildCount '
            'child${expectedChildCount == 1 ? '' : 'ren'}.',
      );
    }

    return PanelSection._(
      layoutStyle: layoutStyle,
      children: List<T>.unmodifiable(children),
    );
  }

  const PanelSection._({required this.layoutStyle, required this.children});

  final PanelSectionLayoutStyle layoutStyle;
  final List<T> children;
}

typedef PanelSectionChildBuilder<T> =
    Widget Function(
      BuildContext context,
      PanelSectionLayoutStyle layoutStyle,
      T child,
    );

class CenterPanelReportLayout<T> extends StatelessWidget {
  const CenterPanelReportLayout({
    super.key,
    required this.sections,
    required this.childBuilder,
    this.sectionSpacing = 20,
    this.columnSpacing = 16,
  });

  final List<PanelSection<T>> sections;
  final PanelSectionChildBuilder<T> childBuilder;
  final double sectionSpacing;
  final double columnSpacing;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var index = 0; index < sections.length; index++) ...[
          if (index > 0) SizedBox(height: sectionSpacing),
          _buildSection(context, sections[index]),
        ],
      ],
    );
  }

  Widget _buildSection(BuildContext context, PanelSection<T> section) {
    return switch (section.layoutStyle) {
      PanelSectionLayoutStyle.fullWidth ||
      PanelSectionLayoutStyle.compactFullWidth => childBuilder(
        context,
        section.layoutStyle,
        section.children.single,
      ),
      PanelSectionLayoutStyle.twoColumn => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: _buildTwoColumnChildren(context, section),
      ),
      PanelSectionLayoutStyle.twoColumnEqualHeight => IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: _buildTwoColumnChildren(context, section),
        ),
      ),
    };
  }

  List<Widget> _buildTwoColumnChildren(
    BuildContext context,
    PanelSection<T> section,
  ) {
    return [
      for (var index = 0; index < section.children.length; index++) ...[
        if (index > 0) SizedBox(width: columnSpacing),
        Expanded(
          child: childBuilder(
            context,
            section.layoutStyle,
            section.children[index],
          ),
        ),
      ],
    ];
  }
}
