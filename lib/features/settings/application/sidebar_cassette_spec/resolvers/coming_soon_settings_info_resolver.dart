import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../../essentials/sidebar/presentation/view_model/sidebar_cassette_card_view_model.dart';

part 'coming_soon_settings_info_resolver.g.dart';

@riverpod
class ComingSoonSettingsInfoResolver extends _$ComingSoonSettingsInfoResolver {
  @override
  void build() {}

  StaticFeatureInfoSidebarCassettePayload resolve({
    required String title,
    required String bodyText,
  }) {
    return StaticFeatureInfoSidebarCassettePayload(
      title: title,
      bodyText: bodyText,
    );
  }
}
