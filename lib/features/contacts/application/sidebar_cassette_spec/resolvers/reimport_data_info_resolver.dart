import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../payloads/reimport_data_info_cassette_payload.dart';

part 'reimport_data_info_resolver.g.dart';

/// Resolver for ContactsSettingsSpec.reimportDataInfo().
///
/// Returns an info card explaining the reimport action.
@riverpod
class ReimportDataInfoResolver extends _$ReimportDataInfoResolver {
  @override
  void build() {}

  ReimportDataInfoCassettePayload resolve({required int cassetteIndex}) {
    return const ReimportDataInfoCassettePayload();
  }
}
