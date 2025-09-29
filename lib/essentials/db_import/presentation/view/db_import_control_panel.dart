import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:macos_ui/macos_ui.dart';

import '../../../db_migrate/presentation/view/db_migration_panel.dart';
import '../../../import/domain/feature_constants.dart';
import '../view_model/db_import_control_provider.dart';
import '../widgets/db_import_debug_panel.dart';
import '../widgets/db_import_details_pane.dart';
import '../widgets/db_import_progress_pane.dart';

class DbImportControlPanel extends ConsumerWidget {
  const DbImportControlPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controlState = ref.watch(dbImportControlViewModelProvider);
    final notifier = ref.read(dbImportControlViewModelProvider.notifier);

    return ColoredBox(
      color: const Color(0xFFF7F7F7),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Import & Migration Controls',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: CupertinoSegmentedControl<ImportMode>(
                    groupValue: controlState.selectedMode,
                    onValueChanged: (value) {
                      notifier.setMode(value);
                    },
                    children: const {
                      ImportMode.import: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Text('Import'),
                      ),
                      ImportMode.migration: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Text('Migration'),
                      ),
                    },
                  ),
                ),
                const SizedBox(width: 12),
                MacosTooltip(
                  message: controlState.showingDebugPanel
                      ? 'Close debug settings'
                      : 'Open debug settings',
                  child: MacosIconButton(
                    semanticLabel: controlState.showingDebugPanel
                        ? 'Close debug settings'
                        : 'Open debug settings',
                    icon: MacosIcon(
                      controlState.showingDebugPanel
                          ? CupertinoIcons.xmark
                          : CupertinoIcons.ant,
                    ),
                    boxConstraints: const BoxConstraints(
                      minWidth: 30,
                      minHeight: 30,
                    ),
                    onPressed: notifier.toggleDebugPanel,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: controlState.showingDebugPanel
                    ? const _DebugPanelView(key: ValueKey('debug-controls'))
                    : controlState.selectedMode == ImportMode.import
                    ? _ImportControls(
                        key: const ValueKey('import-controls'),
                        controlState: controlState,
                        notifier: notifier,
                      )
                    : DbMigrationPanel(
                        key: const ValueKey('migration-controls'),
                        controlState: controlState,
                        notifier: notifier,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ImportControls extends StatelessWidget {
  const _ImportControls({
    required this.controlState,
    required this.notifier,
    super.key,
  });

  final DbImportControlState controlState;
  final DbImportControlViewModel notifier;

  @override
  Widget build(BuildContext context) {
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
                ? DbImportProgressPane(controlState: controlState)
                : DbImportDetailsPane(controlState: controlState),
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
      ],
    );
  }
}

class _DebugPanelView extends StatelessWidget {
  const _DebugPanelView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Align(
      alignment: Alignment.topCenter,
      child: SingleChildScrollView(
        child: SizedBox(width: double.infinity, child: DbImportDebugPanel()),
      ),
    );
  }
}
