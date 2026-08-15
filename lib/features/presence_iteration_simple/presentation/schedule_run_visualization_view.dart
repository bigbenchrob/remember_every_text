import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../config/theme/colors/theme_colors.dart';
import '../../../config/theme/theme_typography.dart';
import '../application/presence_run_visualization.dart';
import '../infrastructure/development/schedule_topology_projection.dart';

class ScheduleRunVisualizationView extends ConsumerWidget {
  const ScheduleRunVisualizationView({required this.visualization, super.key});

  final PresenceRunVisualization visualization;

  static const double _nodeSpacing = 84;
  static const double _nodeDiameter = 48;
  static const double _mapHeight = 168;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final typography = ref.watch(themeTypographyProvider);
    final topology = visualization.topology;
    final mapWidth = math.max(
      600.0,
      (topology.trips.length + 1) * _nodeSpacing,
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(
          visualization.isComplete
              ? 'Schedule complete'
              : 'Current: Trip ${_currentTripNumber(topology)}',
          style: typography.headline,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        _Legend(
          neverVisitedColor: colors.surfaces.control,
          visitedColor: colors.surfaces.selected,
          currentColor: colors.status.warning.withValues(alpha: 0.18),
          textColor: colors.content.textSecondary,
          textStyle: typography.caption,
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: mapWidth,
            height: _mapHeight,
            child: Stack(
              children: <Widget>[
                CustomPaint(
                  size: Size(mapWidth, _mapHeight),
                  painter: _ScheduleRoutePainter(
                    visualization: visualization,
                    possibleColor: colors.lines.border,
                    traversedColor: colors.accents.primary,
                    countStyle: typography.caption.copyWith(fontSize: 10),
                  ),
                ),
                for (var index = 0; index < topology.trips.length; index += 1)
                  _positionedTrip(
                    trip: topology.trips[index],
                    index: index,
                    colors: colors,
                    typography: typography,
                  ),
                _positionedCompletion(
                  index: topology.trips.length,
                  colors: colors,
                  typography: typography,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 14,
          runSpacing: 6,
          children: topology.edges
              .map(
                (edge) => _RouteLabel(
                  source: _tripNumber(topology, edge.sourceTripOccurrenceId),
                  destination: edge.destinationTripOccurrenceId == null
                      ? 'complete'
                      : _tripNumber(
                          topology,
                          edge.destinationTripOccurrenceId!,
                        ),
                  label: edge.label,
                  traversalCount: visualization.traversalCountFor(edge),
                  possibleColor: colors.lines.border,
                  traversedColor: colors.accents.primary,
                  textStyle: typography.caption,
                ),
              )
              .toList(growable: false),
        ),
      ],
    );
  }

  Widget _positionedTrip({
    required ScheduleTopologyTrip trip,
    required int index,
    required ThemeColors colors,
    required ThemeTypography typography,
  }) {
    final visitCount = visualization.visitCountFor(trip.occurrenceId);
    final isCurrent =
        visualization.currentTripOccurrenceId == trip.occurrenceId;
    final fill = isCurrent
        ? colors.status.warning.withValues(alpha: 0.18)
        : visitCount > 0
        ? colors.surfaces.selected
        : colors.surfaces.control;
    final border = isCurrent
        ? colors.status.warning
        : visitCount > 0
        ? colors.accents.primary
        : colors.lines.border;
    return Positioned(
      left: _nodeCenterX(index) - 40,
      top: 40,
      width: 80,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          SizedBox.square(
            dimension: _nodeDiameter,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: fill,
                shape: BoxShape.circle,
                border: Border.all(color: border, width: isCurrent ? 3 : 1.5),
              ),
              child: Center(
                child: Text(
                  '${trip.tripDefinitionId.value}',
                  style: typography.body.copyWith(
                    color: colors.content.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            trip.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: typography.caption,
          ),
          if (visitCount > 0)
            Text(
              'visited ×$visitCount',
              style: typography.caption.copyWith(
                color: colors.content.textSecondary,
              ),
            ),
        ],
      ),
    );
  }

  Widget _positionedCompletion({
    required int index,
    required ThemeColors colors,
    required ThemeTypography typography,
  }) {
    final completionCount = visualization.topology.edges
        .where((edge) => edge.destinationTripOccurrenceId == null)
        .fold<int>(
          0,
          (sum, edge) => sum + visualization.traversalCountFor(edge),
        );
    return Positioned(
      left: _nodeCenterX(index) - 40,
      top: 40,
      width: 80,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          SizedBox.square(
            dimension: _nodeDiameter,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: completionCount > 0
                    ? colors.status.success.withValues(alpha: 0.16)
                    : colors.surfaces.control,
                shape: BoxShape.circle,
                border: Border.all(
                  color: completionCount > 0
                      ? colors.status.success
                      : colors.lines.border,
                  width: completionCount > 0 ? 2 : 1.5,
                ),
              ),
              child: Center(
                child: Text(
                  'Done',
                  style: typography.caption.copyWith(
                    color: colors.content.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text('Complete', style: typography.caption),
        ],
      ),
    );
  }

  String _currentTripNumber(ScheduleTopologyProjection topology) {
    return _tripNumber(topology, visualization.currentTripOccurrenceId!);
  }

  String _tripNumber(ScheduleTopologyProjection topology, int occurrenceId) {
    return topology.trips
        .singleWhere((trip) => trip.occurrenceId == occurrenceId)
        .tripDefinitionId
        .value
        .toString();
  }

  static double _nodeCenterX(int index) => 42 + (index * _nodeSpacing);
}

class _Legend extends StatelessWidget {
  const _Legend({
    required this.neverVisitedColor,
    required this.visitedColor,
    required this.currentColor,
    required this.textColor,
    required this.textStyle,
  });

  final Color neverVisitedColor;
  final Color visitedColor;
  final Color currentColor;
  final Color textColor;
  final TextStyle textStyle;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 16,
      runSpacing: 6,
      children: <Widget>[
        _LegendItem(
          color: neverVisitedColor,
          textColor: textColor,
          textStyle: textStyle,
          label: 'Not visited',
        ),
        _LegendItem(
          color: visitedColor,
          textColor: textColor,
          textStyle: textStyle,
          label: 'Visited',
        ),
        _LegendItem(
          color: currentColor,
          textColor: textColor,
          textStyle: textStyle,
          label: 'Current',
        ),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({
    required this.color,
    required this.textColor,
    required this.textStyle,
    required this.label,
  });

  final Color color;
  final Color textColor;
  final TextStyle textStyle;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        SizedBox.square(
          dimension: 10,
          child: DecoratedBox(
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
        ),
        const SizedBox(width: 5),
        Text(label, style: textStyle.copyWith(color: textColor)),
      ],
    );
  }
}

class _RouteLabel extends StatelessWidget {
  const _RouteLabel({
    required this.source,
    required this.destination,
    required this.label,
    required this.traversalCount,
    required this.possibleColor,
    required this.traversedColor,
    required this.textStyle,
  });

  final String source;
  final String destination;
  final String label;
  final int traversalCount;
  final Color possibleColor;
  final Color traversedColor;
  final TextStyle textStyle;

  @override
  Widget build(BuildContext context) {
    final traversed = traversalCount > 0;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        SizedBox(
          width: 14,
          height: traversed ? 3 : 1.5,
          child: ColoredBox(color: traversed ? traversedColor : possibleColor),
        ),
        const SizedBox(width: 5),
        Text(
          '$source → $destination · $label'
          '${traversalCount > 1 ? ' ×$traversalCount' : ''}',
          style: textStyle,
        ),
      ],
    );
  }
}

