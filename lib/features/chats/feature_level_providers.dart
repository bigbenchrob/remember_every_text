///***************************************************************** */
///* The entry point for dependency injection for the Chats feature.
///***************************************************************** */

import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../essentials/navigation/domain/entities/features/chats_spec.dart';
import 'presentation/widgets/recent_chats_list.dart';

part 'feature_level_providers.g.dart';

/// Holds the currently selected chat ID across the app. -1 means none.
@riverpod
class ChosenChatId extends _$ChosenChatId {
  @override
  int build() {
    return -1;
  }

  // ignore: use_setters_to_change_properties
  void setChatId(int id) {
    state = id;
  }

  void clear() {
    state = -1;
  }
}

/// Coordinator that maps ChatsSpec to appropriate widget builders
@riverpod
class ChatsCoordinator extends _$ChatsCoordinator {
  @override
  void build() {
    // Stateless coordinator
  }

  /// Build widget for the given ChatsSpec
  Widget buildForSpec(ChatsSpec spec) {
    return spec.when(
      list: () => const RecentChatsList(),
      forContact: (contactId) => _buildContactChatsPlaceholder(contactId),
      recent: (limit) => _buildRecentChatsWithLimit(limit),
    );
  }

  /// Placeholder for contact chats (to be implemented)
  Widget _buildContactChatsPlaceholder(String contactId) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Text('Chats for Contact ID: $contactId (coming soon)'),
    );
  }

  /// Recent chats with a specific limit
  Widget _buildRecentChatsWithLimit(int limit) {
    return const RecentChatsList(); // Will use the limit from the provider
  }
}
