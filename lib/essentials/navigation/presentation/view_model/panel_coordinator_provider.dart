import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

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
    return _buildEmptyPanelPlaceholder(panel);

    // Future: render real widgets based on viewSpec
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
