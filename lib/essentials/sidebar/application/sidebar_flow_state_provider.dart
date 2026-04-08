import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../features/messages/domain/spec_classes/messages_view_spec.dart';
import '../../../features/sidebar_utilities/feature_level_providers.dart';
import '../../logging/application/app_logger.dart';
import '../../navigation/application/panels_view_state_provider.dart';
import '../../navigation/domain/entities/view_spec.dart';
import '../../navigation/domain/navigation_constants.dart';
import '../../navigation/domain/sidebar_mode.dart';
import '../feature_level_providers.dart';

part 'sidebar_flow_state_provider.freezed.dart';
part 'sidebar_flow_state_provider.g.dart';

enum SidebarFlowMessageScope { regular, recoveredDeleted }

@freezed
abstract class SidebarFlowState with _$SidebarFlowState {
  const factory SidebarFlowState({
    @Default(TopChatMenuChoice.contacts) TopChatMenuChoice topMenuChoice,
    int? chosenContactId,
    int? selectedHandleId,
    DateTime? scrollToDate,
    @Default(SidebarFlowMessageScope.regular)
    SidebarFlowMessageScope messageScope,
  }) = _SidebarFlowState;

  const SidebarFlowState._();

  bool get isContactsBranch {
    return topMenuChoice == TopChatMenuChoice.contacts;
  }

  ViewSpec? get projectedCenterSpec {
    switch (topMenuChoice) {
      case TopChatMenuChoice.contacts:
        final contactId = chosenContactId;
        if (contactId == null) {
          return null;
        }

        switch (messageScope) {
          case SidebarFlowMessageScope.regular:
            return ViewSpec.messages(
              MessagesSpec.forContact(
                contactId: contactId,
                scrollToDate: scrollToDate,
                filterHandleId: selectedHandleId,
              ),
            );
          case SidebarFlowMessageScope.recoveredDeleted:
            return ViewSpec.messages(
              MessagesSpec.recoveredUnlinkedMessages(
                contactId: contactId,
                scrollToDate: scrollToDate,
              ),
            );
        }
      case TopChatMenuChoice.strayHandles:
        return null;
      case TopChatMenuChoice.searchAllMessages:
        return ViewSpec.messages(
          MessagesSpec.globalTimeline(scrollToDate: scrollToDate),
        );
      case TopChatMenuChoice.recoveredUnlinkedMessages:
        return ViewSpec.messages(
          MessagesSpec.recoveredUnlinkedMessages(scrollToDate: scrollToDate),
        );
      case TopChatMenuChoice.recoveredNoHandleFromMeMessages:
        return ViewSpec.messages(
          MessagesSpec.recoveredNoHandleFromMeMessages(
            scrollToDate: scrollToDate,
          ),
        );
    }
  }
}

@riverpod
class SidebarFlow extends _$SidebarFlow {
  @override
  SidebarFlowState build() {
    return const SidebarFlowState();
  }

  void _setStateAndClearRightIfNeeded(SidebarFlowState nextState) {
    final previousProjectedCenterSpec = state.projectedCenterSpec;
    state = nextState;

    if (previousProjectedCenterSpec == state.projectedCenterSpec) {
      return;
    }

    ref
        .read(panelsViewStateProvider(SidebarMode.messages).notifier)
        .clear(panel: WindowPanel.right);
  }

  void topMenuChanged({
    required TopChatMenuChoice choice,
    required int cassetteIndex,
  }) {
    _setStateAndClearRightIfNeeded(switch (choice) {
      TopChatMenuChoice.contacts => const SidebarFlowState(
        topMenuChoice: TopChatMenuChoice.contacts,
      ),
      TopChatMenuChoice.strayHandles => const SidebarFlowState(
        topMenuChoice: TopChatMenuChoice.strayHandles,
      ),
      TopChatMenuChoice.searchAllMessages => const SidebarFlowState(
        topMenuChoice: TopChatMenuChoice.searchAllMessages,
      ),
      TopChatMenuChoice.recoveredUnlinkedMessages => const SidebarFlowState(
        topMenuChoice: TopChatMenuChoice.recoveredUnlinkedMessages,
        messageScope: SidebarFlowMessageScope.recoveredDeleted,
      ),
      TopChatMenuChoice.recoveredNoHandleFromMeMessages =>
        const SidebarFlowState(
          topMenuChoice: TopChatMenuChoice.recoveredNoHandleFromMeMessages,
        ),
    });

    final newSpec = CassetteSpec.sidebarUtility(
      SidebarUtilityCassetteSpec.topChatMenu(selectedChoice: choice),
    );

    ref
        .read(cassetteRackStateProvider(SidebarMode.messages).notifier)
        .replaceAtIndexAndCascade(cassetteIndex, newSpec);
  }

  void contactChosen({required int contactId, required int infoCardIndex}) {
    _setStateAndClearRightIfNeeded(
      state.copyWith(
        topMenuChoice: TopChatMenuChoice.contacts,
        chosenContactId: contactId,
        selectedHandleId: null,
        messageScope: SidebarFlowMessageScope.regular,
      ),
    );

    final newSpec = CassetteSpec.contacts(
      ContactsCassetteSpec.contactHeroSummary(chosenContactId: contactId),
    );

    ref
        .read(cassetteRackStateProvider(SidebarMode.messages).notifier)
        .replaceAtIndexAndCascade(infoCardIndex, newSpec);
  }

