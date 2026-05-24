import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../features/messages/domain/spec_classes/messages_view_spec.dart';
import '../../../features/settings/domain/spec_classes/settings_view_spec.dart';
import '../../../features/sidebar_utilities/domain/sidebar_utilities_constants.dart';
import '../../../features/sidebar_utilities/feature_level_providers.dart';
import '../../logging/application/app_logger.dart';
import '../../navigation/domain/entities/view_spec.dart';
import '../../navigation/domain/sidebar_mode.dart';
import '../feature_level_providers.dart';

part 'sidebar_flow_state_provider.freezed.dart';
part 'sidebar_flow_state_provider.g.dart';

enum SidebarFlowMessageScope { regular, recoveredDeleted }

enum SidebarFlowContactProjection { allMessages, conversations }

@visibleForTesting
void debugAssertValidSidebarFlowState(SidebarFlowState state) {
  final persistentSettingsContext = state.persistentSettingsContext;
  if (persistentSettingsContext != null &&
      !persistentSettingsContext.isPersistentContext) {
    throw StateError(
      'SidebarFlowState.persistentSettingsContext cannot hold transient '
      'settings actions.',
    );
  }

  switch (state.topMenuChoice) {
    case TopChatMenuChoice.conversations:
      if (state.chosenContactId != null || state.selectedHandleId != null) {
        throw StateError(
          'Conversations branch cannot retain contact-specific selection '
          'state.',
        );
      }

      if (state.messageScope != SidebarFlowMessageScope.regular) {
        throw StateError(
          'Conversations branch must remain in regular message scope.',
        );
      }

      if (state.contactProjection != SidebarFlowContactProjection.allMessages) {
        throw StateError(
          'Conversations branch cannot retain contact projection state.',
        );
      }

    case TopChatMenuChoice.contacts:
      if (state.selectedHandleId != null && state.chosenContactId == null) {
        throw StateError(
          'SidebarFlowState.selectedHandleId requires a chosen contact on '
          'the contacts branch.',
        );
      }

      if (state.messageScope == SidebarFlowMessageScope.recoveredDeleted &&
          state.chosenContactId == null) {
        throw StateError(
          'Recovered contact scope requires a chosen contact on the contacts '
          'branch.',
        );
      }

      if (state.messageScope == SidebarFlowMessageScope.recoveredDeleted &&
          state.selectedHandleId != null) {
        throw StateError(
          'Recovered contact scope cannot retain a selected handle filter.',
        );
      }

      if (state.messageScope == SidebarFlowMessageScope.recoveredDeleted &&
          state.contactProjection != SidebarFlowContactProjection.allMessages) {
        throw StateError(
          'Recovered contact scope cannot use conversation projection mode.',
        );
      }

    case TopChatMenuChoice.strayHandles:
      if (state.chosenContactId != null || state.selectedHandleId != null) {
        throw StateError(
          'Stray handles branch cannot retain contact-specific selection '
          'state.',
        );
      }

      if (state.messageScope != SidebarFlowMessageScope.regular) {
        throw StateError(
          'Stray handles branch must remain in regular message scope.',
        );
      }

      if (state.contactProjection != SidebarFlowContactProjection.allMessages) {
        throw StateError(
          'Stray handles branch cannot retain contact projection state.',
        );
      }

    case TopChatMenuChoice.searchAllMessages:
      if (state.chosenContactId != null || state.selectedHandleId != null) {
        throw StateError(
          'Global timeline branch cannot retain contact-specific selection '
          'state.',
        );
      }

      if (state.messageScope != SidebarFlowMessageScope.regular) {
        throw StateError(
          'Global timeline branch must remain in regular message scope.',
        );
      }

      if (state.contactProjection != SidebarFlowContactProjection.allMessages) {
        throw StateError(
          'Global timeline branch cannot retain contact projection state.',
        );
      }

    case TopChatMenuChoice.recoveredUnlinkedMessages:
      if (state.chosenContactId != null || state.selectedHandleId != null) {
        throw StateError(
          'Global recovered branch cannot retain contact-specific selection '
          'state.',
        );
      }

      if (state.messageScope != SidebarFlowMessageScope.recoveredDeleted) {
        throw StateError(
          'Global recovered branch must remain in recoveredDeleted scope.',
        );
      }

      if (state.contactProjection != SidebarFlowContactProjection.allMessages) {
        throw StateError(
          'Global recovered branch cannot retain contact projection state.',
        );
      }

    case TopChatMenuChoice.recoveredNoHandleFromMeMessages:
      if (state.chosenContactId != null || state.selectedHandleId != null) {
        throw StateError(
          'Recovered no-handle branch cannot retain contact-specific '
          'selection state.',
        );
      }

      if (state.messageScope != SidebarFlowMessageScope.regular) {
        throw StateError(
          'Recovered no-handle branch must remain in regular message scope.',
        );
      }

      if (state.contactProjection != SidebarFlowContactProjection.allMessages) {
        throw StateError(
          'Recovered no-handle branch cannot retain contact projection state.',
        );
      }
  }
}

