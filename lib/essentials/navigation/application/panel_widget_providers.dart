import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../features/messages/feature_level_providers.dart'
    as messages_feature;
import '../../../features/sidebar_utilities/domain/sidebar_utilities_constants.dart';
import '../../logging/application/app_logger.dart';
// Import the sidebar feature barrel to access cassette widget coordinator and card.
// The provider (cassetteWidgetCoordinatorProvider) exposes the list of cassette
// widgets that compose the sidebar. We wrap these in a Column to produce the
// left panel surface.
import '../../sidebar/feature_level_providers.dart';
import '../domain/entities/panel_stack.dart';
import '../domain/entities/view_spec.dart';
import '../domain/navigation_constants.dart';
import '../domain/sidebar_mode.dart';
import '../feature_level_providers.dart';
import './panel_coordinator_provider.dart';

part 'panel_widget_providers.g.dart';

bool isPinnedAppControlCassette(Widget widget) {
  final cassetteCard = unwrapSidebarCassetteCard(widget);
  return cassetteCard != null &&
      cassetteCard.role == SidebarCassetteRole.appControl;
}

bool shouldExpandSidebarCassette(Widget widget) {
  final cassetteCard = unwrapSidebarCassetteCard(widget);
  return cassetteCard?.shouldExpand ?? false;
}

SidebarCassetteCard? unwrapSidebarCassetteCard(Widget widget) {
  Widget current = widget;

  while (current is Padding) {
    final child = current.child;
    if (child == null) {
      return null;
    }
    current = child;
  }

  if (current is SidebarCassetteCard) {
    return current;
  }

  return null;
}

@riverpod
void reconcileSidebarPanels(Ref ref, SidebarMode mode) {
  if (mode != SidebarMode.messages) {
    return;
  }

  final flowState = ref.watch(sidebarFlowProvider);
  final panels = ref.watch(panelsViewStateProvider(mode));
  final centerStack = panels[WindowPanel.center] ?? const PanelStack.empty();
  final rightStack = panels[WindowPanel.right] ?? const PanelStack.empty();
  final centerSpec = centerStack.activePage?.spec;
  final projectedCenterSpec = flowState.projectedCenterSpec;

  final shouldResetCenter = _shouldResetCenterPanel(
    flowState: flowState,
    centerSpec: centerSpec,
    projectedCenterSpec: projectedCenterSpec,
  );
  final effectiveCenterSpec = shouldResetCenter
      ? projectedCenterSpec
      : centerSpec;
  final shouldClearRight =
      !rightStack.isEmpty &&
      (shouldResetCenter ||
          !_supportsRecoveredAttachmentSidebar(effectiveCenterSpec));

  if (!shouldResetCenter && !shouldClearRight) {
    return;
  }

  WidgetsBinding.instance.addPostFrameCallback((_) {
    final panelsNotifier = ref.read(panelsViewStateProvider(mode).notifier);
    if (shouldResetCenter) {
      if (projectedCenterSpec == null) {
        panelsNotifier.clear(panel: WindowPanel.center);
      } else {
        panelsNotifier.show(
          panel: WindowPanel.center,
          spec: projectedCenterSpec,
        );
      }
      return;
    }

    if (shouldClearRight) {
      panelsNotifier.clear(panel: WindowPanel.right);
    }
  });
}

/// Whether the center panel is showing content that operates independently
/// of the sidebar (e.g. import/migration, workbench).
///
/// When true, the sidebar should display a contextual overlay with a
/// dismiss action rather than the cassette rack.
@riverpod
bool isSidebarParked(Ref ref, SidebarMode mode) {
  final stack = ref.watch(
    panelsViewStateProvider(mode).select(
      (stacks) => stacks[WindowPanel.center] ?? const PanelStack.empty(),
    ),
  );
  final spec = stack.activePage?.spec;
  if (spec == null) {
    return false;
  }
  return spec.isSidebarIndependent;
}

