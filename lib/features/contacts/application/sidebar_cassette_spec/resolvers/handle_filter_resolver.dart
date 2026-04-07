import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../../essentials/sidebar/presentation/view_model/sidebar_cassette_card_view_model.dart';
import '../payloads/handle_filter_cassette_payload.dart';

part 'handle_filter_resolver.g.dart';

/// Resolves a handle filter cassette — the "From phone # / email:" dropdown.
///
/// ## Contract
///
/// - Receives explicit parameters (not specs)
/// - Returns `Future<SidebarCassettePayload>`
/// - Returns inert semantic payload only
@riverpod
class HandleFilterResolver extends _$HandleFilterResolver {
  @override
  void build() {
    // Stateless resolver
  }

  /// Resolve the handle filter cassette.
  Future<SidebarCassettePayload> resolve({
    required int contactId,
    int? selectedHandleId,
    required int cassetteIndex,
  }) async {
    return HandleFilterCassettePayload(
      contactId: contactId,
      selectedHandleId: selectedHandleId,
      cassetteIndex: cassetteIndex,
    );
  }
}