@freezed
abstract class SidebarFlowState with _$SidebarFlowState {
  const factory SidebarFlowState({
    @Default(defaultTopChatMenuChoice) TopChatMenuChoice topMenuChoice,
    int? chosenContactId,
    int? selectedHandleId,
    SettingsMenuActionId? persistentSettingsContext,
    DateTime? scrollToDate,
    @Default(SidebarFlowMessageScope.regular)
    SidebarFlowMessageScope messageScope,
    @Default(SidebarFlowContactProjection.allMessages)
    SidebarFlowContactProjection contactProjection,
  }) = _SidebarFlowState;

  const SidebarFlowState._();

  bool get isContactsBranch {
    return topMenuChoice == TopChatMenuChoice.contacts;
  }

  ViewSpec? get projectedCenterSpec {
    assert(() {
      debugAssertValidSidebarFlowState(this);
      return true;
    }());

    switch (topMenuChoice) {
      case TopChatMenuChoice.conversations:
        return const ViewSpec.messages(MessagesSpec.conversationBrowser());
      case TopChatMenuChoice.contacts:
        final contactId = chosenContactId;
        if (contactId == null) {
          return null;
        }

        switch (messageScope) {
          case SidebarFlowMessageScope.regular:
            if (contactProjection ==
                SidebarFlowContactProjection.conversations) {
              return null;
            }
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

  ViewSpec? get projectedSettingsCenterSpec {
    assert(() {
      debugAssertValidSidebarFlowState(this);
      return true;
    }());

    return switch (persistentSettingsContext) {
      SettingsMenuActionId.historicalArchives => const ViewSpec.settings(
        SettingsViewSpec.historicalArchivesWorkflow(),
      ),
      SettingsMenuActionId.messageHistoryCoverage => const ViewSpec.settings(
        SettingsViewSpec.messageHistoryCoverageReport(),
      ),
      SettingsMenuActionId.textSize ||
      SettingsMenuActionId.imageSize ||
      SettingsMenuActionId.sendLogs ||
      SettingsMenuActionId.resetMessageData ||
      null => null,
    };
  }

  ViewSpec? projectedCenterSpecForMode(SidebarMode mode) {
    return switch (mode) {
      SidebarMode.messages => projectedCenterSpec,
      SidebarMode.settings => projectedSettingsCenterSpec,
    };
  }
}

@riverpod
class SidebarFlow extends _$SidebarFlow {
  @override
  SidebarFlowState build() {
    const initialState = SidebarFlowState();
    assert(() {
      debugAssertValidSidebarFlowState(initialState);
      return true;
    }());
    return initialState;
  }

  void _setState(SidebarFlowState nextState) {
    assert(() {
      debugAssertValidSidebarFlowState(nextState);
      return true;
    }());

    state = nextState;
  }

  void topMenuChanged({
    required TopChatMenuChoice choice,
    required int cassetteIndex,
  }) {
    _setState(switch (choice) {
      TopChatMenuChoice.conversations => const SidebarFlowState(
        topMenuChoice: TopChatMenuChoice.conversations,
      ),
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
    _setState(
      state.copyWith(
        topMenuChoice: TopChatMenuChoice.contacts,
        chosenContactId: contactId,
        selectedHandleId: null,
        messageScope: SidebarFlowMessageScope.regular,
        contactProjection: SidebarFlowContactProjection.allMessages,
      ),
    );

    final newSpec = CassetteSpec.contacts(
      ContactsCassetteSpec.contactSelectionControl(chosenContactId: contactId),
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

    _setState(
      state.copyWith(
        chosenContactId: null,
        selectedHandleId: null,
        messageScope: SidebarFlowMessageScope.regular,
        contactProjection: SidebarFlowContactProjection.allMessages,
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
    _setState(
      state.copyWith(
        topMenuChoice: TopChatMenuChoice.contacts,
        chosenContactId: contactId,
        selectedHandleId: handleId,
        messageScope: SidebarFlowMessageScope.regular,
        contactProjection: SidebarFlowContactProjection.allMessages,
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
    required int cassetteIndex,
  }) {
    if (messageScope == SidebarFlowMessageScope.regular) {
      _setState(
        state.copyWith(
          topMenuChoice: TopChatMenuChoice.contacts,
          chosenContactId: contactId,
          scrollToDate: null,
          messageScope: SidebarFlowMessageScope.regular,
          contactProjection: SidebarFlowContactProjection.allMessages,
        ),
      );
      ref
          .read(cassetteRackStateProvider(SidebarMode.messages).notifier)
          .replaceAtIndexAndCascade(
            cassetteIndex,
            CassetteSpec.contacts(
              ContactsCassetteSpec.messageScopeToggle(contactId: contactId),
            ),
          );
      return;
    }

    _setState(
      state.copyWith(
        topMenuChoice: TopChatMenuChoice.contacts,
        chosenContactId: contactId,
        selectedHandleId: null,
        scrollToDate: null,
        messageScope: SidebarFlowMessageScope.recoveredDeleted,
        contactProjection: SidebarFlowContactProjection.allMessages,
      ),
    );

    ref
        .read(cassetteRackStateProvider(SidebarMode.messages).notifier)
        .replaceAtIndexAndCascade(
          cassetteIndex,
          CassetteSpec.contacts(
            ContactsCassetteSpec.messageScopeToggle(contactId: contactId),
          ),
        );
  }

  void showGlobalRecoveredDeleted() {
    _setState(
      state.copyWith(
        topMenuChoice: TopChatMenuChoice.recoveredUnlinkedMessages,
        chosenContactId: null,
        selectedHandleId: null,
        scrollToDate: null,
        messageScope: SidebarFlowMessageScope.recoveredDeleted,
        contactProjection: SidebarFlowContactProjection.allMessages,
      ),
    );
  }

  void showRecoveredNoHandleFromMe({DateTime? scrollToDate}) {
    _setState(
      state.copyWith(
        topMenuChoice: TopChatMenuChoice.recoveredNoHandleFromMeMessages,
        chosenContactId: null,
        selectedHandleId: null,
        scrollToDate: scrollToDate,
        messageScope: SidebarFlowMessageScope.regular,
        contactProjection: SidebarFlowContactProjection.allMessages,
      ),
    );
  }

  void showContactConversationNavigator({required int contactId}) {
    _setState(
      state.copyWith(
        topMenuChoice: TopChatMenuChoice.contacts,
        chosenContactId: contactId,
        selectedHandleId: null,
        scrollToDate: null,
        messageScope: SidebarFlowMessageScope.regular,
        contactProjection: SidebarFlowContactProjection.conversations,
      ),
    );
  }

  void showGlobalTimeline() {
    _setState(
      state.copyWith(
        topMenuChoice: TopChatMenuChoice.searchAllMessages,
        chosenContactId: null,
        selectedHandleId: null,
        scrollToDate: null,
        messageScope: SidebarFlowMessageScope.regular,
        contactProjection: SidebarFlowContactProjection.allMessages,
      ),
    );
  }

  void showGlobalTimelineAt(DateTime? scrollToDate) {
    _setState(
      state.copyWith(
        topMenuChoice: TopChatMenuChoice.searchAllMessages,
        chosenContactId: null,
        selectedHandleId: null,
        scrollToDate: scrollToDate,
        messageScope: SidebarFlowMessageScope.regular,
        contactProjection: SidebarFlowContactProjection.allMessages,
      ),
    );
  }

  void showContactTimelineAt({required int contactId, DateTime? scrollToDate}) {
    _setState(
      state.copyWith(
        topMenuChoice: TopChatMenuChoice.contacts,
        chosenContactId: contactId,
        selectedHandleId: null,
        scrollToDate: scrollToDate,
        messageScope: SidebarFlowMessageScope.regular,
        contactProjection: SidebarFlowContactProjection.allMessages,
      ),
    );
  }

  void showConversationContext() {
    _setState(
      const SidebarFlowState(topMenuChoice: TopChatMenuChoice.conversations),
    );
  }

  void showRecoveredDeletedAt({
    required int? contactId,
    required DateTime startDate,
  }) {
    _setState(
      state.copyWith(
        topMenuChoice: contactId == null
            ? TopChatMenuChoice.recoveredUnlinkedMessages
            : TopChatMenuChoice.contacts,
        chosenContactId: contactId,
        selectedHandleId: null,
        scrollToDate: startDate,
        messageScope: SidebarFlowMessageScope.recoveredDeleted,
        contactProjection: SidebarFlowContactProjection.allMessages,
      ),
    );
  }

  void setPersistentSettingsContext(SettingsMenuActionId? actionId) {
    _setState(state.copyWith(persistentSettingsContext: actionId));
  }
}
