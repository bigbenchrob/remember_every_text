/// Public API providers for the Messages feature.
///
/// These providers are designed to be imported and used by other features.
/// Internal implementation details should remain in application/use_cases/

import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../essentials/navigation/domain/entities/features/messages_spec.dart';
import 'application/use_cases/messages_for_chat_view_builder_provider.dart';

part 'feature_level_providers.g.dart';

/// Coordinator that maps MessagesSpec to appropriate widget builders
@riverpod
class MessagesCoordinator extends _$MessagesCoordinator {
  @override
  void build() {
    // Stateless coordinator
  }

  /// Build widget for the given MessagesSpec
  Widget buildForSpec(MessagesSpec spec) {
    return spec.when(
      forChat: (chatId) => ref.read(messagesForChatViewBuilderProvider(chatId)),
      forContact: (contactId) => _buildContactMessagesPlaceholder(contactId),
      recent: (limit) => _buildRecentMessagesPlaceholder(limit),
    );
  }

  /// Placeholder for contact messages (to be implemented)
  Widget _buildContactMessagesPlaceholder(String contactId) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Text('Messages for Contact ID: $contactId (coming soon)'),
    );
  }

  /// Placeholder for recent messages (to be implemented)
  Widget _buildRecentMessagesPlaceholder(int limit) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Text('Recent $limit messages (coming soon)'),
    );
  }
}
