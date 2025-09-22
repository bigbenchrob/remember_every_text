import 'dart:ui';
import 'package:flutter/material.dart';

import '../../../domain/entities/import_subtask_timing.dart';
import '../../view_model/import_control_state_provider.dart';

class ImportDetailsPane extends StatelessWidget {
  const ImportDetailsPane({super.key, required this.controlState});

  final ImportControlState controlState;

  @override
  Widget build(BuildContext context) {
    return _buildDetailsSection(controlState);
  }

  Widget _buildDetailsSection(ImportControlState controlState) {
    final timings = controlState.timings;

    // Group subtasks by stage for display order matching stages list
    final stageOrder = {
      for (final s in controlState.stages) s.name: s.displayName,
    };

    String formatDuration(Duration? d) {
      if (d == null) {
        return '…';
      }
      final ms = d.inMilliseconds;
      if (ms < 1000) {
        return '${ms}ms';
      }
      final seconds = ms / 1000.0;
      if (seconds < 60) {
        return '${seconds.toStringAsFixed(seconds < 10 ? 2 : 1)}s';
      }
      final minutes = d.inMinutes;
      final remain = (seconds - minutes * 60).toStringAsFixed(1);
      return '${minutes}m ${remain}s';
    }

    final grouped = <String, List<ImportSubtaskTiming>>{};
    for (final t in timings) {
      grouped.putIfAbsent(t.stageName, () => []).add(t);
    }

    final orderedStageKeys = stageOrder.keys
        .where((k) => grouped.containsKey(k))
        .toList();

    if (orderedStageKeys.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(color: const Color(0xFFE0E0E0)),
        ),
        child: const Center(
          child: Text(
            'Timing details will appear here as the import progresses',
            style: TextStyle(color: Color(0xFF777777)),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Detailed Timings',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.builder(
              itemCount: orderedStageKeys.length,
              itemBuilder: (context, index) {
                final stageKey = orderedStageKeys[index];
                final stageName = stageOrder[stageKey] ?? stageKey;
                final subtasks = grouped[stageKey]!;
                // Sort by start time
                subtasks.sort((a, b) => a.startedAt.compareTo(b.startedAt));
                final totalDuration = _sumDurations(subtasks);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        stageName,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF333333),
                        ),
                      ),
                      const SizedBox(height: 4),
                      DecoratedBox(
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFFFFF),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: const Color(0xFFE0E0E0)),
                        ),
                        child: Column(
                          children: [
                            for (final st in subtasks)
                              _buildSubtaskRow(st, formatDuration),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: const BoxDecoration(
                                border: Border(
                                  top: BorderSide(color: Color(0xFFE0E0E0)),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Expanded(
                                    child: Text(
                                      'Stage total',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF555555),
                                      ),
                                    ),
                                  ),
                                  Text(
                                    formatDuration(totalDuration),
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF222222),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubtaskRow(
    ImportSubtaskTiming st,
    String Function(Duration?) formatDuration,
  ) {
    final duration = st.duration;
    final done = duration != null;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFFE0E0E0))),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            done ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 12,
            color: done ? const Color(0xFF4CAF50) : const Color(0xFFCCCCCC),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              st.subtaskName,
              style: TextStyle(
                fontSize: 11,
                color: done ? const Color(0xFF222222) : const Color(0xFF777777),
                fontWeight: done ? FontWeight.w500 : FontWeight.normal,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (st.itemCount != null)
            Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: Text(
                '${st.itemCount}',
                style: const TextStyle(fontSize: 11, color: Color(0xFF555555)),
              ),
            ),
          Text(
            formatDuration(duration),
            style: TextStyle(
              fontSize: 11,
              color: done ? const Color(0xFF333333) : const Color(0xFF999999),
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }

  Duration? _sumDurations(List<ImportSubtaskTiming> subtasks) {
    var total = Duration.zero;
    var anyIncomplete = false;
    for (final s in subtasks) {
      if (s.duration == null) {
        anyIncomplete = true;
      } else {
        total += s.duration!;
      }
    }
    if (anyIncomplete && total == Duration.zero) {
      return null;
    }
    return total;
  }
}
