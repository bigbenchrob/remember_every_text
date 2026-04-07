import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../payloads/stray_emails_cassette_payload.dart';

part 'stray_emails_resolver.g.dart';

/// Resolver for the stray emails cassette.
///
/// Receives explicit parameters (not specs) and produces a view model.
@riverpod
class StrayEmailsResolver extends _$StrayEmailsResolver {
  @override
  void build() {
    // Stateless resolver
  }

  /// Resolve into a sidebar cassette view model.
  Future<StrayEmailsCassettePayload> resolve() async {
    return const StrayEmailsCassettePayload();
  }
}
