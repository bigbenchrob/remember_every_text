import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../payloads/send_logs_info_cassette_payload.dart';

part 'actions_info_resolver.g.dart';

/// Resolver for ContactsSettingsSpec.sendLogsInfo().
///
/// Returns an info card with diagnostic log export action.
@riverpod
class ActionsInfoResolver extends _$ActionsInfoResolver {
  @override
  void build() {}

  SendLogsInfoCassettePayload resolve({required int cassetteIndex}) {
    return const SendLogsInfoCassettePayload();
  }
}