final class _ScheduleRoutePainter extends CustomPainter {
  const _ScheduleRoutePainter({
    required this.visualization,
    required this.possibleColor,
    required this.traversedColor,
    required this.countStyle,
  });

  final PresenceRunVisualization visualization;
  final Color possibleColor;
  final Color traversedColor;
  final TextStyle countStyle;

  @override
  void paint(Canvas canvas, Size size) {
    final topology = visualization.topology;
    final indexByOccurrence = <int, int>{
      for (var index = 0; index < topology.trips.length; index += 1)
        topology.trips[index].occurrenceId: index,
    };
    for (final edge in topology.edges) {
      final sourceIndex = indexByOccurrence[edge.sourceTripOccurrenceId]!;
      final destinationIndex = edge.destinationTripOccurrenceId == null
          ? topology.trips.length
          : indexByOccurrence[edge.destinationTripOccurrenceId]!;
      final traversalCount = visualization.traversalCountFor(edge);
      _paintEdge(
        canvas: canvas,
        sourceIndex: sourceIndex,
        destinationIndex: destinationIndex,
        traversalCount: traversalCount,
      );
    }
  }

  void _paintEdge({
    required Canvas canvas,
    required int sourceIndex,
    required int destinationIndex,
    required int traversalCount,
  }) {
    const centerY = 64.0;
    final sourceX = ScheduleRunVisualizationView._nodeCenterX(sourceIndex);
    final destinationX = ScheduleRunVisualizationView._nodeCenterX(
      destinationIndex,
    );
    final direction = destinationX >= sourceX ? 1.0 : -1.0;
    final start = Offset(
      sourceX + (direction * ScheduleRunVisualizationView._nodeDiameter / 2),
      centerY,
    );
    final end = Offset(
      destinationX -
          (direction * ScheduleRunVisualizationView._nodeDiameter / 2),
      centerY,
    );
    final distance = (destinationIndex - sourceIndex).abs();
    final path = Path()..moveTo(start.dx, start.dy);
    Offset tangentStart;
    if (distance <= 1) {
      path.lineTo(end.dx, end.dy);
      tangentStart = start;
    } else {
      final arc = math.min(48.0, 18 + (distance * 7));
      final control = Offset(
        (start.dx + end.dx) / 2,
        centerY + (direction > 0 ? -arc : arc),
      );
      path.quadraticBezierTo(control.dx, control.dy, end.dx, end.dy);
      tangentStart = control;
    }
    final paint = Paint()
      ..color = traversalCount > 0 ? traversedColor : possibleColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = traversalCount > 0 ? 3 : 1.5;
    canvas.drawPath(path, paint);
    _paintArrow(canvas, from: tangentStart, to: end, paint: paint);

    if (traversalCount > 1) {
      final countPainter = TextPainter(
        text: TextSpan(text: '×$traversalCount', style: countStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      countPainter.paint(
        canvas,
        Offset(
          ((start.dx + end.dx) / 2) - (countPainter.width / 2),
          direction > 0 ? 4 : 112,
        ),
      );
    }
  }

  void _paintArrow(
    Canvas canvas, {
    required Offset from,
    required Offset to,
    required Paint paint,
  }) {
    final angle = math.atan2(to.dy - from.dy, to.dx - from.dx);
    const arrowLength = 7.0;
    const spread = 0.55;
    final arrow = Path()
      ..moveTo(to.dx, to.dy)
      ..lineTo(
        to.dx - (arrowLength * math.cos(angle - spread)),
        to.dy - (arrowLength * math.sin(angle - spread)),
      )
      ..moveTo(to.dx, to.dy)
      ..lineTo(
        to.dx - (arrowLength * math.cos(angle + spread)),
        to.dy - (arrowLength * math.sin(angle + spread)),
      );
    canvas.drawPath(arrow, paint);
  }

  @override
  bool shouldRepaint(_ScheduleRoutePainter oldDelegate) {
    return oldDelegate.visualization != visualization ||
        oldDelegate.possibleColor != possibleColor ||
        oldDelegate.traversedColor != traversedColor ||
        oldDelegate.countStyle != countStyle;
  }
}
