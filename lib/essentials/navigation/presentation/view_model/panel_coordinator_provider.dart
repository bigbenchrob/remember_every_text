import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../features/chats/presentation/view/chats_sidebar_view.dart';
import '../../../../features/messages/feature_level_providers.dart';
import '../../../db_import/presentation/view/db_import_control_panel.dart';
import '../../../db_import/presentation/view_model/db_import_control_provider.dart';
import '../../application/panels_view_state_provider.dart';
import '../../domain/entities/features/import_spec.dart';
import '../../domain/entities/view_spec.dart';
import '../../domain/navigation_constants.dart';

part 'panel_coordinator_provider.g.dart';

/// Coordinator that maps panel ViewSpecs to rendered widgets
@riverpod
class PanelCoordinator extends _$PanelCoordinator {
  @override
  void build() {
    // Stateless coordinator
  }

  /// Build widget for the specified panel
  Widget buildPanelWidget(WindowPanel panel) {
    final panelSpecs = ref.read(panelsViewStateProvider);
    final viewSpec = panelSpecs[panel];

    if (viewSpec == null) {
      return _buildEmptyPanelPlaceholder(panel);
    }

    return viewSpec.when(
      messages: (messagesSpec) =>
          ref.read(messagesCoordinatorProvider.notifier).buildForSpec(
                messagesSpec,
              ),
      chats: (chatsSpec) => ChatsSidebarView(spec: chatsSpec),
      contacts: (_) => _buildEmptyPanelPlaceholder(panel),
      import: (spec) => _buildImportPanel(spec),
    );
  }

  Widget _buildImportPanel(ImportSpec spec) {
    final desiredMode = spec.when(
      forImport: () => DbImportMode.import,
      forMigration: () => DbImportMode.migration,
    );

    final controlState = ref.read(dbImportControlViewModelProvider);
    if (controlState.selectedMode != desiredMode) {
      ref.read(dbImportControlViewModelProvider.notifier).setMode(desiredMode);
    }

    return const DbImportControlPanel();
  }

  /// Placeholder for empty panels
  Widget _buildEmptyPanelPlaceholder(WindowPanel panel) {
    return Container(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.inbox_outlined, size: 48, color: Color(0xFFCCCCCC)),
          const SizedBox(height: 16),
          Text(
            '${panel.name.toUpperCase()} PANEL',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF999999).withValues(alpha: 0.8),
            ),
          ),
          const Text(
            'No content selected',
            style: TextStyle(fontSize: 12, color: Color(0xFFCCCCCC)),
          ),
        ],
      ),
    );
  }
}
