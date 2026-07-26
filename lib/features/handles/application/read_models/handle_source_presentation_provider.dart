import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../essentials/db/feature_level_providers.dart'
    show messageDataVersionProvider;
import 'handle_display_name_provider.dart';
import 'handle_identity.dart';
import 'handle_source_presentation.dart';
import 'stray_handles_provider.dart';

part 'handle_source_presentation_provider.g.dart';

/// Provides the canonical identity projection for one source.
///
/// Messages owns the complete handle-lens ViewSpec presentation. Handles owns
/// this source identity projection so collaborating presentations cannot invent
/// different fallback labels or source-review wording.
@riverpod
Future<HandleSourcePresentation> handleSourcePresentation(
  Ref ref, {
  required int handleId,
}) async {
  ref.watch(messageDataVersionProvider);
  final canonicalHandleId = canonicalHandleIdentityKey(handleId);
  final repository = await ref.watch(strayHandlesReadRepositoryProvider.future);
  final source = await repository.readHandleSource(handleId: canonicalHandleId);
  final resolvedDisplayName = await ref.watch(
    handleDisplayNameProvider(handleId: canonicalHandleId).future,
  );
  final rawEndpoint = source?.handleValue.trim();

  return HandleSourcePresentation(
    canonicalHandleId: canonicalHandleId,
    primaryDisplayLabel: _firstNonEmpty(
      resolvedDisplayName,
      rawEndpoint,
      'Handle #$canonicalHandleId',
    ),
    rawEndpoint: rawEndpoint == null || rawEndpoint.isEmpty
        ? null
        : rawEndpoint,
    statusLabel: 'Unfamiliar source',
    messageCount: source?.totalMessages ?? 0,
  );
}

String _firstNonEmpty(String? first, String? second, String fallback) {
  final normalizedFirst = first?.trim();
  if (normalizedFirst != null && normalizedFirst.isNotEmpty) {
    return normalizedFirst;
  }
  final normalizedSecond = second?.trim();
  if (normalizedSecond != null && normalizedSecond.isNotEmpty) {
    return normalizedSecond;
  }
  return fallback;
}
