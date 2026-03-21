import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../features/contacts/domain/spec_classes/contacts_settings_spec.dart';
import '../../../features/handles/application/state/stray_handle_mode_provider.dart';
import '../../../features/handles/domain/spec_classes/handles_cassette_spec.dart';
import '../../../features/handles/infrastructure/repositories/stray_handles_provider.dart';
import '../../../features/sidebar_utilities/domain/sidebar_utilities_constants.dart';
import '../../../features/sidebar_utilities/domain/spec_classes/sidebar_utility_cassette_spec.dart';
import '../../db/feature_level_providers.dart';
import '../../logging/application/app_logger.dart';
import '../../logging/infrastructure/log_export_service.dart';
import '../../navigation/domain/entities/view_spec.dart';
import '../../navigation/domain/navigation_constants.dart';
import '../../navigation/domain/sidebar_mode.dart';
import '../../navigation/feature_level_providers.dart';
import '../../onboarding/application/onboarding_gate_provider.dart';
import '../domain/entities/cassette_spec.dart';
import '../domain/sidebar_action_intent.dart';
import '../feature_level_providers.dart';

part 'sidebar_action_dispatcher.g.dart';

class SidebarActionDispatchContext {
  const SidebarActionDispatchContext({
    required this.sidebarMode,
    this.cassetteIndex,
  });

  final SidebarMode sidebarMode;
  final int? cassetteIndex;
}

@riverpod
class SidebarActionDispatcher extends _$SidebarActionDispatcher {
  @override
  void build() {
    // Stateless dispatcher.
  }

  Future<void> dispatch({
    required SidebarActionIntent intent,
    required SidebarActionDispatchContext context,
  }) async {
    switch (intent) {
      case TopMenuChanged(:final choice):
        ref
            .read(sidebarFlowProvider.notifier)
            .topMenuChanged(
              choice: _mapTopMenuChoice(choice),
              cassetteIndex: _requireCassetteIndex(context),
            );
      case SettingsMenuChanged(:final choice):
        _replaceCassetteAtContext(
          context: context,
          spec: CassetteSpec.sidebarUtility(
            SidebarUtilityCassetteSpec.settingsMenu(
              selectedChoice: _mapSettingsMenuChoice(choice),
            ),
          ),
        );
      case SettingsActionChosen(:final choice):
        _replaceCassetteAtContext(
          context: context,
          spec: CassetteSpec.contactsSettings(
            ContactsSettingsSpec.actionsMenu(
              selectedChoice: _mapSettingsActionChoice(choice),
            ),
          ),
        );
      case ContactChosen(:final contactId):
        ref
            .read(sidebarFlowProvider.notifier)
            .contactChosen(
              contactId: contactId,
              infoCardIndex: _requireCassetteIndex(context),
            );
      case ChooseAnotherContact():
        ref
            .read(sidebarFlowProvider.notifier)
            .chooseAnotherContact(
              infoCardIndex: _requireCassetteIndex(context),
            );
      case ContactHandleSelected(:final contactId, :final handleId):
        ref
            .read(sidebarFlowProvider.notifier)
            .handleSelected(
              contactId: contactId,
              handleId: handleId,
              cassetteIndex: _requireCassetteIndex(context),
            );
      case ContactMessageScopeChanged(:final contactId, :final scope):
        ref
            .read(sidebarFlowProvider.notifier)
            .setContactMessageScope(
              contactId: contactId,
              messageScope: _mapMessageScope(scope),
            );
      case HeatMapMonthFocused(:final monthAnchor, :final contactId):
        _dispatchHeatMapFocus(contactId: contactId, monthAnchor: monthAnchor);
      case RecoveredMonthFocused(
        :final monthAnchor,
        :final contactId,
        :final onlyNoHandleFromMe,
      ):
        _dispatchRecoveredMonthFocus(
          contactId: contactId,
          monthAnchor: monthAnchor,
          onlyNoHandleFromMe: onlyNoHandleFromMe,
        );
      case StrayHandleFilterChanged(:final filter):
        _replaceCassetteAtContext(
          context: context,
          spec: CassetteSpec.handles(
            HandlesCassetteSpec.strayHandlesTypeSwitcher(
              selectedFilter: _mapStrayHandleFilter(filter),
            ),
          ),
        );
      case StrayHandleModeChanged(:final mode):
        ref
            .read(strayHandleModeSettingProvider.notifier)
            .setMode(_mapStrayHandleMode(mode));
      case StrayHandleOpened(:final handleId):
        ref
            .read(panelsViewStateProvider(context.sidebarMode).notifier)
            .show(
              panel: WindowPanel.center,
              spec: ViewSpec.messages(
                MessagesSpec.handleLens(handleId: handleId),
              ),
            );
      case StrayHandleDismissed(:final normalizedHandle):
        await _dismissHandle(normalizedHandle);
      case StrayHandleRestored(:final normalizedHandle):
        await _restoreHandle(normalizedHandle);
      case ReimportDataRequested():
        await ref.read(onboardingGateProvider.notifier).startReimport();
      case SendLogsRequested():
        final writer = ref.read(appLoggerProvider.notifier).writer;
        LogExportService(writer).exportAndPresent();
    }
  }

