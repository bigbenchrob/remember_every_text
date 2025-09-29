import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../import/domain/entities/import_subtask_timing.dart';
import '../view_model/db_import_control_provider.dart';

class DbImportDetailsPane extends StatelessWidget {
  const DbImportDetailsPane({super.key, required this.controlState});

  final DbImportControlState controlState;

  @override
  Widget build(BuildContext context) {
    return _buildDetailsSection(controlState);
  }

  Widget _buildDetailsSection(DbImportControlState state) {
    final stageOrder = {
      for (final stage in state.stages) stage.name: stage.displayName,
    };

    String formatDuration(Duration? duration) {
      if (duration == null) {
        return '…';
      }
      if (duration.inMilliseconds < 1000) {
        return '${duration.inMilliseconds}ms';
      }
      final seconds = duration.inMilliseconds / 1000.0;
      if (seconds < 60) {
        return '${seconds.toStringAsFixed(seconds < 10 ? 2 : 1)}s';
      }
      final minutes = duration.inMinutes;
      final remaining = seconds - minutes * 60;
      return '${minutes}m ${remaining.toStringAsFixed(1)}s';
    }

    final grouped = <String, List<ImportSubtaskTiming>>{};
    for (final timing in state.timings) {
      grouped.putIfAbsent(timing.stageName, () => []).add(timing);
    }

    final orderedStages = stageOrder.keys
        .where((key) => grouped.containsKey(key))
        .toList();

    if (orderedStages.isEmpty) {
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
              itemCount: orderedStages.length,
              itemBuilder: (context, index) {
                final stageKey = orderedStages[index];
                final stageName = stageOrder[stageKey] ?? stageKey;
                final subtasks = grouped[stageKey]!;
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
                            for (final subtask in subtasks)
                              _buildSubtaskRow(subtask, formatDuration),
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
    ImportSubtaskTiming subtask,
    String Function(Duration?) formatDuration,
  ) {
    final duration = subtask.duration;
    final done = duration != null;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFFE0E0E0))),
      ),
      child: Row(
        children: [
          Icon(
            done ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 12,
            color: done ? const Color(0xFF4CAF50) : const Color(0xFFCCCCCC),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              subtask.subtaskName,
              style: TextStyle(
                fontSize: 11,
                color: done ? const Color(0xFF222222) : const Color(0xFF777777),
                fontWeight: done ? FontWeight.w500 : FontWeight.normal,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (subtask.itemCount != null)
            Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: Text(
                subtask.itemCount.toString(),
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
    for (final subtask in subtasks) {
      if (subtask.duration == null) {
        anyIncomplete = true;
      } else {
        total += subtask.duration!;
      }
    }
    if (anyIncomplete && total == Duration.zero) {
      return null;
    }
    return total;
  }
}
