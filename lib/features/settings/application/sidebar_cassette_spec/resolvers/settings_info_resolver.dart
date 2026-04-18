import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../../essentials/sidebar/presentation/view_model/sidebar_cassette_card_view_model.dart';

part 'settings_info_resolver.g.dart';

@riverpod
class SettingsInfoResolver extends _$SettingsInfoResolver {
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
