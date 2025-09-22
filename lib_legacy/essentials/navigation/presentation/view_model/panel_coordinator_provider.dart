import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../features/chats/feature_level_providers.dart';
import '../../../../features/messages/feature_level_providers.dart';
import '../../../import/presentation/view/import_control_panel.dart';
import '../../application/panels_view_state_provider.dart';
import '../../domain/entities/features/contacts_spec.dart';
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
    final panelViewState = ref.watch(panelsViewStateProvider);
    final viewSpec = panelViewState[panel];

    if (viewSpec == null) {
      return _buildEmptyPanelPlaceholder(panel);
    }

    return viewSpec.when(
      messages: (messagesSpec) => ref
          .read(messagesCoordinatorProvider.notifier)
          .buildForSpec(messagesSpec),
      chats: (chatsSpec) =>
          ref.read(chatsCoordinatorProvider.notifier).buildForSpec(chatsSpec),
      contacts: (contactsSpec) => _buildPlaceholderForContacts(contactsSpec),
      import: (importSpec) => _buildPlaceholderForImport(importSpec),
    );
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

  /// Placeholder for contacts feature (to be implemented)
  Widget _buildPlaceholderForContacts(ContactsSpec spec) {
    return Container(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.contacts_outlined,
            size: 48,
            color: Color(0xFF2196F3),
          ),
          const SizedBox(height: 16),
          const Text(
            'CONTACTS FEATURE',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2196F3),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            spec.when(
              list: () => 'Contacts List (coming soon)',
              detail: (contactId) => 'Contact Detail: $contactId (coming soon)',
              search: (query) => 'Search Results: "$query" (coming soon)',
            ),
            style: const TextStyle(fontSize: 14, color: Color(0xFF666666)),
          ),
        ],
      ),
    );
  }

  /// Import control panel with actual functionality
  Widget _buildPlaceholderForImport(ImportSpec spec) {
    return const ImportControlPanel();
  }
}
