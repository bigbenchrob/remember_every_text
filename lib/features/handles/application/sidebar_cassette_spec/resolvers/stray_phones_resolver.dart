import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../payloads/stray_phone_numbers_cassette_payload.dart';

part 'stray_phones_resolver.g.dart';

/// Resolver for the stray phone numbers cassette.
///
/// Receives explicit parameters (not specs) and produces a view model.
@riverpod
class StrayPhonesResolver extends _$StrayPhonesResolver {
  @override
  void build() {
    // Stateless resolver
  }

  /// Resolve into a sidebar cassette view model.
  Future<StrayPhoneNumbersCassettePayload> resolve() async {
    return const StrayPhoneNumbersCassettePayload();
  }
}
