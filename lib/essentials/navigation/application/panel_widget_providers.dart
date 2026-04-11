import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../features/messages/feature_level_providers.dart'
    as messages_feature;
import '../../../features/sidebar_utilities/domain/sidebar_utilities_constants.dart';
import '../../logging/application/app_logger.dart';
import '../../sidebar/feature_level_providers.dart';
import '../../sidebar/presentation/view_model/sidebar_cassette_card_view_model.dart';
import '../domain/entities/panel_stack.dart';
import '../domain/entities/view_spec.dart';
import '../domain/navigation_constants.dart';
import '../domain/sidebar_mode.dart';
import '../feature_level_providers.dart';
import './panel_coordinator_provider.dart';

// Import the sidebar feature barrel for rack state, cassette resolution, and
// render helpers used to compose the left panel surface.

part 'panel_widget_providers.g.dart';

bool isPinnedAppControlCassette(ResolvedSidebarCassette resolvedCassette) {
  return resolvedCassette.payload.role == SidebarCassetteRole.appControl;
}

bool shouldExpandSidebarCassette(ResolvedSidebarCassette resolvedCassette) {
  return switch (resolvedCassette.payload) {
    PlacementGovernedSidebarCassettePayload(:final shouldExpand) =>
      shouldExpand,
    SharedBodyModelSidebarCassettePayload(:final shouldExpand) => shouldExpand,
    SidebarCassettePayload() => false,
  };
}

@riverpod
PanelStack effectiveCenterPanelStack(Ref ref, SidebarMode mode) {
  final centerStack = ref.watch(
    panelsViewStateProvider(mode).select(
      (stacks) => stacks[WindowPanel.center] ?? const PanelStack.empty(),
    ),
  );

  if (mode != SidebarMode.messages) {
    return centerStack;
  }

  final flowState = ref.watch(sidebarFlowProvider);
  final projectedCenterSpec = flowState.projectedCenterSpec;

  return _resolveEffectiveCenterStack(
    flowState: flowState,
    centerStack: centerStack,
    projectedCenterSpec: projectedCenterSpec,
  );
}

@riverpod
ViewSpec? effectiveCenterPanelSpec(Ref ref, SidebarMode mode) {
  final stack = ref.watch(effectiveCenterPanelStackProvider(mode));
  return stack.activePage?.spec;
}

@riverpod
PanelStack effectiveRightPanelStack(Ref ref, SidebarMode mode) {
  final rightStack = ref.watch(
    panelsViewStateProvider(
      mode,
    ).select((stacks) => stacks[WindowPanel.right] ?? const PanelStack.empty()),
  );

  if (mode != SidebarMode.messages) {
    return rightStack;
  }

  final effectiveCenterSpec = ref.watch(effectiveCenterPanelSpecProvider(mode));
  if (!_supportsRecoveredAttachmentSidebar(effectiveCenterSpec)) {
    return const PanelStack.empty();
  }

  return rightStack;
}

@riverpod
ViewSpec? effectiveRightPanelSpec(Ref ref, SidebarMode mode) {
  final stack = ref.watch(effectiveRightPanelStackProvider(mode));
  return stack.activePage?.spec;
}

/// Whether the center panel is showing content that operates independently
/// of the sidebar (e.g. import/migration, workbench).
///
/// When true, the sidebar should display a contextual overlay with a
/// dismiss action rather than the cassette rack.
@riverpod
bool isSidebarParked(Ref ref, SidebarMode mode) {
  final spec = ref.watch(effectiveCenterPanelSpecProvider(mode));
  if (spec == null) {
    return false;
  }
  return spec.isSidebarIndependent;
}

/// Widget provider for center panel
@riverpod
Widget centerPanelWidget(Ref ref, SidebarMode mode) {
  final stack = ref.watch(effectiveCenterPanelStackProvider(mode));
  return ref
      .read(panelCoordinatorProvider(mode).notifier)
      .buildPanelSurface(WindowPanel.center, stack);
}

@riverpod
Widget rightPanelWidget(Ref ref, SidebarMode mode) {
  final stack = ref.watch(effectiveRightPanelStackProvider(mode));
  return ref
      .read(panelCoordinatorProvider(mode).notifier)
      .buildPanelSurface(WindowPanel.right, stack);
}

@riverpod
bool shouldShowEndSidebar(Ref ref, SidebarMode mode) {
  if (mode != SidebarMode.messages) {
    return false;
  }

  final rightStack = ref.watch(effectiveRightPanelStackProvider(mode));
  return !rightStack.isEmpty;
}

