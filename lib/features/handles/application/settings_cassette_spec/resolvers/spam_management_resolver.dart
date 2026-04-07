import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../payloads/spam_management_cassette_payload.dart';

part 'spam_management_resolver.g.dart';

/// Resolver for the spam management settings cassette.
///
/// Receives explicit parameters (not specs) and produces a view model.
@riverpod
class SpamManagementResolver extends _$SpamManagementResolver {
  @override
  void build() {
    // Stateless resolver
  }

  /// Resolve into a sidebar cassette view model.
  Future<SpamManagementCassettePayload> resolve() async {
    return const SpamManagementCassettePayload();
  }
}
