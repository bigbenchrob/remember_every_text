import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../payloads/manual_linking_cassette_payload.dart';

part 'manual_linking_resolver.g.dart';

/// Resolver for the manual handle linking settings cassette.
///
/// Receives explicit parameters (not specs) and produces a view model.
@riverpod
class ManualLinkingResolver extends _$ManualLinkingResolver {
  @override
  void build() {
    // Stateless resolver
  }

  /// Resolve into a sidebar cassette view model.
  Future<ManualLinkingCassettePayload> resolve() async {
    return const ManualLinkingCassettePayload();
  }
}
