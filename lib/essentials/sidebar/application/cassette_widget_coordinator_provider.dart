import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../features/contacts/feature_level_providers.dart'
    as contacts_feature;
import '../../../features/handles/feature_level_providers.dart'
    as handles_feature;
import '../../../features/messages/feature_level_providers.dart'
    as messages_feature;
import '../../../features/sidebar_utilities/feature_level_providers.dart'
    as sidebar_utilities;
import '../../navigation/domain/sidebar_mode.dart';
import '../feature_level_providers.dart';
import '../presentation/view/sidebar_info_card.dart';
import '../presentation/view/sidebar_navigation_card.dart';
import '../presentation/view_model/sidebar_cassette_card_view_model.dart';
import 'sidebar_cassette_sectioning.dart';

/// utility widgets to wrap each cassette in a card

part 'cassette_widget_coordinator_provider.g.dart';

@riverpod
class CassetteWidgetCoordinator extends _$CassetteWidgetCoordinator {
  /// NOTE: This is now async because feature-side spec handling may require
  /// repositories/data access (counts, derived values, etc.).
  ///
  /// This means the provider becomes an AsyncValue<List<Widget>> at call sites.
  @override
  Future<List<Widget>> build(SidebarMode mode) async {
    final rack = ref.watch(cassetteRackStateProvider(mode));
    final flowState = mode == SidebarMode.messages
        ? ref.watch(sidebarFlowProvider)
        : null;
    final widgets = <Widget>[];
    SidebarCassetteSection? previousSection;

    /// Build a view model for a given cassette spec by routing to the owning feature.
    ///
    /// IMPORTANT:
    /// Every branch returns a Future, even if the underlying coordinator is sync.
    /// This avoids mixed return types inside `spec.when(...)`.
    ///
    /// The [cassetteIndex] is passed to feature coordinators so widgets can
    /// update the rack without holding specs in state.
    Future<SidebarCassettePayload> buildViewModelForSpec(
      CassetteSpec spec, {
      required int cassetteIndex,
    }) {
      return spec.when(
        sidebarUtility: (sidebarSpec) async {
          final coordinator = ref.read(
            sidebar_utilities
                .sidebarUtilitiesCassetteCoordinatorProvider
                .notifier,
          );
          return coordinator.buildViewModel(
            sidebarSpec,
            cassetteIndex: cassetteIndex,
          );
        },
        contacts: (contactsSpec) async {
          final coordinator = ref.read(
            contacts_feature.contactsCassetteCoordinatorProvider.notifier,
          );
          return coordinator.buildViewModel(
            contactsSpec,
            cassetteIndex: cassetteIndex,
          );
        },
        contactsSettings: (settingsSpec) async {
          final coordinator = ref.read(
            contacts_feature.contactsSettingsCoordinatorProvider.notifier,
          );
          return coordinator.buildViewModel(
            settingsSpec,
            cassetteIndex: cassetteIndex,
          );
        },
        contactsInfo: (infoSpec) async {
          final coordinator = ref.read(
            contacts_feature.contactsInfoCassetteCoordinatorProvider.notifier,
          );
          return coordinator.buildViewModel(
            infoSpec,
            cassetteIndex: cassetteIndex,
          );
        },
        handles: (handlesSpec) async {
          handlesSpec.maybeMap(
            strayHandlesReview: (_) {
              ref.watch(handles_feature.strayHandleModeSettingProvider);
              return null;
            },
            orElse: () {
              return null;
            },
          );

          final coordinator = ref.read(
            handles_feature.handlesCassetteCoordinatorProvider.notifier,
          );
          return coordinator.buildViewModel(
            handlesSpec,
            cassetteIndex: cassetteIndex,
          );
        },
        handlesInfo: (handlesInfoSpec) async {
          final coordinator = ref.read(
            handles_feature.handlesInfoCassetteCoordinatorProvider.notifier,
          );
          return coordinator.buildViewModel(
            handlesInfoSpec,
            cassetteIndex: cassetteIndex,
          );
        },
        messages: (messagesSpec) async {
          final coordinator = ref.read(
            messages_feature.messagesCassetteCoordinatorProvider.notifier,
          );
          return coordinator.buildViewModel(
            messagesSpec,
            cassetteIndex: cassetteIndex,
          );
        },
        messagesInfo: (messagesInfoSpec) async {
          final coordinator = ref.read(
            messages_feature.messagesInfoCassetteCoordinatorProvider.notifier,
          );
          return coordinator.buildViewModel(
            messagesInfoSpec,
            cassetteIndex: cassetteIndex,
          );
        },
      );
    }

    /// Convert a view model into a concrete widget and append it to the list.
    ///
    /// This is async because it awaits buildViewModelForSpec(spec).
    Future<void> addCassette(
      CassetteSpec spec, {
      required int cassetteIndex,
    }) async {
      final payload = await buildViewModelForSpec(
        spec,
        cassetteIndex: cassetteIndex,
      );

      Widget widget;

      switch (payload) {
        case SidebarCassetteCardViewModel():
          widget = SidebarCassetteCard(
            title: payload.title,
            subtitle: payload.subtitle,
            sectionTitle: payload.sectionTitle,
            footerText: payload.footerText,
            isNaked: payload.isNaked,
            shouldExpand: payload.shouldExpand,
            role: payload.role,
            placementMode: payload.placementMode,
            contentAlignment: payload.contentAlignment,
            layoutStyle: payload.layoutStyle,
            child: payload.child,
          );
        case SidebarInfoCassetteViewModel():
          widget = SidebarInfoCard(
            title: payload.title,
            bodyText: payload.bodyText,
            footnote: payload.footnote,
            content: payload.content,
          );
        case SidebarNavigationCassetteViewModel():
          widget = SidebarNavigationCard(
            placementMode: payload.placementMode,
            contentAlignment: payload.contentAlignment,
            child: payload.child,
          );
      }

      if (payload.topSpacing > 0) {
        widget = Padding(
          padding: EdgeInsets.only(top: payload.topSpacing),
          child: widget,
        );
      }

      final currentSection = sidebarCassetteSectionForRole(payload.role);
      final sectionTopSpacing = sidebarCassetteSectionTopSpacing(
        previousSection: previousSection,
        currentSection: currentSection,
      );

      if (sectionTopSpacing > 0) {
        widget = Padding(
          padding: EdgeInsets.only(top: sectionTopSpacing),
          child: widget,
        );
      }

      widgets.add(widget);
      previousSection = currentSection;
    }

    // Build widgets for the explicit rack cassettes.
    for (var i = 0; i < rack.cassettes.length; i++) {
      final spec = rack.cassettes[i];
      if (_shouldHideSpecForFlow(spec: spec, flowState: flowState)) {
        continue;
      }

      await addCassette(spec, cassetteIndex: i);
    }

    return widgets;
  }
}

bool _shouldHideSpecForFlow({
  required CassetteSpec spec,
  required SidebarFlowState? flowState,
}) {
  if (flowState == null) {
    return false;
  }

  if (!flowState.isContactsBranch ||
      flowState.messageScope != SidebarFlowMessageScope.recoveredDeleted) {
    return false;
  }

  return spec.maybeWhen(
    messages: (messagesSpec) {
      return messagesSpec.maybeWhen(
        heatMap: (contactId) {
          return contactId != null;
        },
        orElse: () {
          return false;
        },
      );
    },
    orElse: () {
      return false;
    },
  );
}
