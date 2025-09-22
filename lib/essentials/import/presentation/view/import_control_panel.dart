import 'package:flutter/cupertino.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:macos_ui/macos_ui.dart';

import '../../domain/feature_constants.dart';
import '../view_model/import_control_state_provider.dart';
import '../widgets/import_debug_control_panel.dart';
import 'migrate_control_panel.dart';
import 'widgets/details_pane.dart';
import 'widgets/progress_pane.dart';

class ImportControlPanel extends ConsumerWidget {
  const ImportControlPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controlState = ref.watch(importControlViewModelProvider);
    final notifier = ref.read(importControlViewModelProvider.notifier);

    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Import & Migration',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          CupertinoSegmentedControl<ImportMode>(
            groupValue: controlState.selectedMode,
            onValueChanged: (ImportMode value) {
              notifier.setMode(value);
            },
            children: const {
              ImportMode.import: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text('Import'),
              ),
              ImportMode.migration: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text('Migration'),
              ),
            },
          ),
          const SizedBox(height: 24),

          Expanded(
            child: controlState.selectedMode == ImportMode.import
                ? _buildImport(context, controlState, notifier)
                : const MigrateControlPanel(),
          ),
        ],
      ),
    );
  }

  Widget _buildImport(
    BuildContext context,
    ImportControlState controlState,
    ImportControlViewModel notifier,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Import Message Data',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        const Text(
          'Import messages from macOS Messages database',
          style: TextStyle(fontSize: 14, color: Color(0xFF666666)),
        ),
        const SizedBox(height: 24),

        SizedBox(
          width: double.infinity,
          child: PushButton(
            controlSize: ControlSize.regular,
            onPressed: controlState.isProcessing
                ? null
                : () => notifier.startImport(),
            child: Text(
              controlState.isProcessing ? 'Importing...' : 'Start Import',
            ),
          ),
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
          const Expanded(
            child: Center(
              child: Text(
                'Click "Start Import" to begin importing message data',
                style: TextStyle(color: Color(0xFF999999)),
              ),
            ),
          ),

        // Debug control panel at the bottom
        const SizedBox(height: 16),
        const ImportDebugControlPanel(),
      ],
    );
  }
}