@riverpod
Widget? contextualSidebarWidget(Ref ref, SidebarMode mode) {
  if (mode != SidebarMode.messages) {
    return null;
  }

  final flowState = ref.watch(sidebarFlowProvider);
  final centerSpec = ref.watch(effectiveCenterPanelSpecProvider(mode));

  if (centerSpec == null) {
    return null;
  }

  return centerSpec.when(
    messages: (messagesSpec) {
      return messagesSpec.mapOrNull(
        recoveredUnlinkedMessages: (spec) {
          if (!_shouldShowRecoveredContextFor(flowState)) {
            return null;
          }

          final effectiveContactId = flowState.isContactsBranch
              ? flowState.chosenContactId
              : spec.contactId;

          return ref.watch(
            messages_feature.recoveredMessagesSidebarProvider(
              contactId: effectiveContactId,
              scrollToDate: spec.scrollToDate,
            ),
          );
        },
        recoveredNoHandleFromMeMessages: (spec) => ref.watch(
          messages_feature.recoveredMessagesSidebarProvider(
            onlyNoHandleFromMe: true,
            scrollToDate: spec.scrollToDate,
          ),
        ),
      );
    },
    import: (_) => null,
    environmentReadiness: (_) => null,
    onboarding: (_) => null,
  );
}

bool _supportsRecoveredAttachmentSidebar(ViewSpec? spec) {
  if (spec == null) {
    return false;
  }

  return spec.maybeWhen(
    messages: (messagesSpec) {
      return messagesSpec.maybeWhen(
        globalTimeline: (_) => true,
        recoveredUnlinkedMessages: (_, __) => true,
        recoveredNoHandleFromMeMessages: (_) => true,
        orElse: () => false,
      );
    },
    orElse: () => false,
  );
}

bool _shouldShowRecoveredContextFor(SidebarFlowState flowState) {
  if (flowState.topMenuChoice == TopChatMenuChoice.recoveredUnlinkedMessages ||
      flowState.topMenuChoice ==
          TopChatMenuChoice.recoveredNoHandleFromMeMessages) {
    return true;
  }

  return flowState.isContactsBranch &&
      flowState.messageScope == SidebarFlowMessageScope.recoveredDeleted &&
      flowState.chosenContactId != null;
}

PanelStack _resolveEffectiveCenterStack({
  required SidebarFlowState flowState,
  required PanelStack centerStack,
  required ViewSpec? projectedCenterSpec,
}) {
  if (_shouldUseStoredCenterStack(
    flowState: flowState,
    centerStack: centerStack,
    projectedCenterSpec: projectedCenterSpec,
  )) {
    return centerStack;
  }

  if (projectedCenterSpec == null) {
    return const PanelStack.empty();
  }

  return PanelStack(
    pages: <PanelPage>[
      PanelPage(
        id: 'derived:$projectedCenterSpec',
        spec: projectedCenterSpec,
        title: _defaultPanelTitle(projectedCenterSpec),
        isClosable: false,
      ),
    ],
  );
}

bool _shouldUseStoredCenterStack({
  required SidebarFlowState flowState,
  required PanelStack centerStack,
  required ViewSpec? projectedCenterSpec,
}) {
  final centerSpec = centerStack.activePage?.spec;
  if (centerSpec == null) {
    return false;
  }

  if (centerSpec.isSidebarIndependent) {
    return true;
  }

  if (_isFlowManagedCenterSpec(centerSpec)) {
    return false;
  }

  return !_shouldResetCenterPanel(
    flowState: flowState,
    centerSpec: centerSpec,
    projectedCenterSpec: projectedCenterSpec,
  );
}

String _defaultPanelTitle(ViewSpec spec) {
  return spec.map(
    messages: (_) => 'Messages',
    import: (_) => 'Import',
    environmentReadiness: (_) => 'Environment Readiness',
    onboarding: (_) => 'Onboarding',
  );
}

bool _shouldResetCenterPanel({
  required SidebarFlowState flowState,
  required ViewSpec? centerSpec,
  required ViewSpec? projectedCenterSpec,
}) {
  if (centerSpec?.isSidebarIndependent ?? false) {
    return false;
  }

  if (projectedCenterSpec != null) {
    if (centerSpec == null) {
      return true;
    }

    if (_isFlowManagedCenterSpec(centerSpec)) {
      return centerSpec != projectedCenterSpec;
    }

    return !_isCenterSpecCompatibleWithSidebar(
      flowState: flowState,
      centerSpec: centerSpec,
    );
  }

  if (centerSpec == null) {
    return false;
  }

  if (_isFlowManagedCenterSpec(centerSpec)) {
    return true;
  }

  return !_isCenterSpecCompatibleWithSidebar(
    flowState: flowState,
    centerSpec: centerSpec,
  );
}

