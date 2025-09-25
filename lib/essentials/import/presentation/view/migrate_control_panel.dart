import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:macos_ui/macos_ui.dart';

import '../../domain/feature_constants.dart';
import '../view_model/import_control_state_provider.dart';
import 'widgets/details_pane.dart';
import 'widgets/progress_pane.dart';

class MigrateControlPanel extends ConsumerWidget {
  const MigrateControlPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controlState = ref.watch(importControlViewModelProvider);
    final notifier = ref.read(importControlViewModelProvider.notifier);

    return _buildMigration(context, controlState, notifier);
  }

  Widget _buildMigration(
    BuildContext context,
    ImportControlState controlState,
    ImportControlViewModel notifier,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Data Migration',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        const Text(
          'Migrate existing data into the current database format',
          style: TextStyle(fontSize: 14, color: Color(0xFF666666)),
        ),
        const SizedBox(height: 24),

        // Migration controls
        Row(
          children: [
            Expanded(
              child: PushButton(
                controlSize: ControlSize.regular,
                onPressed: controlState.isProcessing
                    ? null
                    : () => notifier.startMigration(),
                child: Text(
                  controlState.isProcessing
                      ? 'Migrating...'
                      : 'Start Migration',
                ),
              ),
            ),
            const SizedBox(width: 8),
            PushButton(
              controlSize: ControlSize.regular,
              secondary: true,
              onPressed: controlState.isProcessing
                  ? null
                  : () => notifier.checkDatabaseAccess(),
              child: const Text('Check DB'),
            ),
            const SizedBox(width: 8),
            PushButton(
              controlSize: ControlSize.regular,
              secondary: true,
              onPressed: controlState.isProcessing
                  ? null
                  : () => notifier.showDatabaseDiagnostics(),
              child: const Text('Help'),
            ),
          ],
        ),
        const SizedBox(height: 24),

        if (controlState.stages.isNotEmpty) ...[
          CupertinoSegmentedControl<ImportViewMode>(
            groupValue: controlState.viewMode,
            onValueChanged: notifier.setViewMode,
            children: const {
              ImportViewMode.progress: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Text('Progress'),
              ),
              ImportViewMode.details: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Text('Details'),
              ),
            },
          ),
          const SizedBox(height: 16),
        ],

        if (controlState.stages.isNotEmpty)
          Expanded(
            child: controlState.viewMode == ImportViewMode.progress
                ? ImportProgressPane(controlState: controlState)
                : ImportDetailsPane(controlState: controlState),
          )
        else
          Expanded(
            child: Column(
              children: [
                if (controlState.statusMessage != null) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color:
                          controlState.statusMessage!.contains('failed') ||
                              controlState.statusMessage!.contains('locked')
                          ? const Color(0xFFFFF3CD) // Warning background
                          : const Color(0xFFD4EDDA), // Success background
                      border: Border.all(
                        color:
                            controlState.statusMessage!.contains('failed') ||
                                controlState.statusMessage!.contains('locked')
                            ? const Color(0xFFFFC107) // Warning border
                            : const Color(0xFF28A745), // Success border
                      ),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      controlState.statusMessage!,
                      style: TextStyle(
                        fontSize: 13,
                        color:
                            controlState.statusMessage!.contains('failed') ||
                                controlState.statusMessage!.contains('locked')
                            ? const Color(0xFF856404) // Warning text
                            : const Color(0xFF155724), // Success text
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                const Expanded(
                  child: Center(
                    child: Text(
                      'Click "Start Migration" to migrate data or "Check Database" to verify access',
                      style: TextStyle(color: Color(0xFF999999)),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
