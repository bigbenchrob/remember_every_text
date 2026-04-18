import '../../../../../essentials/sidebar/domain/sidebar_action_intent.dart';
import '../../../../../essentials/sidebar/presentation/view_model/sidebar_cassette_card_view_model.dart';

final class SettingsInfoActionsCassettePayload
    extends FeatureInfoSidebarCassettePayload {
  const SettingsInfoActionsCassettePayload({
    required this.actions,
    required this.cassetteIndex,
    required super.bodyText,
    super.role = SidebarCassetteRole.action,
    super.topSpacing = 0,
    super.title,
    super.footnote,
  });

  final List<SidebarActionDescriptor> actions;
  final int cassetteIndex;
}