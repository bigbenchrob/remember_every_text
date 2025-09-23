import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:macos_ui/macos_ui.dart';

import '../../../logging/application/navigation_logger.dart';
import '../../../window_state/feature_level_providers.dart';
import '../../application/panels_view_state_provider.dart';
import '../../domain/entities/features/chats_spec.dart';
import '../../domain/entities/features/contacts_spec.dart';
import '../../domain/entities/features/import_spec.dart';
import '../../domain/entities/features/messages_spec.dart';
import '../../domain/entities/view_spec.dart';
import '../../domain/navigation_constants.dart';
import '../view_model/panel_widget_providers.dart';

/// Basic macOS window with two sidebars
class MacosAppShell extends ConsumerStatefulWidget {
  const MacosAppShell({super.key});

  @override
  ConsumerState<MacosAppShell> createState() => _MacosAppShellState();
}

class _MacosAppShellState extends ConsumerState<MacosAppShell> {
  double? _sidebarWidth;
  double? _endSidebarWidth;
  bool _initialized = false;
  Timer? _debounceTimer;
  Timer? _windowFrameDebounce;
  DateTime _lastFrameSave = DateTime.fromMillisecondsSinceEpoch(0);
  bool _pendingTrailingFrameSave = false;

  @override
  void initState() {
    super.initState();
    _restore();
  }

  Future<void> _restore() async {
    try {
      final svc = ref.read(windowStateServiceProvider);
      final state = await svc.loadWindowState();
      if (mounted) {
        setState(() {
          _sidebarWidth = state.sidebarWidth;
          _endSidebarWidth = state.endSidebarWidth;
          _initialized = true;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _initialized = true;
        });
      }
    }
  }

  void _debounceSave(Future<void> Function() op) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 120), () {
      op();
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _windowFrameDebounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return const ColoredBox(
        color: Colors.black,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final windowSvc = ref.watch(windowStateServiceProvider);

    // Capture window size/position after each frame (debounced)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final now = DateTime.now();
      final elapsed = now.difference(_lastFrameSave).inMilliseconds;

      // Throttle: only allow an immediate save if > 1500ms since last save
      if (elapsed > 1500) {
        _lastFrameSave = now;
        windowSvc.saveCurrentWindowState();
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
            windowSvc.saveCurrentWindowState();
          }
        });
      }
    });

    return MacosWindow(
      onSidebarWidthChanged: (w) {
        final width = w < 0.0 ? 0.0 : w;
        setState(() {
          _sidebarWidth = width;
        });
        _debounceSave(() async {
          await windowSvc.saveSidebarWidths(sidebarWidth: width);
        });
      },
      onEndSidebarWidthChanged: (w) {
        final width = w < 0.0 ? 0.0 : w;
        setState(() {
          _endSidebarWidth = width;
        });
        _debounceSave(() async {
          await windowSvc.saveSidebarWidths(endSidebarWidth: width);
        });
      },
      sidebar: Sidebar(
        minWidth: 120,
        startWidth: _sidebarWidth ?? 320,
        builder: (context, scrollController) {
          return ref.watch(leftPanelWidgetProvider);
        },
      ),
      endSidebar: Sidebar(
        minWidth: 120,
        startWidth: _endSidebarWidth ?? 280,
        builder: (context, scrollController) {
          return ref.watch(rightPanelWidgetProvider);
        },
      ),
      child: MacosScaffold(
        toolBar: ToolBar(
          title: const Text('Remember This Text'),
          centerTitle: true,
          actions: [
            ToolBarIconButton(
              label: 'Messages',
              icon: const MacosIcon(CupertinoIcons.chat_bubble),
              onPressed: () {
                const spec = ViewSpec.messages(
                  MessagesSpec.forChat(chatId: 42),
                );

                // Log the navigation action
                ref
                    .read(navigationLoggerProvider.notifier)
                    .logToolbarClick(
                      buttonLabel: 'Messages',
                      targetPanel: WindowPanel.center,
                      viewSpec: spec,
                    );

                // Perform the navigation
                ref
                    .read(panelsViewStateProvider.notifier)
                    .show(panel: WindowPanel.center, spec: spec);
              },
              showLabel: false,
            ),
            ToolBarIconButton(
              label: 'Chats',
              icon: const MacosIcon(CupertinoIcons.chat_bubble_2),
              onPressed: () {
                const spec = ViewSpec.chats(ChatsSpec.list());

                // Log the navigation action
                ref
                    .read(navigationLoggerProvider.notifier)
                    .logToolbarClick(
                      buttonLabel: 'Chats',
                      targetPanel: WindowPanel.left,
                      viewSpec: spec,
                    );

                // Perform the navigation
                ref
                    .read(panelsViewStateProvider.notifier)
                    .show(panel: WindowPanel.left, spec: spec);
              },
              showLabel: false,
            ),
            ToolBarIconButton(
              label: 'Contacts',
              icon: const MacosIcon(CupertinoIcons.person_2),
              onPressed: () {
                const spec = ViewSpec.contacts(ContactsSpec.list());

                // Log the navigation action
                ref
                    .read(navigationLoggerProvider.notifier)
                    .logToolbarClick(
                      buttonLabel: 'Contacts',
                      targetPanel: WindowPanel.center,
                      viewSpec: spec,
                    );

                // Perform the navigation
                ref
                    .read(panelsViewStateProvider.notifier)
                    .show(panel: WindowPanel.center, spec: spec);
              },
              showLabel: false,
            ),
            ToolBarIconButton(
              label: 'Import',
              icon: const MacosIcon(CupertinoIcons.square_arrow_down),
              onPressed: () {
                const spec = ViewSpec.import(ImportSpec.forImport());

                // Log the navigation action
                ref
                    .read(navigationLoggerProvider.notifier)
                    .logToolbarClick(
                      buttonLabel: 'Import',
                      targetPanel: WindowPanel.right,
                      viewSpec: spec,
                    );

                // Perform the navigation
                ref
                    .read(panelsViewStateProvider.notifier)
                    .show(panel: WindowPanel.right, spec: spec);
              },
              showLabel: false,
            ),
            const ToolBarSpacer(),
            ToolBarIconButton(
              label: 'Settings',
              icon: const MacosIcon(CupertinoIcons.settings),
              onPressed: () {
                // Demo: Show contacts search as an example
                const spec = ViewSpec.contacts(
                  ContactsSpec.search(query: 'John'),
                );

                // Log the navigation action
                ref
                    .read(navigationLoggerProvider.notifier)
                    .logToolbarClick(
                      buttonLabel: 'Settings',
                      targetPanel: WindowPanel.right,
                      viewSpec: spec,
                    );

                // Perform the navigation
                ref
                    .read(panelsViewStateProvider.notifier)
                    .show(panel: WindowPanel.right, spec: spec);
              },
              showLabel: false,
            ),
          ],
        ),
        children: [
          ContentArea(
            builder: (context, scrollController) {
              return ref.watch(centerPanelWidgetProvider);
            },
          ),
        ],
      ),
    );
  }
}

// Legacy placeholder widgets removed; dynamic providers now supply content.
