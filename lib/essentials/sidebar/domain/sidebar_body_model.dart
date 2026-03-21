import 'sidebar_action_intent.dart';
import 'sidebar_body_option.dart';
import 'sidebar_list_item_model.dart';

enum SidebarHeroKind { contactSummary }

enum SidebarActionPresentation { buttonGroup, inlineLinks, navigationRows }

enum SidebarHeatMapKind { messages, recoveredMessages }

sealed class SidebarBodyModel {
  const SidebarBodyModel();
}

class SidebarEmptyStateModel {
  const SidebarEmptyStateModel({
    required this.title,
    this.bodyText,
    this.action,
  });

  final String title;
  final String? bodyText;
  final SidebarActionDescriptor? action;
}

class SidebarLegendItemModel {
  const SidebarLegendItemModel({required this.label, required this.value});

  final String label;
  final String value;
}

class SidebarHeatMapPointModel {
  const SidebarHeatMapPointModel({
    required this.monthAnchor,
    required this.value,
    required this.interactionIntent,
    this.isSelected = false,
  });

  final DateTime monthAnchor;
  final int value;
  final SidebarActionIntent interactionIntent;
  final bool isSelected;
}

class SidebarBodySectionModel {
  const SidebarBodySectionModel({this.title, required this.body});

  final String? title;
  final SidebarBodyModel body;
}

final class SidebarInfoBodyModel extends SidebarBodyModel {
  const SidebarInfoBodyModel({
    this.title,
    required this.bodyText,
    this.footnote,
    this.supplementalAction,
  });

  final String? title;
  final String bodyText;
  final String? footnote;
  final SidebarActionDescriptor? supplementalAction;
}

final class SidebarHeroBodyModel extends SidebarBodyModel {
  const SidebarHeroBodyModel({
    required this.heroKind,
    required this.primaryText,
    this.secondaryText,
    this.metadata = const <SidebarMetadataItem>[],
    this.heroActions = const <SidebarActionDescriptor>[],
  });

  final SidebarHeroKind heroKind;
  final String primaryText;
  final String? secondaryText;
  final List<SidebarMetadataItem> metadata;
  final List<SidebarActionDescriptor> heroActions;
}

final class SidebarDropdownBodyModel extends SidebarBodyModel {
  const SidebarDropdownBodyModel({
    required this.promptLabel,
    required this.options,
    this.selectedOptionId,
    this.visualPriority = SidebarControlVisualPriority.standard,
  });

  final String promptLabel;
  final String? selectedOptionId;
  final List<SidebarDropdownOption> options;
  final SidebarControlVisualPriority visualPriority;
}

final class SidebarSegmentedControlBodyModel extends SidebarBodyModel {
  const SidebarSegmentedControlBodyModel({
    required this.segments,
    required this.selectedSegmentId,
    this.density = SidebarSegmentedControlDensity.standard,
  });

  final List<SidebarSegmentOption> segments;
  final String selectedSegmentId;
  final SidebarSegmentedControlDensity density;
}

final class SidebarActionBodyModel extends SidebarBodyModel {
  const SidebarActionBodyModel({
    required this.actions,
    this.presentation = SidebarActionPresentation.buttonGroup,
  });

  final List<SidebarActionDescriptor> actions;
  final SidebarActionPresentation presentation;
}

final class SidebarListBodyModel extends SidebarBodyModel {
  const SidebarListBodyModel({
    required this.items,
    this.selectionState = const SidebarListSelectionState(),
    this.emptyState,
    this.listStyle = SidebarListStyle.standard,
    this.trailingAffordanceMode = SidebarListTrailingAffordanceMode.none,
  });

  final List<SidebarListItemModel> items;
  final SidebarListSelectionState selectionState;
  final SidebarEmptyStateModel? emptyState;
  final SidebarListStyle listStyle;
  final SidebarListTrailingAffordanceMode trailingAffordanceMode;
}

final class SidebarHeatMapBodyModel extends SidebarBodyModel {
  const SidebarHeatMapBodyModel({
    required this.heatMapKind,
    required this.dataSeries,
    this.selectedMonthAnchor,
    this.legend = const <SidebarLegendItemModel>[],
    this.emptyState,
  });

  final SidebarHeatMapKind heatMapKind;
  final List<SidebarHeatMapPointModel> dataSeries;
  final DateTime? selectedMonthAnchor;
  final List<SidebarLegendItemModel> legend;
  final SidebarEmptyStateModel? emptyState;
}

final class SidebarCompositeBodyModel extends SidebarBodyModel {
  const SidebarCompositeBodyModel({required this.sections});

  final List<SidebarBodySectionModel> sections;
}
