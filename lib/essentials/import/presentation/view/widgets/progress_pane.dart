import 'dart:ui';
import 'package:flutter/material.dart';

import '../../../domain/entities/import_progress_stage.dart';
import '../../../domain/entities/import_subtask_timing.dart';
import '../../view_model/import_control_state_provider.dart';

class ImportProgressPane extends StatelessWidget {
  const ImportProgressPane({super.key, required this.controlState});

  final ImportControlState controlState;

  @override
  Widget build(BuildContext context) {
    // Determine if this is a migration based on status message content
    final isMigration =
        controlState.statusMessage?.toLowerCase().contains('migrat') ?? false;
    return _buildProgressSection(controlState, isImport: !isMigration);
  }

  Widget _buildProgressSection(
    ImportControlState controlState, {
    required bool isImport,
  }) {
    // Precompute total durations per stage from instrumentation timings
    final grouped = <String, List<ImportSubtaskTiming>>{};
    for (final t in controlState.timings) {
      grouped.putIfAbsent(t.stageName, () => []).add(t);
    }
    final stageDurations = <String, Duration?>{
      for (final e in grouped.entries) e.key: _sumDurations(e.value),
    };

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${isImport ? 'Import' : 'Migration'} Progress',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),

          // Overall progress bar
          LinearProgressIndicator(
            value: controlState.progress,
            backgroundColor: const Color(0xFFE0E0E0),
            valueColor: AlwaysStoppedAnimation<Color>(
              isImport ? const Color(0xFF4CAF50) : const Color(0xFF2196F3),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            controlState.statusMessage ?? 'Preparing...',
            style: const TextStyle(fontSize: 12, color: Color(0xFF666666)),
          ),
          const SizedBox(height: 16),

          // Detailed step progress
          Expanded(
            child: controlState.stages.isEmpty
                ? Center(
                    child: Text(
                      isImport
                          ? 'Click "Start Import" to begin'
                          : 'Click "Start Migration" to begin',
                      style: const TextStyle(color: Color(0xFF999999)),
                    ),
                  )
                : ListView.separated(
                    itemCount: controlState.stages.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final stage = controlState.stages[index];
                      final duration = stageDurations[stage.name];
                      return _buildStageItem(stage, duration: duration);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStageItem(ImportProgressStage stage, {Duration? duration}) {
    Color iconColor;
    IconData icon;
    var statusText = stage.displayName;

    if (stage.isComplete) {
      iconColor = const Color(0xFF4CAF50);
      icon = Icons.check_circle;
    } else if (stage.isActive) {
      iconColor = const Color(0xFF2196F3);
      icon = Icons.radio_button_checked;
      if (stage.current != null && stage.total != null) {
        statusText += ' (${stage.current}/${stage.total})';
      }
    } else {
      iconColor = const Color(0xFFCCCCCC);
      icon = Icons.radio_button_unchecked;
    }

    String formatDurationShort(Duration d) {
      if (d.inMilliseconds < 1000) {
        return '${d.inMilliseconds}ms';
      }
      if (d.inSeconds < 60) {
        final s = d.inMilliseconds / 1000.0;
        return '${s.toStringAsFixed(s < 10 ? 2 : 1)}s';
      }
      final m = d.inMinutes;
      final sRem = d.inSeconds - m * 60;
      return '${m}m ${sRem}s';
    }

    Color? accentForStage(String name) {
      if (name == 'analyzingMessages') {
        return const Color(0xFFFB8C00); // orange
      }
      if (name == 'extractingRichContent') {
        return const Color(0xFF8E24AA); // purple
      }
      if (name == 'importingMessages') {
        return const Color(0xFF00897B); // teal
      }
      return null;
    }

    final accent = accentForStage(stage.name);

    final row = Row(
      children: [
        Icon(icon, size: 16, color: iconColor),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                statusText,
                style: TextStyle(
                  fontSize: 13,
                  color: stage.isActive || stage.isComplete
                      ? const Color(0xFF333333)
                      : const Color(0xFF999999),
                  fontWeight: stage.isActive
                      ? FontWeight.w500
                      : FontWeight.normal,
                ),
              ),
              if ((stage.isActive && stage.progress != null) ||
                  (stage.isComplete && stage.progress != null)) ...[
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: stage.progress,
                  backgroundColor: const Color(0xFFE0E0E0),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    stage.isComplete
                        ? const Color(0xFF4CAF50)
                        : const Color(0xFF2196F3),
                  ),
                ),
              ],
            ],
          ),
        ),
        if (stage.isComplete && duration != null)
          Text(
            formatDurationShort(duration),
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF555555),
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
      ],
    );

    if (accent != null && stage.isActive) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
        decoration: BoxDecoration(
          color: accent.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(6),
          border: Border(
            left: BorderSide(color: accent.withValues(alpha: 0.9), width: 3),
          ),
        ),
        child: row,
      );
    }

    return row;
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
