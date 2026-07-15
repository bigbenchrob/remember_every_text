import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:macos_ui/macos_ui.dart';

import '../../../../config/theme/colors/theme_colors.dart';
import '../../../../config/theme/theme_typography.dart';
import '../../../../config/theme/widgets/layout/cross_column_track_plan.dart';
import '../../../../features/conversations/presentation/widgets/conversation_signature_card.dart';
import '../../../../features/sidebar_utilities/domain/sidebar_utilities_constants.dart';
import '../../../app_mode/feature_level_providers.dart'
    show switchableDarkModeProvider;
import '../../../conversation_graph/presentation/status/conversation_graph_status_sheet.dart';
import '../../../debug/feature_level_providers.dart'
    show
        DeveloperModeValue,
        columnBandDebugMarginsProvider,
        developerModeProvider;
import '../../../onboarding/domain/onboarding_status.dart';
import '../../../onboarding/feature_level_providers.dart'
    show onboardingGateProvider;
import '../../../onboarding/presentation/onboarding_overlay.dart';
import '../../../sidebar/application/sidebar_flow_state_provider.dart';
import '../../application/app_shell_actions_provider.dart';
import '../../application/panel_widget_providers.dart';
import '../../application/sidebar_mode_provider.dart';
import '../../domain/sidebar_mode.dart';
import '../layout/search_page_conversation_track_occupants.dart';
import '../layout/search_page_track_plan.dart';
import '../widgets/app_mode_toggle.dart';
import '../widgets/onboarding_center_panel_sync_observer.dart';
import 'workspace_layout.dart';

/// macOS window with a fixed navigation column and primary content canvas.
class MacosAppShell extends ConsumerStatefulWidget {
  const MacosAppShell({super.key});

  @override
  ConsumerState<MacosAppShell> createState() => _MacosAppShellState();
}

