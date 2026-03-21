import 'sidebar_action_intent.dart';

enum SidebarListStyle { standard, dense, guttered }

enum SidebarListTrailingAffordanceMode { none, inline, reservedGutter }

enum SidebarListItemTone { neutral, emphasized, destructive }

enum SidebarBadgeTone { neutral, accent, warning }

class SidebarMetadataItem {
  const SidebarMetadataItem({required this.label, required this.value});

  final String label;
  final String value;
}

class SidebarBadgeModel {
  const SidebarBadgeModel({
    required this.label,
    this.tone = SidebarBadgeTone.neutral,
  });

  final String label;
  final SidebarBadgeTone tone;
}

class SidebarListSelectionState {
  const SidebarListSelectionState({this.selectedItemId});

  final String? selectedItemId;
}

class SidebarListItemModel {
  const SidebarListItemModel({
    required this.id,
    required this.title,
    this.subtitle,
    this.metadata = const <SidebarMetadataItem>[],
    this.badge,
    this.rowIntent,
    this.trailingAction,
    this.tone = SidebarListItemTone.neutral,
    this.isSelected = false,
  });

  final String id;
  final String title;
  final String? subtitle;
  final List<SidebarMetadataItem> metadata;
  final SidebarBadgeModel? badge;
  final SidebarActionIntent? rowIntent;
  final SidebarActionDescriptor? trailingAction;
  final SidebarListItemTone tone;
  final bool isSelected;
}
