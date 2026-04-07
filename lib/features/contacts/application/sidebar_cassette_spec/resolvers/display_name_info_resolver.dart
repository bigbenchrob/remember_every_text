import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../../essentials/sidebar/presentation/view_model/sidebar_cassette_card_view_model.dart';

part 'display_name_info_resolver.g.dart';

/// Resolver for ContactsSettingsSpec.displayNameInfo().
///
/// Returns an info card explaining how to customize contact display names.
///
/// ## Contract (from 00-cross-surface-spec-system.md)
///
/// Resolvers:
/// - Own the semantic interpretation of specs
/// - Read data and make decisions
/// - Return fully-configured ViewModels
@riverpod
class DisplayNameInfoResolver extends _$DisplayNameInfoResolver {
  @override
  void build() {}

  /// Produces a canonical info payload about name customization.
  StaticFeatureInfoSidebarCassettePayload resolve({
    required int cassetteIndex,
  }) {
    return const StaticFeatureInfoSidebarCassettePayload(
      role: SidebarCassetteRole.contextSecondary,
      title: 'Contact Names',
      bodyText:
          'Contact names are imported from your Contacts app. '
          "If the imported name isn't quite right, you can customize it.\n\n"
          "To customize a contact's name:\n"
          '1. Switch to Messages mode\n'
          '2. Select the contact\n'
          '3. Click "edit" on their hero card',
      footnote: 'Your custom name will be used throughout the app.',
    );
  }
}
