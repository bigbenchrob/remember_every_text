import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../domain/spec_classes/handles_info_cassette_spec.dart';

part 'info_content_resolver.g.dart';

/// Surface-agnostic resolved information content for the Handles feature.
///
/// This payload carries meaning only: plain text plus optional title and
/// footnote. Rendering, actions, spacing, and chrome belong to the surface
/// that consumes it.
///
/// IMPORTANT: Keep this payload UI-surface agnostic:
/// - no padding
/// - no card type decisions
/// - no widget building
class HandlesInfoContent {
  final String? title;
  final String body;
  final String? footnote;

  const HandlesInfoContent({required this.body, this.title, this.footnote});
}

/// Resolves Handles informational keys into surface-agnostic content.
///
/// This is the single source of truth for "what does this info key mean?".
///
/// - May evolve to query repositories (e.g., counts, dynamic hints)
/// - May become async when it needs feature data
@riverpod
class HandlesInfoContentResolver extends _$HandlesInfoContentResolver {
  @override
  void build() {
    // Stateless resolver; callers use resolve() with an explicit info key.
  }

  /// Resolve an info key into surface-agnostic content.
  ///
  /// Keep UI concerns out of here (no card chrome, no widgets). Just meaning and content.
  Future<HandlesInfoContent> resolve(HandlesInfoKey key) async {
    switch (key) {
      case HandlesInfoKey.strayEmailsExplanation:
        return const HandlesInfoContent(
          body:
              'These are messages from email addresses that do not '
              'belong to a contact in your address book.',
        );

      case HandlesInfoKey.strayPhoneNumbersExplanation:
        return const HandlesInfoContent(
          body:
              'These are messages from phone numbers that do not '
              'belong to a contact in your address book.',
        );
    }
  }
}
