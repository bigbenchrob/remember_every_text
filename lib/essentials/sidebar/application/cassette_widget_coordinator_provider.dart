import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../features/contacts/feature_level_providers.dart'
    as contacts_feature;
import '../../../features/handles/feature_level_providers.dart'
    as handles_feature;
import '../../../features/messages/feature_level_providers.dart'
    as messages_feature;
import '../../../features/settings/feature_level_providers.dart'
    as settings_feature;
import '../../../features/sidebar_utilities/feature_level_providers.dart'
    as sidebar_utilities;
import '../../navigation/domain/sidebar_mode.dart';
import '../feature_level_providers.dart';
import '../presentation/view_model/sidebar_cassette_card_view_model.dart';
import 'renderable_sidebar_cassette_specs_provider.dart';
import 'sidebar_cassette_sectioning.dart';

part 'cassette_widget_coordinator_provider.g.dart';

final class SidebarCassetteResolutionError {
  const SidebarCassetteResolutionError({
    required this.error,
    required this.stackTrace,
  });

  final Object error;
  final StackTrace? stackTrace;
}

final class SidebarCassetteResolutionState {
  const SidebarCassetteResolutionState({
    required this.resolvedCassettes,
    required this.expectedVisibleCount,
    required this.isLoading,
    this.errors = const <SidebarCassetteResolutionError>[],
  });

  final List<ResolvedSidebarCassette> resolvedCassettes;
  final int expectedVisibleCount;
  final bool isLoading;
  final List<SidebarCassetteResolutionError> errors;

  bool get hasCompleteResolvedRack {
    return resolvedCassettes.length == expectedVisibleCount;
  }
}

@riverpod
Future<ResolvedSidebarCassette> resolvedSidebarCassette(
  Ref ref,
  SidebarMode mode,
  CassetteSpec spec,
  int cassetteIndex,
) async {
  final payload = await _buildPayloadForSpec(
    ref,
    spec,
    cassetteIndex: cassetteIndex,
  );

  return ResolvedSidebarCassette(
    spec: spec,
    cassetteIndex: cassetteIndex,
    payload: payload,
  );
}

@riverpod
SidebarCassetteResolutionState sidebarCassetteResolutionState(
  Ref ref,
  SidebarMode mode,
) {
  final renderableSpecs = ref.watch(
    renderableSidebarCassetteSpecsProvider(mode),
  );
  return _buildSidebarCassetteResolutionState(
    ref,
    mode: mode,
    renderableSpecs: renderableSpecs,
  );
}

SidebarCassetteResolutionState _buildSidebarCassetteResolutionState(
  Ref ref, {
  required SidebarMode mode,
  required List<RenderableSidebarCassetteSpec> renderableSpecs,
}) {
  final resolvedCassettes = <ResolvedSidebarCassette>[];
  final errors = <SidebarCassetteResolutionError>[];
  var isLoading = false;

  for (final renderableSpec in renderableSpecs) {
    final asyncResolvedCassette = ref.watch(
      resolvedSidebarCassetteProvider(
        mode,
        renderableSpec.spec,
        renderableSpec.cassetteIndex,
      ),
    );

    if (asyncResolvedCassette.isLoading || !asyncResolvedCassette.hasValue) {
      isLoading = true;
    }

    final error = asyncResolvedCassette.asError;
    if (error != null) {
      errors.add(
        SidebarCassetteResolutionError(
          error: error.error,
          stackTrace: error.stackTrace,
        ),
      );
    }

    final resolvedCassette = asyncResolvedCassette.valueOrNull;
    if (resolvedCassette != null) {
      resolvedCassettes.add(resolvedCassette);
    }
  }

  return SidebarCassetteResolutionState(
    resolvedCassettes: _applySidebarSectionSpacing(resolvedCassettes),
    expectedVisibleCount: renderableSpecs.length,
    isLoading: isLoading,
    errors: errors,
  );
}

Future<SidebarCassettePayload> _buildPayloadForSpec(
  Ref ref,
  CassetteSpec spec, {
  required int cassetteIndex,
}) {
  return spec.when(
    sidebarUtility: (sidebarSpec) async {
      final persistentSettingsContextActionId = sidebarSpec.maybeMap(
        settingsMenu: (_) {
          return ref.watch(
            sidebarFlowProvider.select(
              (flowState) => flowState.persistentSettingsContext,
            ),
          );
        },
        orElse: () => null,
      );

      final coordinator = ref.read(
        sidebar_utilities.sidebarUtilitiesCassetteCoordinatorProvider.notifier,
      );
      return coordinator.buildViewModel(
        sidebarSpec,
        cassetteIndex: cassetteIndex,
        persistentSettingsContextActionId: persistentSettingsContextActionId,
      );
    },
    contacts: (contactsSpec) async {
      contactsSpec.maybeMap(
        contactChooser: (_) {
          ref.watch(contacts_feature.contactChooserCassetteStateProvider);
          return null;
        },
        orElse: () {
          return null;
        },
      );

      final coordinator = ref.read(
        contacts_feature.contactsCassetteCoordinatorProvider.notifier,
      );
      return coordinator.buildViewModel(
        contactsSpec,
        cassetteIndex: cassetteIndex,
      );
    },
    contactsInfo: (infoSpec) async {
      final coordinator = ref.read(
        contacts_feature.contactsInfoCassetteCoordinatorProvider.notifier,
      );
      return coordinator.buildViewModel(infoSpec, cassetteIndex: cassetteIndex);
    },
    handles: (handlesSpec) async {
      handlesSpec.maybeMap(
        strayHandlesReview: (_) {
          ref.watch(handles_feature.strayHandleModeSettingProvider);
          return null;
        },
        strayHandlesModeSwitcher: (_) {
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
    settings: (settingsSpec) async {
      final coordinator = ref.read(
        settings_feature.settingsCassetteCoordinatorProvider.notifier,
      );
      return coordinator.buildViewModel(
        settingsSpec,
        cassetteIndex: cassetteIndex,
      );
    },
  );
}

List<ResolvedSidebarCassette> _applySidebarSectionSpacing(
  List<ResolvedSidebarCassette> resolvedCassettes,
) {
  final spacedCassettes = <ResolvedSidebarCassette>[];
  SidebarCassetteSection? previousSection;

  for (final resolvedCassette in resolvedCassettes) {
    final currentSection = sidebarCassetteSectionForRole(
      resolvedCassette.payload.role,
    );
    final sectionTopSpacing = sidebarCassetteSectionTopSpacing(
      previousSection: previousSection,
      currentSection: currentSection,
    );

    assert(() {
      if (previousSection == currentSection && sectionTopSpacing != 0) {
        throw StateError(
          'sidebarCassetteSectionTopSpacing must return 0 for contiguous '
          'same-section cassettes. Intra-section rhythm belongs to '
          'payload.topSpacing or card chrome, not the sectioning layer.',
        );
      }

      return true;
    }());

    spacedCassettes.add(
      ResolvedSidebarCassette(
        spec: resolvedCassette.spec,
        cassetteIndex: resolvedCassette.cassetteIndex,
        payload: resolvedCassette.payload,
        topSpacing: resolvedCassette.payload.topSpacing + sectionTopSpacing,
      ),
    );
    previousSection = currentSection;
  }

  return spacedCassettes;
}
