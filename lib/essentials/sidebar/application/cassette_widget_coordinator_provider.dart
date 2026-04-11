import 'package:hooks_riverpod/hooks_riverpod.dart';
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
import '../presentation/view_model/sidebar_cassette_card_view_model.dart';
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

final class _IndexedCassetteSpec {
  const _IndexedCassetteSpec({required this.spec, required this.cassetteIndex});

  final CassetteSpec spec;
  final int cassetteIndex;
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
  final visibleSpecs = _visibleSidebarSpecsForMode(ref, mode);
  return _buildSidebarCassetteResolutionState(
    ref,
    mode: mode,
    visibleSpecs: visibleSpecs,
  );
}

SidebarCassetteResolutionState _buildSidebarCassetteResolutionState(
  Ref ref, {
  required SidebarMode mode,
  required List<_IndexedCassetteSpec> visibleSpecs,
}) {
  final resolvedCassettes = <ResolvedSidebarCassette>[];
  final errors = <SidebarCassetteResolutionError>[];
  var isLoading = false;

  for (final visibleSpec in visibleSpecs) {
    final asyncResolvedCassette = ref.watch(
      resolvedSidebarCassetteProvider(
        mode,
        visibleSpec.spec,
        visibleSpec.cassetteIndex,
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
    expectedVisibleCount: visibleSpecs.length,
    isLoading: isLoading,
    errors: errors,
  );
}

List<_IndexedCassetteSpec> _visibleSidebarSpecsForMode(
  Ref ref,
  SidebarMode mode,
) {
  final rack = ref.watch(cassetteRackStateProvider(mode));
  final flowState = mode == SidebarMode.messages
      ? ref.watch(sidebarFlowProvider)
      : null;

  return _visibleSidebarSpecs(rack: rack, flowState: flowState);
}

Future<SidebarCassettePayload> _buildPayloadForSpec(
  Ref ref,
  CassetteSpec spec, {
  required int cassetteIndex,
}) {
  return spec.when(
    sidebarUtility: (sidebarSpec) async {
      final coordinator = ref.read(
        sidebar_utilities.sidebarUtilitiesCassetteCoordinatorProvider.notifier,
      );
      return coordinator.buildViewModel(
        sidebarSpec,
        cassetteIndex: cassetteIndex,
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
  );
}

List<_IndexedCassetteSpec> _visibleSidebarSpecs({
  required CassetteRack rack,
  required SidebarFlowState? flowState,
}) {
  final visibleSpecs = <_IndexedCassetteSpec>[];

  for (var i = 0; i < rack.cassettes.length; i++) {
    final spec = rack.cassettes[i];
    if (_shouldHideSpecForFlow(spec: spec, flowState: flowState)) {
      continue;
    }

    visibleSpecs.add(_IndexedCassetteSpec(spec: spec, cassetteIndex: i));
  }

  return visibleSpecs;
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