/// Widget provider for center panel
@riverpod
Widget centerPanelWidget(Ref ref, SidebarMode mode) {
  ref.watch(reconcileSidebarPanelsProvider(mode));
  final stack = ref.watch(
    panelsViewStateProvider(mode).select(
      (stacks) => stacks[WindowPanel.center] ?? const PanelStack.empty(),
    ),
  );
  return ref
      .read(panelCoordinatorProvider(mode).notifier)
      .buildPanelSurface(WindowPanel.center, stack);
}

@riverpod
Widget rightPanelWidget(Ref ref, SidebarMode mode) {
  final stack = ref.watch(
    panelsViewStateProvider(
      mode,
    ).select((stacks) => stacks[WindowPanel.right] ?? const PanelStack.empty()),
  );
  return ref
      .read(panelCoordinatorProvider(mode).notifier)
      .buildPanelSurface(WindowPanel.right, stack);
}

@riverpod
bool shouldShowEndSidebar(Ref ref, SidebarMode mode) {
  if (mode != SidebarMode.messages) {
    return false;
  }

  final stacks = ref.watch(panelsViewStateProvider(mode));
  final centerSpec = stacks[WindowPanel.center]?.activePage?.spec;
  final rightStack = stacks[WindowPanel.right] ?? const PanelStack.empty();

  if (rightStack.isEmpty) {
    return false;
  }

  return _supportsRecoveredAttachmentSidebar(centerSpec);
}

@riverpod
Widget? contextualSidebarWidget(Ref ref, SidebarMode mode) {
  if (mode != SidebarMode.messages) {
    return null;
  }

  final flowState = ref.watch(sidebarFlowProvider);

  final centerSpec = ref.watch(
    panelsViewStateProvider(
      mode,
    ).select((stacks) => stacks[WindowPanel.center]?.activePage?.spec),
  );

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

bool _shouldResetCenterPanel({
  required SidebarFlowState flowState,
  required ViewSpec? centerSpec,
  required ViewSpec? projectedCenterSpec,
}) {
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
    onboarding: (_) => true,
  );
}