bool _isFlowManagedCenterSpec(ViewSpec spec) {
  return spec.maybeWhen(
    messages: (messagesSpec) {
      return messagesSpec.maybeWhen(
        forContact: (_, __, ___) => true,
        globalTimeline: (_) => true,
        recoveredUnlinkedMessages: (_, __) => true,
        recoveredNoHandleFromMeMessages: (_) => true,
        orElse: () => false,
      );
    },
    orElse: () => false,
  );
}

bool _isCenterSpecCompatibleWithSidebar({
  required SidebarFlowState flowState,
  required ViewSpec? centerSpec,
}) {
  if (centerSpec == null) {
    return true;
  }

  return centerSpec.when(
    messages: (messagesSpec) {
      return messagesSpec.when(
        forChat: (_) => true,
        forContact: (contactId, _, __) {
          return flowState.topMenuChoice == TopChatMenuChoice.contacts &&
              flowState.messageScope == SidebarFlowMessageScope.regular &&
              flowState.chosenContactId == contactId;
        },
        globalTimeline: (_) {
          return flowState.topMenuChoice == TopChatMenuChoice.searchAllMessages;
        },
        forHandle: (_) {
          return flowState.topMenuChoice == TopChatMenuChoice.strayHandles;
        },
        recoveredUnlinkedMessages: (contactId, _) {
          if (flowState.topMenuChoice ==
              TopChatMenuChoice.recoveredUnlinkedMessages) {
            return true;
          }

          return flowState.topMenuChoice == TopChatMenuChoice.contacts &&
              flowState.messageScope ==
                  SidebarFlowMessageScope.recoveredDeleted &&
              flowState.chosenContactId != null &&
              contactId == flowState.chosenContactId;
        },
        recoveredNoHandleFromMeMessages: (_) {
          return flowState.topMenuChoice ==
              TopChatMenuChoice.recoveredNoHandleFromMeMessages;
        },
        recoveredAttachmentViewer: (_, __) => true,
        searchResultContext: (_, __, ___, ____) {
          return flowState.topMenuChoice == TopChatMenuChoice.searchAllMessages;
        },
        handleLens: (_) {
          return flowState.topMenuChoice == TopChatMenuChoice.strayHandles;
        },
        forChatInDateRange: (_, __, ___) => true,
      );
    },
    import: (_) => true,
    environmentReadiness: (_) => true,
    onboarding: (_) => true,
  );
}

/// Widget provider for the left sidebar surface.
///
/// The host reads the aggregate per-cassette resolution state for the current
/// rack and renders only when the visible rack is complete. Per-cassette
/// providers preserve previously resolved values during same-rack reloads,
/// while structural rack changes still blank until the new rack is fully
/// resolved.
///
/// Errors are logged but do not currently surface user-visible recovery UI.
@riverpod
Widget leftPanelWidget(Ref ref, SidebarMode mode) {
  final contextualWidget = ref.watch(contextualSidebarWidgetProvider(mode));
  final rack = ref.watch(cassetteRackStateProvider(mode));
  final resolutionState = ref.watch(
    sidebarCassetteResolutionStateProvider(mode),
  );

  return _buildLeftPanelSurface(
    mode: mode,
    rack: rack,
    contextualWidget: contextualWidget,
    resolutionState: resolutionState,
    logError: (error, stackTrace) {
      ref
          .read(appLoggerProvider.notifier)
          .error(
            'Sidebar cassette error: $error',
            source: 'SidebarPanel',
            context: {if (stackTrace != null) 'stackTrace': '$stackTrace'},
          );
    },
  );
}

Widget _buildLeftPanelFromWidgetRef(WidgetRef ref, SidebarMode mode) {
  final contextualWidget = ref.watch(contextualSidebarWidgetProvider(mode));
  final rack = ref.watch(cassetteRackStateProvider(mode));
  final resolutionState = ref.watch(
    sidebarCassetteResolutionStateProvider(mode),
  );

  return _buildLeftPanelSurface(
    mode: mode,
    rack: rack,
    contextualWidget: contextualWidget,
    resolutionState: resolutionState,
    logError: (error, stackTrace) {
      ref
          .read(appLoggerProvider.notifier)
          .error(
            'Sidebar cassette error: $error',
            source: 'SidebarPanel',
            context: {if (stackTrace != null) 'stackTrace': '$stackTrace'},
          );
    },
  );
}