  void _dispatchHeatMapFocus({
    required int? contactId,
    required DateTime monthAnchor,
  }) {
    if (contactId == null) {
      ref.read(sidebarFlowProvider.notifier).showGlobalTimelineAt(monthAnchor);
      return;
    }

    ref
        .read(sidebarFlowProvider.notifier)
        .showContactTimelineAt(contactId: contactId, scrollToDate: monthAnchor);
  }

  void _dispatchRecoveredMonthFocus({
    required int? contactId,
    required DateTime monthAnchor,
    required bool onlyNoHandleFromMe,
  }) {
    if (onlyNoHandleFromMe) {
      ref
          .read(sidebarFlowProvider.notifier)
          .showRecoveredNoHandleFromMe(scrollToDate: monthAnchor);
      return;
    }

    ref
        .read(sidebarFlowProvider.notifier)
        .showRecoveredDeletedAt(contactId: contactId, startDate: monthAnchor);
  }

  Future<void> _dismissHandle(String normalizedHandle) async {
    final overlayDb = await ref.read(overlayDatabaseProvider.future);
    await overlayDb.dismissHandle(normalizedHandle);
    _invalidateStrayHandleProviders();
  }

  Future<void> _restoreHandle(String normalizedHandle) async {
    final overlayDb = await ref.read(overlayDatabaseProvider.future);
    await overlayDb.restoreHandle(normalizedHandle);
    _invalidateStrayHandleProviders();
  }

  void _invalidateStrayHandleProviders() {
    ref.invalidate(strayHandlesProvider);
    ref.invalidate(spamCandidateHandlesProvider);
    ref.invalidate(dismissedHandlesProvider);
  }

  void _replaceCassetteAtContext({
    required SidebarActionDispatchContext context,
    required CassetteSpec spec,
  }) {
    ref
        .read(cassetteRackStateProvider(context.sidebarMode).notifier)
        .replaceAtIndexAndCascade(_requireCassetteIndex(context), spec);
  }

  int _requireCassetteIndex(SidebarActionDispatchContext context) {
    final cassetteIndex = context.cassetteIndex;
    if (cassetteIndex == null) {
      throw StateError('Sidebar action requires a cassette index.');
    }
    return cassetteIndex;
  }
}

TopChatMenuChoice _mapTopMenuChoice(SidebarTopMenuChoice choice) {
  return switch (choice) {
    SidebarTopMenuChoice.contacts => TopChatMenuChoice.contacts,
    SidebarTopMenuChoice.strayHandles => TopChatMenuChoice.strayHandles,
    SidebarTopMenuChoice.searchAllMessages =>
      TopChatMenuChoice.searchAllMessages,
    SidebarTopMenuChoice.recoveredUnlinkedMessages =>
      TopChatMenuChoice.recoveredUnlinkedMessages,
    SidebarTopMenuChoice.recoveredNoHandleFromMeMessages =>
      TopChatMenuChoice.recoveredNoHandleFromMeMessages,
  };
}

SettingsMenuChoice _mapSettingsMenuChoice(SidebarSettingsMenuChoice choice) {
  return switch (choice) {
    SidebarSettingsMenuChoice.actions => SettingsMenuChoice.actions,
  };
}

ActionsMenuChoice _mapSettingsActionChoice(SidebarSettingsActionChoice choice) {
  return switch (choice) {
    SidebarSettingsActionChoice.sendLogs => ActionsMenuChoice.sendLogs,
    SidebarSettingsActionChoice.reimportData => ActionsMenuChoice.reimportData,
  };
}

SidebarFlowMessageScope _mapMessageScope(SidebarMessageScope scope) {
  return switch (scope) {
    SidebarMessageScope.regular => SidebarFlowMessageScope.regular,
    SidebarMessageScope.recoveredDeleted =>
      SidebarFlowMessageScope.recoveredDeleted,
  };
}

StrayHandleFilter _mapStrayHandleFilter(SidebarStrayHandleFilter filter) {
  return switch (filter) {
    SidebarStrayHandleFilter.phones => StrayHandleFilter.phones,
    SidebarStrayHandleFilter.emails => StrayHandleFilter.emails,
    SidebarStrayHandleFilter.businessUrns => StrayHandleFilter.businessUrns,
  };
}

StrayHandleMode _mapStrayHandleMode(SidebarStrayHandleMode mode) {
  return switch (mode) {
    SidebarStrayHandleMode.allStrays => StrayHandleMode.allStrays,
    SidebarStrayHandleMode.spamCandidates => StrayHandleMode.spamCandidates,
    SidebarStrayHandleMode.dismissed => StrayHandleMode.dismissed,
  };
}
