import '../../../../../constants/domain/contact_constants.dart';
import '../../../../../essentials/sidebar/presentation/view_model/sidebar_cassette_card_view_model.dart';
import '../resolver_tools/picker_filter_mode_provider.dart';
import '../resolver_tools/unified_picker_sections_provider.dart';

/// Inert transport payload for the contacts chooser cassette.
///
/// This carries only semantic chooser state across the cassette coordination
/// boundary. The feature-owned render edge reconstructs the concrete widget.
final class ContactChooserCassettePayload
    extends PlacementGovernedSidebarCassettePayload {
  const ContactChooserCassettePayload({
    this.pickerMode,
    this.pickerFilterMode,
    this.filteredSections,
    required this.chosenContactId,
    required this.cassetteIndex,
    super.title = '',
    super.subtitle,
    super.sectionTitle,
    super.footerText,
    super.placementMode = SidebarBodyPlacementMode.fullWidth,
    super.contentAlignment = SidebarBodyContentAlignment.fill,
    super.layoutStyle = SidebarCardLayoutStyle.standard,
    super.isNaked = false,
    super.shouldExpand = true,
    super.role = SidebarCassetteRole.contextPrimary,
    super.topSpacing = 0,
  });

  final ContactPickerMode? pickerMode;
  final PickerFilterMode? pickerFilterMode;
  final UnifiedPickerSections? filteredSections;
  final int? chosenContactId;
  final int cassetteIndex;
}