class _MacosAppShellState extends ConsumerState<MacosAppShell> {
  static const double _toolbarHorizontalPadding = 8.0;
  static const double _toolbarVerticalPadding = 4.0;
  static const double _defaultEndSidebarWidth = 360.0;
  static const double _endSidebarContentHorizontalInset = 32.0;
  static const double _minimumEndSidebarWidth =
      ConversationSignatureCardPresentationMetrics.canonicalWidth +
      (_endSidebarContentHorizontalInset * 2);
  Timer? _windowFrameDebounce;
  DateTime _lastFrameSave = DateTime.fromMillisecondsSinceEpoch(0);
  bool _pendingTrailingFrameSave = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _windowFrameDebounce?.cancel();
    super.dispose();
  }

  void _showConversationGraphStatus() {
    unawaited(
      showMacosSheet<void>(
        context: context,
        barrierDismissible: true,
        builder: (context) => const ConversationGraphStatusSheet(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Capture window size/position after each frame (debounced)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final now = DateTime.now();
      final elapsed = now.difference(_lastFrameSave).inMilliseconds;

      // Throttle: only allow an immediate save if > 1500ms since last save
      if (elapsed > 1500) {
        _lastFrameSave = now;
        unawaited(
          ref
              .read(appShellActionsProvider.notifier)
              .saveCurrentWindowState(includeSize: false),
        );
        _pendingTrailingFrameSave = false;
      } else {
        // Schedule a trailing save 1600ms after last immediate save
        _pendingTrailingFrameSave = true;
        _windowFrameDebounce?.cancel();
        final delay = 1600 - elapsed;
        _windowFrameDebounce = Timer(Duration(milliseconds: delay), () {
          if (_pendingTrailingFrameSave) {
            _lastFrameSave = DateTime.now();
            _pendingTrailingFrameSave = false;
            unawaited(
              ref
                  .read(appShellActionsProvider.notifier)
                  .saveCurrentWindowState(includeSize: false),
            );
          }
        });
      }
    });

    final onboardingStatus = ref.watch(onboardingGateProvider);
    final showOnboardingOverlay = switch (onboardingStatus) {
      OnboardingStatus.recoveringFailedAttempt ||
      OnboardingStatus.importing ||
      OnboardingStatus.buildingGraph ||
      OnboardingStatus.complete ||
      OnboardingStatus.reimporting ||
      OnboardingStatus.reimportBuildingGraph ||
      OnboardingStatus.reimportComplete => true,
      _ => false,
    };
    final activeMode = ref.watch(activeSidebarModeProvider);
    final useSearchTrackPlan =
        activeMode == SidebarMode.messages &&
        ref.watch(sidebarFlowProvider).topMenuChoice ==
            TopChatMenuChoice.searchAllMessages;

    return Stack(
      children: [
        MacosWindow(
          endSidebar: Sidebar(
            key: ValueKey<String>('end-sidebar-${activeMode.name}'),
            startWidth: _defaultEndSidebarWidth,
            minWidth: _minimumEndSidebarWidth,
            maxWidth: 520,
            shownByDefault: false,
            builder: (context, scrollController) {
              final rightPanel = RightPanelHost(mode: activeMode);
              if (!useSearchTrackPlan) {
                return rightPanel;
              }

              final typography = ref.watch(themeTypographyProvider);
              ref.watch(themeColorsProvider);
              final colors = ref.read(themeColorsProvider.notifier);
              final rightSpec = ref.watch(
                effectiveRightPanelSpecProvider(activeMode),
              );
              final additionalOccupants =
                  searchPageConversationExcerptTrackOccupants(
                    ref: ref,
                    rightSpec: rightSpec,
                    colors: colors,
                    typography: typography,
                  );
              return ResolvedTrackPlanScope(
                plan: resolveSearchPageTrackPlan(
                  context: context,
                  typography: typography,
                  additionalOccupants: additionalOccupants,
                ),
                child: rightPanel,
              );
            },
          ),
          child: MacosScaffold(
            toolBar: ToolBar(
              // Position mode toggle above sidebar, other controls above center panel.
              padding: const EdgeInsets.only(
                left: _toolbarHorizontalPadding,
                right: _toolbarHorizontalPadding,
                top: _toolbarVerticalPadding,
                bottom: _toolbarVerticalPadding,
              ),
              title: const _ToolbarTitle(),
              centerTitle: true,
              leading: const AppModeToggle(),
              actions: [
                if (kDebugMode)
                  ToolBarIconButton(
                    label: 'Conversation graph status',
                    icon: const MacosIcon(CupertinoIcons.waveform_path_ecg),
                    onPressed: _showConversationGraphStatus,
                    showLabel: false,
                  ),
                if (kDebugMode)
                  () {
                    final developerMode = ref.watch(developerModeProvider);
                    final isDeveloperMode =
                        developerMode.valueOrNull ==
                        DeveloperModeValue.developer;
                    return ToolBarIconButton(
                      label: isDeveloperMode
                          ? 'Developer mode enabled'
                          : 'Developer mode disabled',
                      icon: MacosIcon(
                        isDeveloperMode
                            ? CupertinoIcons.hammer_fill
                            : CupertinoIcons.hammer,
                      ),
                      onPressed: () {
                        unawaited(
                          ref
                              .read(appShellActionsProvider.notifier)
                              .toggleDeveloperMode(),
                        );
                      },
                      showLabel: false,
                    );
                  }(),
                if (kDebugMode &&
                    ref.watch(developerModeProvider).valueOrNull ==
                        DeveloperModeValue.developer)
                  () {
                    final marginsVisible = ref.watch(
                      columnBandDebugMarginsProvider,
                    );
                    return ToolBarIconButton(
                      label: marginsVisible
                          ? 'Hide layout band margins'
                          : 'Show layout band margins',
                      icon: MacosIcon(
                        marginsVisible
                            ? Icons.border_outer
                            : Icons.border_clear,
                      ),
                      onPressed: () {
                        ref
                            .read(appShellActionsProvider.notifier)
                            .toggleColumnBandDebugMargins();
                      },
                      showLabel: false,
                    );
                  }(),
                () {
                  final themeMode = ref.watch(switchableDarkModeProvider);
                  final (IconData icon, String tooltip) = switch (themeMode) {
                    ThemeMode.system => (
                      CupertinoIcons.circle_lefthalf_fill,
                      'Theme: System (click to switch to Light)',
                    ),
                    ThemeMode.light => (
                      CupertinoIcons.sun_max_fill,
                      'Theme: Light (click to switch to Dark)',
                    ),
                    ThemeMode.dark => (
                      CupertinoIcons.moon_stars_fill,
                      'Theme: Dark (click to switch to System)',
                    ),
                  };
                  return ToolBarIconButton(
                    label: tooltip,
                    icon: MacosIcon(icon),
                    onPressed: () {
                      ref
                          .read(appShellActionsProvider.notifier)
                          .cycleThemeMode();
                    },
                    showLabel: false,
                  );
                }(),
              ],
            ),
            children: [
              ContentArea(
                builder: (context, scrollController) {
                  return Stack(
                    children: [
                      IndexedStack(
                        index: activeMode == SidebarMode.messages ? 0 : 1,
                        children: const [
                          WorkspaceLayout(mode: SidebarMode.messages),
                          WorkspaceLayout(mode: SidebarMode.settings),
                        ],
                      ),
                      const OnboardingCenterPanelSyncObserver(),
                      _EndSidebarSyncObserver(mode: activeMode),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
        if (showOnboardingOverlay) const OnboardingOverlay(),
      ],
    );
  }
}

class _EndSidebarSyncObserver extends ConsumerWidget {
  const _EndSidebarSyncObserver({required this.mode});

  final SidebarMode mode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shouldShow = ref.watch(shouldShowEndSidebarProvider(mode));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) {
        return;
      }

      final scope = MacosWindowScope.of(context);
      if (scope.isEndSidebarShown != shouldShow) {
        scope.toggleEndSidebar();
        unawaited(
          ref
              .read(appShellActionsProvider.notifier)
              .animateEndSidebarWindowWidth(
                showing: shouldShow,
                sidebarWidth: _MacosAppShellState._defaultEndSidebarWidth,
              ),
        );
      }
    });

    return const SizedBox.shrink();
  }
}

class _ToolbarTitle extends StatelessWidget {
  const _ToolbarTitle();

  static const String _toolbarIconAsset =
      'assets/branding/message_lens_toolbar_icon.png';

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          _toolbarIconAsset,
          width: 18,
          height: 18,
          filterQuality: FilterQuality.high,
        ),
        const SizedBox(width: 8),
        const Text('MessageLens'),
      ],
    );
  }
}
