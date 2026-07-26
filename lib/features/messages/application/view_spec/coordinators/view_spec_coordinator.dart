import 'package:flutter/widgets.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../domain/spec_classes/messages_view_spec.dart';
import '../resolvers/global_timeline_resolver.dart';
import '../resolvers/handle_investigation_resolver.dart';
import '../resolvers/messages_for_contact_resolver.dart';
import '../resolvers/messages_for_handle_resolver.dart';
import '../resolvers/recovered_attachment_sidebar_resolver.dart';
import '../resolvers/recovered_unlinked_messages_resolver.dart';

part 'view_spec_coordinator.g.dart';

/// Coordinator that maps [MessagesSpec] to rendered widgets for the center panel.
///
/// Each variant is delegated to a dedicated resolver, which in turn calls a
/// widget builder in `../widget_builders/`.
@riverpod
class ViewSpecCoordinator extends _$ViewSpecCoordinator {
  @override
  void build() {
    // Stateless coordinator
  }

  /// Build a center-panel widget for the given [MessagesSpec].
  Widget buildForSpec(MessagesSpec spec) {
    return spec.when(
      forContact: (contactId, scrollToDate, filterHandleId) =>
          MessagesForContactResolver().resolve(
            contactId: contactId,
            scrollToDate: scrollToDate,
            filterHandleId: filterHandleId,
          ),
      globalTimeline: (scrollToDate) =>
          GlobalTimelineResolver().resolve(scrollToDate: scrollToDate),
      forHandle: (handleId) =>
          MessagesForHandleResolver().resolve(handleId: handleId),
      recoveredUnlinkedMessages: (contactId, scrollToDate) =>
          RecoveredUnlinkedMessagesResolver().resolve(
            contactId: contactId,
            scrollToDate: scrollToDate,
          ),
      recoveredNoHandleFromMeMessages: (scrollToDate) =>
          RecoveredUnlinkedMessagesResolver().resolve(
            onlyNoHandleFromMe: true,
            scrollToDate: scrollToDate,
          ),
      recoveredAttachmentViewer: (messageId, attachment) =>
          RecoveredAttachmentSidebarResolver().resolve(
            messageId: messageId,
            attachment: attachment,
          ),
      handleInvestigation: (investigationId, investigation, target) =>
          HandleInvestigationResolver().resolve(
            investigation: investigation,
            target: target,
          ),
    );
  }
}
