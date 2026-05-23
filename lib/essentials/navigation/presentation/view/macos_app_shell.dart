import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:macos_ui/macos_ui.dart';

import '../../../../providers.dart';
import '../../../debug/application/developer_mode_provider.dart';
import '../../../incremental_update/application/messages/integrators/import_decision_provider.dart';
import '../../../incremental_update/application/messages/orchestrators/sync_state_polling_orchestrator_provider.dart';
import '../../../incremental_update/domain/sealed_unions/import_decision.dart';
import '../../../incremental_update_ss/presentation/incremental_update_status_sheet.dart';
import '../../../onboarding/application/onboarding_gate_provider.dart';
import '../../../onboarding/domain/onboarding_status.dart';
import '../../../onboarding/presentation/onboarding_overlay.dart';
import '../../../window_state/feature_level_providers.dart';
import '../../application/panel_widget_providers.dart';
import '../../application/sidebar_mode_provider.dart';
import '../../domain/sidebar_mode.dart';
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
  Timer? _windowFrameDebounce;
  DateTime _lastFrameSave = DateTime.fromMillisecondsSinceEpoch(0);
  bool _pendingTrailingFrameSave = false;

  late final ProviderSubscription<AsyncValue<ImportDecision>>
  _importDecisionSubscription;
  ImportDecision? _lastImportDecision;

  @override
  void initState() {
    super.initState();

    _importDecisionSubscription = ref.listenManual<AsyncValue<ImportDecision>>(
      importDecisionProvider,
      (previous, next) {
        next.when(
          data: (decision) {
            if (decision == _lastImportDecision) {
              return;
            }

            _lastImportDecision = decision;
            debugPrint('Shadow import decision changed: $decision');
          },
          loading: () {},
          error: (error, stackTrace) {
            debugPrint('Shadow import decision failed: $error');
            debugPrint(stackTrace.toString());
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _importDecisionSubscription.close();
    _windowFrameDebounce?.cancel();
    super.dispose();
  }

  void _startMessageSnapshotDeltaPolling() {
    ref.read(deltaRefreshOrchestratorProvider).startPolling();
  }

  void _stopMessageSnapshotDeltaPolling() {
    ref.read(deltaRefreshOrchestratorProvider).stopPolling();
  }

  void _refreshMessageSnapshotDeltaOnce() {
    unawaited(ref.read(deltaRefreshOrchestratorProvider).refreshOnce());
  }

  void _showIncrementalUpdateStatus() {
    unawaited(
      showMacosSheet<void>(
        context: context,
        barrierDismissible: true,
        builder: (context) => const IncrementalUpdateStatusSheet(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final windowSvc = ref.watch(windowStateServiceProvider);

    // Capture window size/position after each frame (debounced)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final now = DateTime.now();
      final elapsed = now.difference(_lastFrameSave).inMilliseconds;

      // Throttle: only allow an immediate save if > 1500ms since last save
      if (elapsed > 1500) {
        _lastFrameSave = now;
        windowSvc.saveCurrentWindowState(includeSize: false);
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
            windowSvc.saveCurrentWindowState(includeSize: false);
          }
        });
      }
    });

    final onboardingStatus = ref.watch(onboardingGateProvider);
    final showOnboardingOverlay = switch (onboardingStatus) {
      OnboardingStatus.recoveringFailedAttempt ||
      OnboardingStatus.importing ||
      OnboardingStatus.migrating ||
      OnboardingStatus.complete ||
      OnboardingStatus.reimporting ||
      OnboardingStatus.reimportMigrating ||
      OnboardingStatus.reimportComplete => true,
      _ => false,
    };
    final activeMode = ref.watch(activeSidebarModeProvider);

    return Stack(
      children: [
        MacosWindow(
          endSidebar: Sidebar(
            key: ValueKey<String>('end-sidebar-${activeMode.name}'),
            startWidth: _defaultEndSidebarWidth,
            minWidth: 300,
            maxWidth: 520,
            shownByDefault: false,
            builder: (context, scrollController) {
              return RightPanelHost(mode: activeMode);
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
                    label: 'Start message snapshot polling',
                    icon: const MacosIcon(CupertinoIcons.play_fill),
                    onPressed: _startMessageSnapshotDeltaPolling,
                    showLabel: false,
                  ),
                if (kDebugMode)
                  ToolBarIconButton(
                    label: 'Stop message snapshot polling',
                    icon: const MacosIcon(CupertinoIcons.stop_fill),
                    onPressed: _stopMessageSnapshotDeltaPolling,
                    showLabel: false,
                  ),
                if (kDebugMode)
                  ToolBarIconButton(
                    label: 'Refresh shadow incremental update once',
                    icon: const MacosIcon(CupertinoIcons.arrow_clockwise),
                    onPressed: _refreshMessageSnapshotDeltaOnce,
                    showLabel: false,
                  ),
                if (kDebugMode)
                  ToolBarIconButton(
                    label: 'Source-scoped incremental update status',
                    icon: const MacosIcon(CupertinoIcons.waveform_path_ecg),
                    onPressed: _showIncrementalUpdateStatus,
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
                          ref.read(developerModeProvider.notifier).toggleMode(),
                        );
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
                      ref.read(switchableDarkModeProvider.notifier).cycle();
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

// Legacy placeholder widgets removed; dynamic providers now supply content.

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
              .read(windowStateServiceProvider)
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
