import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../payloads/unmatched_handles_cassette_payload.dart';

part 'unmatched_handles_resolver.g.dart';

/// Resolver for the unmatched handles list cassette.
///
/// Receives explicit parameters (not specs) and produces a view model.
@riverpod
class UnmatchedHandlesResolver extends _$UnmatchedHandlesResolver {
  @override
  void build() {
    // Stateless resolver
  }

  /// Resolve into a sidebar cassette view model.
  Future<UnmatchedHandlesCassettePayload> resolve() async {
    return const UnmatchedHandlesCassettePayload();
  }
}