  void chooseAnotherContact({required int infoCardIndex}) {
    ref
        .read(appLoggerProvider.notifier)
        .debug(
          'chooseAnotherContact start',
          source: 'SidebarFlow',
          context: {
            'infoCardIndex': infoCardIndex,
            'previousChosenContactId': state.chosenContactId,
            'previousSelectedHandleId': state.selectedHandleId,
            'previousProjectedCenterSpec': '${state.projectedCenterSpec}',
          },
        );

    _setStateAndClearRightIfNeeded(
      state.copyWith(
        chosenContactId: null,
        selectedHandleId: null,
        messageScope: SidebarFlowMessageScope.regular,
      ),
    );

    const newSpec = CassetteSpec.contactsInfo(
      ContactsInfoCassetteSpec.infoCard(
        key: ContactsInfoKey.pickerContentSources,
      ),
    );

    ref
        .read(cassetteRackStateProvider(SidebarMode.messages).notifier)
        .replaceAtIndexAndCascade(infoCardIndex, newSpec);

    ref
        .read(appLoggerProvider.notifier)
        .debug(
          'chooseAnotherContact complete',
          source: 'SidebarFlow',
          context: {
            'infoCardIndex': infoCardIndex,
            'chosenContactId': state.chosenContactId,
            'selectedHandleId': state.selectedHandleId,
            'projectedCenterSpec': '${state.projectedCenterSpec}',
          },
        );
  }

  void handleSelected({
    required int contactId,
    required int? handleId,
    required int cassetteIndex,
  }) {
    _setStateAndClearRightIfNeeded(
      state.copyWith(
        topMenuChoice: TopChatMenuChoice.contacts,
        chosenContactId: contactId,
        selectedHandleId: handleId,
        messageScope: SidebarFlowMessageScope.regular,
      ),
    );

    final newSpec = CassetteSpec.contacts(
      ContactsCassetteSpec.handleFilter(
        contactId: contactId,
        selectedHandleId: handleId,
      ),
    );

    ref
        .read(cassetteRackStateProvider(SidebarMode.messages).notifier)
        .replaceAtIndexAndCascade(cassetteIndex, newSpec);
  }

  void setContactMessageScope({
    required int contactId,
    required SidebarFlowMessageScope messageScope,
  }) {
    if (messageScope == SidebarFlowMessageScope.regular) {
      _setStateAndClearRightIfNeeded(
        state.copyWith(
          topMenuChoice: TopChatMenuChoice.contacts,
          chosenContactId: contactId,
          scrollToDate: null,
          messageScope: SidebarFlowMessageScope.regular,
        ),
      );
      return;
    }

    _setStateAndClearRightIfNeeded(
      state.copyWith(
        topMenuChoice: TopChatMenuChoice.contacts,
        chosenContactId: contactId,
        selectedHandleId: null,
        scrollToDate: null,
        messageScope: SidebarFlowMessageScope.recoveredDeleted,
      ),
    );
  }

  void showRecoveredDeletedForContact({
    required int contactId,
    required int heroCassetteIndex,
  }) {
    _setStateAndClearRightIfNeeded(
      state.copyWith(
        topMenuChoice: TopChatMenuChoice.contacts,
        chosenContactId: contactId,
        selectedHandleId: null,
        messageScope: SidebarFlowMessageScope.recoveredDeleted,
      ),
    );

    final heroSpec = CassetteSpec.contacts(
      ContactsCassetteSpec.contactHeroSummary(chosenContactId: contactId),
    );

    ref
        .read(cassetteRackStateProvider(SidebarMode.messages).notifier)
        .replaceAtIndexAndCascade(heroCassetteIndex, heroSpec);
  }

  void showGlobalRecoveredDeleted() {
    _setStateAndClearRightIfNeeded(
      state.copyWith(
        topMenuChoice: TopChatMenuChoice.recoveredUnlinkedMessages,
        chosenContactId: null,
        selectedHandleId: null,
        scrollToDate: null,
        messageScope: SidebarFlowMessageScope.recoveredDeleted,
      ),
    );
  }

  void showRecoveredNoHandleFromMe({DateTime? scrollToDate}) {
    _setStateAndClearRightIfNeeded(
      state.copyWith(
        topMenuChoice: TopChatMenuChoice.recoveredNoHandleFromMeMessages,
        chosenContactId: null,
        selectedHandleId: null,
        scrollToDate: scrollToDate,
        messageScope: SidebarFlowMessageScope.regular,
      ),
    );
  }

  void showGlobalTimeline() {
    _setStateAndClearRightIfNeeded(
      state.copyWith(
        topMenuChoice: TopChatMenuChoice.searchAllMessages,
        chosenContactId: null,
        selectedHandleId: null,
        scrollToDate: null,
        messageScope: SidebarFlowMessageScope.regular,
      ),
    );
  }

  void showGlobalTimelineAt(DateTime? scrollToDate) {
    _setStateAndClearRightIfNeeded(
      state.copyWith(
        topMenuChoice: TopChatMenuChoice.searchAllMessages,
        chosenContactId: null,
        selectedHandleId: null,
        scrollToDate: scrollToDate,
        messageScope: SidebarFlowMessageScope.regular,
      ),
    );
  }

  void showContactTimelineAt({required int contactId, DateTime? scrollToDate}) {
    _setStateAndClearRightIfNeeded(
      state.copyWith(
        topMenuChoice: TopChatMenuChoice.contacts,
        chosenContactId: contactId,
        scrollToDate: scrollToDate,
        messageScope: SidebarFlowMessageScope.regular,
      ),
    );
  }

  void showRecoveredDeletedAt({
    required int? contactId,
    required DateTime startDate,
  }) {
    _setStateAndClearRightIfNeeded(
      state.copyWith(
        topMenuChoice: contactId == null
            ? TopChatMenuChoice.recoveredUnlinkedMessages
            : TopChatMenuChoice.contacts,
        chosenContactId: contactId,
        selectedHandleId: null,
        scrollToDate: startDate,
        messageScope: SidebarFlowMessageScope.recoveredDeleted,
      ),
    );
  }
}
