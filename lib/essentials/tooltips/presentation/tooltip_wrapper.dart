import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../application/tooltip_coordinator.dart';
import '../domain/entities/tooltip_spec.dart';
import '../domain/tooltip_config.dart';

/// Displays resolved tooltip text on hover.
///
/// Wraps any child widget and shows a tooltip when the user hovers over it.
/// Uses Flutter's built-in [Tooltip] widget with macOS-appropriate styling.
///
/// ## Usage
///
/// ```dart
/// TooltipWrapper(
///   spec: TooltipSpec.contacts(ContactsTooltipSpec.editDisplayName()),
///   child: Icon(CupertinoIcons.pencil),
/// )
/// ```
///
/// ## Spec Resolution
///
/// The tooltip text is resolved asynchronously via [TooltipCoordinator].
/// While resolving, no tooltip is shown (to avoid flash of loading state).
class TooltipWrapper extends ConsumerWidget {
  const TooltipWrapper({
    super.key,
    required this.spec,
    required this.child,
    this.showDelay,
    this.preferBelow =
        false, // Default to above if room, otherwise auto-positions
  });

  /// The tooltip specification to resolve.
  final TooltipSpec spec;

  /// The widget to wrap with tooltip behavior.
  final Widget child;

  /// Override the default show delay. If null, uses [TooltipConfig.defaultShowDelay].
  final Duration? showDelay;

  /// Whether to prefer showing tooltip below the widget.
  /// Defaults to `false` (prefer above), which feels more natural for desktop apps.
  /// Flutter's Tooltip auto-positions if the preferred direction lacks space.
  final bool preferBelow;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<String>(
      future: ref.read(tooltipCoordinatorProvider.notifier).resolve(spec),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return child;
        }

        final tooltipText = snapshot.data!;

        return Tooltip(
          message: tooltipText,
          waitDuration: showDelay ?? TooltipConfig.defaultShowDelay,
          showDuration: TooltipConfig.defaultDisplayDuration,
          preferBelow: preferBelow,
          child: child,
        );
      },
    );
  }
}
