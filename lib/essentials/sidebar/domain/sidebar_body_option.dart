import 'sidebar_action_intent.dart';

enum SidebarControlVisualPriority { standard, prominent }

enum SidebarSegmentedControlDensity { standard, compact }

class SidebarDropdownOption {
  const SidebarDropdownOption({
    required this.id,
    required this.label,
    required this.selectionIntent,
    this.secondaryLabel,
    this.isDestructive = false,
    this.isDisabled = false,
  });

  final String id;
  final String label;
  final String? secondaryLabel;
  final SidebarActionIntent selectionIntent;
  final bool isDestructive;
  final bool isDisabled;
}

class SidebarSegmentOption {
  const SidebarSegmentOption({
    required this.id,
    required this.label,
    required this.selectionIntent,
    this.isDisabled = false,
  });

  final String id;
  final String label;
  final SidebarActionIntent selectionIntent;
  final bool isDisabled;
}