Widget _buildLeftPanelSurface({
  required SidebarMode mode,
  required CassetteRack rack,
  required Widget? contextualWidget,
  required SidebarCassetteResolutionState resolutionState,
  required void Function(Object error, StackTrace? stackTrace) logError,
}) {
  final cassetteEntries =
      <({ResolvedSidebarCassette resolvedCassette, Widget widget})>[
        for (final resolvedCassette in resolutionState.resolvedCassettes)
          (
            resolvedCassette: resolvedCassette,
            widget: buildResolvedSidebarCassetteWidget(
              mode: mode,
              resolvedCassette: resolvedCassette,
            ),
          ),
      ];

  // Log errors for debugging but don't disrupt the UI.
  //
  // Future enhancement: Consider surfacing errors via a toast, badge, or

  // subtle inline indicator rather than silently swallowing them.
  for (final error in resolutionState.errors) {
    // TODO(sidebar): Add user-visible error indicator or recovery UI.
    logError(error.error, error.stackTrace);
  }

  if (!resolutionState.hasCompleteResolvedRack) {
    return const Center(child: CircularProgressIndicator.adaptive());
  }

  // Render the sidebar surface with the current (possibly stale) cassette list.
  //
  // The MouseRegion wrapper supports future hover-based interactions
  // (e.g., showing cassette actions on hover).
  return MouseRegion(
    key: ValueKey<String>('left-panel-$mode-${rack.cassettes.join('|')}'),
    child: _LeftSidebarSurface(
      cassetteEntries: cassetteEntries,
      contextualWidget: contextualWidget,
    ),
  );
}

class LeftPanelHost extends ConsumerWidget {
  const LeftPanelHost({super.key, required this.mode});

  final SidebarMode mode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _buildLeftPanelFromWidgetRef(ref, mode);
  }
}

class CenterPanelHost extends ConsumerWidget {
  const CenterPanelHost({super.key, required this.mode});

  final SidebarMode mode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(centerPanelWidgetProvider(mode));
  }
}

class RightPanelHost extends ConsumerWidget {
  const RightPanelHost({super.key, required this.mode});

  final SidebarMode mode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(rightPanelWidgetProvider(mode));
  }
}

/// Sidebar surface that separates pinned controls from scrollable content.
class _LeftSidebarSurface extends StatelessWidget {
  const _LeftSidebarSurface({
    required this.cassetteEntries,
    required this.contextualWidget,
  });

  final List<({ResolvedSidebarCassette resolvedCassette, Widget widget})>
  cassetteEntries;
  final Widget? contextualWidget;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final controls = <Widget>[];
        final content = <({Widget widget, bool shouldExpand})>[];
        var encounteredMainContent = false;

        for (final entry in cassetteEntries) {
          final constrained = ConstrainedBox(
            constraints: BoxConstraints(maxWidth: constraints.maxWidth),
            child: entry.widget,
          );

          final isPinnedControlCandidate = isPinnedAppControlCassette(
            entry.resolvedCassette,
          );

          // Only keep the leading control block pinned. Once main content
          // starts, preserve the authored cassette order even if later items
          // use naked/control styling for visual reasons.
          if (!encounteredMainContent && isPinnedControlCandidate) {
            controls.add(constrained);
          } else {
            encounteredMainContent = true;

            final shouldExpand = shouldExpandSidebarCassette(
              entry.resolvedCassette,
            );
            content.add((widget: constrained, shouldExpand: shouldExpand));
          }
        }

        if (contextualWidget case final contextualWidgetValue?) {
          content.add((
            widget: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: constraints.maxWidth),
              child: contextualWidgetValue,
            ),
            shouldExpand: false,
          ));
        }

        final hasExpandingContent = content.any((c) => c.shouldExpand);

        // When we have expanding content (e.g., scrollable lists that handle
        // their own scrolling), use a simple Column layout instead of
        // CustomScrollView. This prevents the outer sidebar from showing its
        // own scrollbar - only the inner list scrolls.
        if (hasExpandingContent) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ...controls,
              Expanded(child: _ContentFillColumn(children: content)),
            ],
          );
        }

        // For content without expanding items, use CustomScrollView so the
        // entire sidebar can scroll if content exceeds available height.
        return CustomScrollView(
          slivers: [
            for (final control in controls) SliverToBoxAdapter(child: control),
            for (final item in content) SliverToBoxAdapter(child: item.widget),
          ],
        );
      },
    );
  }
}

class _ContentFillColumn extends StatelessWidget {
  const _ContentFillColumn({required this.children});

  final List<({Widget widget, bool shouldExpand})> children;

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final item in children)
          if (item.shouldExpand) Expanded(child: item.widget) else item.widget,
      ],
    );
  }
}
