// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stray_handles_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$strayHandlesReadRepositoryHash() =>
    r'270e74e8bf8057bc5ce5146ec27cbb8f29ff07fc';

/// See also [strayHandlesReadRepository].
@ProviderFor(strayHandlesReadRepository)
final strayHandlesReadRepositoryProvider =
    AutoDisposeFutureProvider<StrayHandlesReadRepository>.internal(
      strayHandlesReadRepository,
      name: r'strayHandlesReadRepositoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$strayHandlesReadRepositoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef StrayHandlesReadRepositoryRef =
    AutoDisposeFutureProviderRef<StrayHandlesReadRepository>;
String _$strayHandlesHash() => r'f15efb4b7334541d79e57f8b089ec223ec4d75fd';

/// Returns all handles that are truly "stray": no graph contact link and no
/// linked override (participant or virtual participant) in the overlay DB.
///
/// Handles with an overlay row that has only `reviewed_at` set (both
/// participant IDs null) are still included — they are reviewed but unlinked.
///
/// Excludes dismissed handles; those are only visible in the Dismissed escape
/// hatch view via [dismissedHandlesProvider].
///
/// Copied from [strayHandles].
@ProviderFor(strayHandles)
final strayHandlesProvider =
    AutoDisposeFutureProvider<List<StrayHandleSummary>>.internal(
      strayHandles,
      name: r'strayHandlesProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$strayHandlesHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef StrayHandlesRef =
    AutoDisposeFutureProviderRef<List<StrayHandleSummary>>;
String _$spamCandidateHandlesHash() =>
    r'f11874bcb1c15f4dab78cc276dd096a43f025558';

/// Returns only stray handles that match junk-like heuristics.
///
/// Copied from [spamCandidateHandles].
@ProviderFor(spamCandidateHandles)
final spamCandidateHandlesProvider =
    AutoDisposeFutureProvider<List<StrayHandleSummary>>.internal(
      spamCandidateHandles,
      name: r'spamCandidateHandlesProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$spamCandidateHandlesHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SpamCandidateHandlesRef =
    AutoDisposeFutureProviderRef<List<StrayHandleSummary>>;
String _$dismissedHandlesHash() => r'dd449e24e25f0f42fb977aa65f385eb7c2d5bf9a';

/// Returns only dismissed handles for the escape hatch view.
///
/// Copied from [dismissedHandles].
@ProviderFor(dismissedHandles)
final dismissedHandlesProvider =
    AutoDisposeFutureProvider<List<StrayHandleSummary>>.internal(
      dismissedHandles,
      name: r'dismissedHandlesProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$dismissedHandlesHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DismissedHandlesRef =
    AutoDisposeFutureProviderRef<List<StrayHandleSummary>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
