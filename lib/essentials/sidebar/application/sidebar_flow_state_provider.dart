import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../features/sidebar_utilities/feature_level_providers.dart';
import '../../navigation/domain/entities/view_spec.dart';
import '../../navigation/domain/navigation_constants.dart';
import '../../navigation/domain/sidebar_mode.dart';
import '../../navigation/feature_level_providers.dart';
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

  void topMenuChanged({
    required TopChatMenuChoice choice,
    required int cassetteIndex,
  }) {
    state = switch (choice) {
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
    };

    final newSpec = CassetteSpec.sidebarUtility(
      SidebarUtilityCassetteSpec.topChatMenu(selectedChoice: choice),
    );

    ref
        .read(cassetteRackStateProvider(SidebarMode.messages).notifier)
        .replaceAtIndexAndCascade(cassetteIndex, newSpec);

    _syncProjectedCenterPanel();
  }

  void contactChosen({required int contactId, required int infoCardIndex}) {
    state = state.copyWith(
      topMenuChoice: TopChatMenuChoice.contacts,
      chosenContactId: contactId,
      selectedHandleId: null,
      messageScope: SidebarFlowMessageScope.regular,
    );

    final newSpec = CassetteSpec.contacts(
      ContactsCassetteSpec.contactHeroSummary(chosenContactId: contactId),
    );

    ref
        .read(cassetteRackStateProvider(SidebarMode.messages).notifier)
        .replaceAtIndexAndCascade(infoCardIndex, newSpec);

    _syncProjectedCenterPanel();
  }

  void chooseAnotherContact({required int infoCardIndex}) {
    state = state.copyWith(
      chosenContactId: null,
      selectedHandleId: null,
      messageScope: SidebarFlowMessageScope.regular,
    );

    const newSpec = CassetteSpec.contactsInfo(
      ContactsInfoCassetteSpec.infoCard(
        key: ContactsInfoKey.pickerContentSources,
      ),
    );

    ref
        .read(cassetteRackStateProvider(SidebarMode.messages).notifier)
        .replaceAtIndexAndCascade(infoCardIndex, newSpec);

    _syncProjectedCenterPanel();
  }

  void handleSelected({
    required int contactId,
    required int? handleId,
    required int cassetteIndex,
  }) {
    state = state.copyWith(
      topMenuChoice: TopChatMenuChoice.contacts,
      chosenContactId: contactId,
      selectedHandleId: handleId,
      messageScope: SidebarFlowMessageScope.regular,
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

    _syncProjectedCenterPanel();
  }

  void setContactMessageScope({
    required int contactId,
    required SidebarFlowMessageScope messageScope,
  }) {
    if (messageScope == SidebarFlowMessageScope.regular) {
      state = state.copyWith(
        topMenuChoice: TopChatMenuChoice.contacts,
        chosenContactId: contactId,
        scrollToDate: null,
        messageScope: SidebarFlowMessageScope.regular,
      );

      _syncProjectedCenterPanel();
      return;
    }

    state = state.copyWith(
      topMenuChoice: TopChatMenuChoice.contacts,
      chosenContactId: contactId,
      selectedHandleId: null,
      scrollToDate: null,
      messageScope: SidebarFlowMessageScope.recoveredDeleted,
    );

    _syncProjectedCenterPanel();
  }

  void showRecoveredDeletedForContact({
    required int contactId,
    required int heroCassetteIndex,
  }) {
    state = state.copyWith(
      topMenuChoice: TopChatMenuChoice.contacts,
      chosenContactId: contactId,
      selectedHandleId: null,
      messageScope: SidebarFlowMessageScope.recoveredDeleted,
    );

    final heroSpec = CassetteSpec.contacts(
      ContactsCassetteSpec.contactHeroSummary(chosenContactId: contactId),
    );

    ref
        .read(cassetteRackStateProvider(SidebarMode.messages).notifier)
        .replaceAtIndexAndCascade(heroCassetteIndex, heroSpec);

    _syncProjectedCenterPanel();
  }

  void showGlobalRecoveredDeleted() {
    state = state.copyWith(
      topMenuChoice: TopChatMenuChoice.recoveredUnlinkedMessages,
      chosenContactId: null,
      selectedHandleId: null,
      scrollToDate: null,
      messageScope: SidebarFlowMessageScope.recoveredDeleted,
    );

    _syncProjectedCenterPanel();
  }

  void showRecoveredNoHandleFromMe({DateTime? scrollToDate}) {
    state = state.copyWith(
      topMenuChoice: TopChatMenuChoice.recoveredNoHandleFromMeMessages,
      chosenContactId: null,
      selectedHandleId: null,
      scrollToDate: scrollToDate,
      messageScope: SidebarFlowMessageScope.regular,
    );

    _syncProjectedCenterPanel();
  }

  void showGlobalTimeline() {
    state = state.copyWith(
      topMenuChoice: TopChatMenuChoice.searchAllMessages,
      chosenContactId: null,
      selectedHandleId: null,
      scrollToDate: null,
      messageScope: SidebarFlowMessageScope.regular,
    );

    _syncProjectedCenterPanel();
  }

  void showGlobalTimelineAt(DateTime? scrollToDate) {
    state = state.copyWith(
      topMenuChoice: TopChatMenuChoice.searchAllMessages,
      chosenContactId: null,
      selectedHandleId: null,
      scrollToDate: scrollToDate,
      messageScope: SidebarFlowMessageScope.regular,
    );

    _syncProjectedCenterPanel();
  }

  void showContactTimelineAt({required int contactId, DateTime? scrollToDate}) {
    state = state.copyWith(
      topMenuChoice: TopChatMenuChoice.contacts,
      chosenContactId: contactId,
      scrollToDate: scrollToDate,
      messageScope: SidebarFlowMessageScope.regular,
    );

    _syncProjectedCenterPanel();
  }

  void showRecoveredDeletedAt({
    required int? contactId,
    required DateTime startDate,
  }) {
    state = state.copyWith(
      topMenuChoice: contactId == null
          ? TopChatMenuChoice.recoveredUnlinkedMessages
          : TopChatMenuChoice.contacts,
      chosenContactId: contactId,
      selectedHandleId: null,
      scrollToDate: startDate,
      messageScope: SidebarFlowMessageScope.recoveredDeleted,
    );

    _syncProjectedCenterPanel();
  }

  void _syncProjectedCenterPanel() {
    final projectedCenterSpec = state.projectedCenterSpec;
    final panelsNotifier = ref.read(
      panelsViewStateProvider(SidebarMode.messages).notifier,
    );

    if (projectedCenterSpec == null) {
      _clearPanels();
      return;
    }

    final currentCenterSpec = ref.read(
      panelsViewStateProvider(
        SidebarMode.messages,
      ).select((stacks) => stacks[WindowPanel.center]?.activePage?.spec),
    );

    if (currentCenterSpec == projectedCenterSpec) {
      return;
    }

    panelsNotifier.show(panel: WindowPanel.center, spec: projectedCenterSpec);
  }

  void _clearPanels() {
    final panelState = ref.read(panelsViewStateProvider(SidebarMode.messages));
    final centerIsEmpty = panelState[WindowPanel.center]?.isEmpty ?? true;
    final rightIsEmpty = panelState[WindowPanel.right]?.isEmpty ?? true;
    if (centerIsEmpty && rightIsEmpty) {
      return;
    }

    final panels = ref.read(
      panelsViewStateProvider(SidebarMode.messages).notifier,
    );
    panels.clear(panel: WindowPanel.right);
    panels.clear(panel: WindowPanel.center);
  }
}
