import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:macos_ui/macos_ui.dart';

import '../../../db_import/presentation/view_model/db_import_control_provider.dart';
import '../../../db_import/presentation/widgets/db_import_details_pane.dart';
import '../../../db_import/presentation/widgets/db_import_progress_pane.dart';
import '../../../import/domain/feature_constants.dart';

class DbMigrationPanel extends StatelessWidget {
  const DbMigrationPanel({
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
          'Data Migration',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        const Text(
          'Migrate existing data into the current database format',
          style: TextStyle(fontSize: 14, color: Color(0xFF666666)),
        ),
        const SizedBox(height: 24),
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
                ? DbImportProgressPane(controlState: controlState)
                : DbImportDetailsPane(controlState: controlState),
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
                          controlState.statusMessage!.toLowerCase().contains(
                            'failed',
                          )
                          ? const Color(0xFFFFF3CD)
                          : const Color(0xFFD4EDDA),
                      border: Border.all(
                        color:
                            controlState.statusMessage!.toLowerCase().contains(
                              'failed',
                            )
                            ? const Color(0xFFFFC107)
                            : const Color(0xFF28A745),
                      ),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      controlState.statusMessage!,
                      style: TextStyle(
                        fontSize: 13,
                        color:
                            controlState.statusMessage!.toLowerCase().contains(
                              'failed',
                            )
                            ? const Color(0xFF856404)
                            : const Color(0xFF155724),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                const Expanded(
                  child: Center(
                    child: Text(
                      'Click "Start Migration" to migrate data or "Check DB" to verify access',
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