/// Widget provider for left panel (sidebar).
///
/// This provider builds the left panel by reading the current list of
/// cassette widgets from [CassetteWidgetCoordinator].  The resulting list
/// is wrapped in a [Column] so that the cassettes are laid out vertically.
///
/// ## Async Handling Strategy
///
/// The [CassetteWidgetCoordinator] returns `AsyncValue<List<Widget>>` because
/// feature-side spec coordinators may need to fetch data from repositories
/// (e.g., contact counts, derived values, async formatting).
///
/// We use a **stale-while-revalidate** pattern here:
///
/// 1. **Initial load**: Show a loading indicator until the first cassette list
///    resolves. This only happens once per sidebar mode on app startup or when
///    the mode changes.
///
/// 2. **Subsequent updates**: Keep displaying the previous cassette list while
///    the new list builds asynchronously. This prevents jarring full-sidebar
///    reloads when the user interacts with a cassette (e.g., toggles a setting,
///    selects a filter).
///
/// 3. **Errors**: Currently logged but not displayed. The previous valid state
///    is preserved. Future enhancement: consider a subtle error toast or badge.
///
/// ## Why `valueOrNull` instead of `when()`?
///
/// Using `asyncCassettes.valueOrNull` with explicit state checks gives us more
/// control than `AsyncValue.when()`:
///
/// - **Easier to add loading overlays**: We can later add a subtle progress
///   indicator (e.g., a thin bar at the top) without restructuring the code.
///
/// - **Partial update support**: If we ever want to show incremental cassette
///   updates (e.g., stream-based), this pattern accommodates that.
///
/// - **Cleaner error handling**: We can log errors and preserve the UI without
///   forcing an error widget into the layout.
///
/// - **No callback nesting**: The linear flow is easier to read and extend.
///
/// ## Future Extension Points
///
/// - **Loading indicator overlay**: Add a `Stack` with an `AnimatedOpacity`
///   progress bar that fades in during `isLoading && hasValue`.
///
/// - **Per-cassette loading**: If individual cassettes need independent async
///   states, consider returning `List<AsyncValue<Widget>>` from the coordinator
///   and handling loading per-slot.
///
/// - **Error recovery UI**: Add a "Retry" affordance or error badge that
///   appears when `hasError` is true but we're still showing stale data.
///
/// - **Optimistic updates**: For user-initiated changes (e.g., toggling a
///   setting), consider updating the UI optimistically before the async
///   operation completes.
@riverpod
Widget leftPanelWidget(Ref ref, SidebarMode mode) {
  final contextualWidget = ref.watch(contextualSidebarWidgetProvider(mode));
  // Watch the async cassette list from the coordinator.
  //
  // This is an AsyncValue because feature-side coordinators (e.g.,
  // InfoCassetteCoordinator) may perform async operations like repository
  // lookups or data formatting.
  final asyncCassettes = ref.watch(cassetteWidgetCoordinatorProvider(mode));

  // Extract the most recent successful value, or fall back to an empty list.
  //
  // Using `valueOrNull` ensures that during a refresh (when isLoading is true
  // but we have previous data), we continue showing the previous cassettes
  // rather than dropping to a loading state.
  final cassetteWidgets = asyncCassettes.valueOrNull ?? const <Widget>[];
  final sidebarWidgets = contextualWidget == null
      ? cassetteWidgets
      : <Widget>[...cassetteWidgets, contextualWidget];

  // Determine if this is truly the first load (no data yet) vs. a refresh
  // (loading new data but we have previous data to show).
  //
  // We only show the loading indicator when:
  // - We're in a loading state, AND
  // - We have no previous value to display
  //
  // This prevents the entire sidebar from flashing a spinner every time a
  // cassette triggers an update.
  final isInitialLoad = asyncCassettes.isLoading && !asyncCassettes.hasValue;

  // Log errors for debugging but don't disrupt the UI.
  //
  // Future enhancement: Consider surfacing errors via a toast, badge, or

  // subtle inline indicator rather than silently swallowing them.
  if (asyncCassettes.hasError) {
    // TODO(sidebar): Add user-visible error indicator or recovery UI.
    ref
        .read(appLoggerProvider.notifier)
        .error(
          'Sidebar cassette error: ${asyncCassettes.error}',
          source: 'SidebarPanel',
          context: {
            if (asyncCassettes.stackTrace != null)
              'stackTrace': '${asyncCassettes.stackTrace}',
          },
        );
  }

  // Show a centered loading indicator only during the initial load.
  //
  // This ensures the user sees feedback on first render, but subsequent
  // updates (triggered by user actions) don't cause a jarring full-reload.
  if (isInitialLoad) {
    return const Center(child: CircularProgressIndicator.adaptive());
  }

  // Render the sidebar surface with the current (possibly stale) cassette list.
  //
  // The MouseRegion wrapper supports future hover-based interactions
  // (e.g., showing cassette actions on hover).
  return MouseRegion(
    child: _LeftSidebarSurface(cassetteWidgets: sidebarWidgets),
  );
}

/// Sidebar surface that separates pinned controls from scrollable content.
class _LeftSidebarSurface extends StatelessWidget {
  const _LeftSidebarSurface({required this.cassetteWidgets});

  final List<Widget> cassetteWidgets;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final controls = <Widget>[];
        final content = <({Widget widget, bool shouldExpand})>[];
        var encounteredMainContent = false;

        for (final widget in cassetteWidgets) {
          final constrained = ConstrainedBox(
            constraints: BoxConstraints(maxWidth: constraints.maxWidth),
            child: widget,
          );

          final isPinnedControlCandidate = isPinnedAppControlCassette(widget);

          // Only keep the leading control block pinned. Once main content
          // starts, preserve the authored cassette order even if later items
          // use naked/control styling for visual reasons.
          if (!encounteredMainContent && isPinnedControlCandidate) {
            controls.add(constrained);
          } else {
            encounteredMainContent = true;

            // SidebarCassetteCard carries its own shouldExpand flag.
            // All other widget types default to false (intrinsic height).
            final shouldExpand = shouldExpandSidebarCassette(widget);
            content.add((widget: constrained, shouldExpand: shouldExpand));
          }
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
