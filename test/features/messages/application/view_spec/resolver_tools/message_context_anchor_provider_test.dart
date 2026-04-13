import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:remember_this_text/essentials/db/feature_level_providers/working_db_populated_provider.dart';
import 'package:remember_this_text/essentials/navigation/application/panels_view_state_provider.dart';
import 'package:remember_this_text/essentials/navigation/domain/entities/view_spec.dart';
import 'package:remember_this_text/essentials/navigation/domain/navigation_constants.dart';
import 'package:remember_this_text/essentials/navigation/domain/sidebar_mode.dart';
import 'package:remember_this_text/essentials/sidebar/application/sidebar_flow_state_provider.dart';
import 'package:remember_this_text/features/messages/application/timeline/ordinal/message_timeline_ordinal_provider.dart';
import 'package:remember_this_text/features/messages/application/view_spec/resolver_tools/message_context_anchor_provider.dart';
import 'package:remember_this_text/features/messages/domain/spec_classes/messages_view_spec.dart';
import 'package:remember_this_text/features/messages/domain/value_objects/message_timeline_scope.dart';
import 'package:remember_this_text/features/messages/presentation/view_model/timeline/message_timeline_view_model_provider.dart';

void main() {
  group('messageContextAnchorProvider', () {
    test(
      'derives the active anchor from search-result context right panel',
      () {
        const globalScope = MessageTimelineScope.global();
        final container = ProviderContainer(
          overrides: [
            workingDbPopulatedProvider.overrideWith(
              _AlwaysPopulatedWorkingDb.new,
            ),
            messageTimelineViewModelProvider(
              scope: globalScope,
            ).overrideWith(_FakeSearchingGlobalTimelineViewModel.new),
          ],
        );

        container.read(sidebarFlowProvider.notifier).showGlobalTimeline();
        container
            .read(panelsViewStateProvider(SidebarMode.messages).notifier)
            .show(
              panel: WindowPanel.right,
              spec: const ViewSpec.messages(
                MessagesSpec.searchResultContext(
                  messageId: 99,
                  chatId: 5,
                  beforeCount: 10,
                  afterCount: 10,
                ),
              ),
            );

        final anchor = container.read(messageContextAnchorProvider);

        expect(anchor, isNotNull);
        expect(anchor!.messageId, 99);
        expect(anchor.chatId, 5);
        expect(anchor.beforeCount, 10);
        expect(anchor.afterCount, 10);

        container.dispose();
      },
    );

    test(
      'clears the active anchor when the right panel becomes incompatible',
      () {
        const globalScope = MessageTimelineScope.global();
        final container = ProviderContainer(
          overrides: [
            workingDbPopulatedProvider.overrideWith(
              _AlwaysPopulatedWorkingDb.new,
            ),
            messageTimelineViewModelProvider(
              scope: globalScope,
            ).overrideWith(_FakeSearchingGlobalTimelineViewModel.new),
          ],
        );

        container.read(sidebarFlowProvider.notifier).showGlobalTimeline();
        container
            .read(panelsViewStateProvider(SidebarMode.messages).notifier)
            .show(
              panel: WindowPanel.right,
              spec: const ViewSpec.messages(
                MessagesSpec.searchResultContext(messageId: 99, chatId: 5),
              ),
            );

        expect(container.read(messageContextAnchorProvider), isNotNull);

        container
            .read(sidebarFlowProvider.notifier)
            .showContactTimelineAt(contactId: 42);

        expect(container.read(messageContextAnchorProvider), isNull);

        container.dispose();
      },
    );
  });
}

class _AlwaysPopulatedWorkingDb extends WorkingDbPopulated {
  @override
  bool build() {
    return true;
  }
}

class _FakeSearchingGlobalTimelineViewModel extends MessageTimelineViewModel {
  @override
  MessageTimelineViewModelState build({required MessageTimelineScope scope}) {
    final searchController = TextEditingController(text: 'anchor');
    ref.onDispose(searchController.dispose);

    return MessageTimelineViewModelState(
      scope: scope,
      searchController: searchController,
      searchQuery: 'anchor',
      debouncedQuery: 'anchor',
      searchMode: MessageSearchMode.allTerms,
      searchResultIds: const AsyncValue<List<int>>.data(<int>[99]),
      ordinal: const AsyncValue<MessageTimelineOrdinalState>.loading(),
    );
  }
}
