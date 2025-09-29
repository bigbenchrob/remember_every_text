import 'dart:ui';

import 'package:flutter/material.dart';

import '../view_model/db_import_control_provider.dart';

class DbImportProgressPane extends StatelessWidget {
  const DbImportProgressPane({
    super.key,
    required this.controlState,
    required this.mode,
  });

  final DbImportControlState controlState;
  final DbImportMode mode;

  @override
  Widget build(BuildContext context) {
    final isImport = mode == DbImportMode.import;
    return _buildProgressSection(controlState, isImport: isImport);
  }

  Widget _buildProgressSection(
    DbImportControlState state, {
    required bool isImport,
  }) {
    final stageDurations = <String, Duration?>{
      for (final stage in state.stages) stage.name: stage.duration,
    };
    final aggregateDuration = _aggregateDuration(state.stages);

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
          LinearProgressIndicator(
            value: state.progress,
            backgroundColor: const Color(0xFFE0E0E0),
            valueColor: AlwaysStoppedAnimation<Color>(
              isImport ? const Color(0xFF4CAF50) : const Color(0xFF2196F3),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            state.statusMessage ?? 'Preparing...',
            style: const TextStyle(fontSize: 12, color: Color(0xFF666666)),
          ),
          const SizedBox(height: 16),
          if (aggregateDuration != null) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: const Color(0xFF4CAF50).withValues(alpha: 0.4),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.timer_outlined,
                    size: 16,
                    color: Color(0xFF2E7D32),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Total elapsed time: ${_formatDurationShort(aggregateDuration)}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2E7D32),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          Expanded(
            child: state.stages.isEmpty
                ? Center(
                    child: Text(
                      isImport
                          ? 'Click "Start Import" to begin'
                          : 'Click "Start Migration" to begin',
                      style: const TextStyle(color: Color(0xFF999999)),
                    ),
                  )
                : ListView.separated(
                    itemCount: state.stages.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final stage = state.stages[index];
                      final duration = stageDurations[stage.name];
                      return _buildStageItem(stage, duration: duration);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStageItem(UiStageProgress stage, {Duration? duration}) {
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

    Color? accentForStage(String name) {
      if (name == 'extractingRichContent') {
        return const Color(0xFF8E24AA);
      }
      if (name == 'importingMessages') {
        return const Color(0xFF00897B);
      }
      if (name == 'migratingMessages') {
        return const Color(0xFF1976D2);
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
            _formatDurationShort(duration),
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

  Duration? _aggregateDuration(List<UiStageProgress> stages) {
    if (stages.isEmpty || stages.every((stage) => !stage.isComplete)) {
      return null;
    }
    if (stages.any((stage) => !stage.isComplete || stage.duration == null)) {
      return null;
    }

    return stages.fold<Duration>(
      Duration.zero,
      (accumulator, stage) => accumulator + stage.duration!,
    );
  }

  String _formatDurationShort(Duration duration) {
    if (duration.inMilliseconds < 1000) {
      return '${duration.inMilliseconds}ms';
    }
    if (duration.inSeconds < 60) {
      final seconds = duration.inMilliseconds / 1000.0;
      return '${seconds.toStringAsFixed(seconds < 10 ? 2 : 1)}s';
    }
    final minutes = duration.inMinutes;
    final remainingSeconds = duration.inSeconds - minutes * 60;
    return '${minutes}m ${remainingSeconds}s';
  }
}
