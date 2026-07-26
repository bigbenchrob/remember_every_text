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
String _$unknownSourceIdentificationHandlesHash() =>
    r'7489d31836807c30a52291a85a9c5c13cc4c7eeb';

/// Returns active unresolved endpoints compatible with identity discovery.
///
/// Copied from [unknownSourceIdentificationHandles].
@ProviderFor(unknownSourceIdentificationHandles)
final unknownSourceIdentificationHandlesProvider =
    AutoDisposeProvider<AsyncValue<List<StrayHandleSummary>>>.internal(
      unknownSourceIdentificationHandles,
      name: r'unknownSourceIdentificationHandlesProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$unknownSourceIdentificationHandlesHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef UnknownSourceIdentificationHandlesRef =
    AutoDisposeProviderRef<AsyncValue<List<StrayHandleSummary>>>;
String _$numericSenderIdHandlesHash() =>
    r'de54eb5633b77727cb5796a8b01c8cdf54eedea1';

/// Returns active unresolved endpoints with the structural shape of a short
/// code. This is not a spam or automation verdict.
///
/// Copied from [numericSenderIdHandles].
@ProviderFor(numericSenderIdHandles)
final numericSenderIdHandlesProvider =
    AutoDisposeProvider<AsyncValue<List<StrayHandleSummary>>>.internal(
      numericSenderIdHandles,
      name: r'numericSenderIdHandlesProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$numericSenderIdHandlesHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef NumericSenderIdHandlesRef =
    AutoDisposeProviderRef<AsyncValue<List<StrayHandleSummary>>>;
String _$dismissedUnknownSourceIdentificationHandlesHash() =>
    r'67552f098101e422e230b147d74017f3af026791';

/// Returns dismissed endpoints compatible with identity discovery.
///
/// Copied from [dismissedUnknownSourceIdentificationHandles].
@ProviderFor(dismissedUnknownSourceIdentificationHandles)
final dismissedUnknownSourceIdentificationHandlesProvider =
    AutoDisposeProvider<AsyncValue<List<StrayHandleSummary>>>.internal(
      dismissedUnknownSourceIdentificationHandles,
      name: r'dismissedUnknownSourceIdentificationHandlesProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$dismissedUnknownSourceIdentificationHandlesHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DismissedUnknownSourceIdentificationHandlesRef =
    AutoDisposeProviderRef<AsyncValue<List<StrayHandleSummary>>>;
String _$dismissedNumericSenderIdHandlesHash() =>
    r'0c00ac2c1efec7ea5aa28941e786a16508e65b03';

/// Returns dismissed endpoints with the structural shape of a short code.
///
/// Copied from [dismissedNumericSenderIdHandles].
@ProviderFor(dismissedNumericSenderIdHandles)
final dismissedNumericSenderIdHandlesProvider =
    AutoDisposeProvider<AsyncValue<List<StrayHandleSummary>>>.internal(
      dismissedNumericSenderIdHandles,
      name: r'dismissedNumericSenderIdHandlesProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$dismissedNumericSenderIdHandlesHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DismissedNumericSenderIdHandlesRef =
    AutoDisposeProviderRef<AsyncValue<List<StrayHandleSummary>>>;
String _$strayHandlesHash() => r'9ec19f40ea3f2f82e6dce760cd398742a273fed6';

/// Returns all handles that are truly "stray": no graph contact link and no
/// linked override (participant or virtual participant) in the overlay DB.
///
/// Handles with an overlay row that has only `reviewed_at` set (both
/// participant IDs null) are still included — they are reviewed but unlinked.
///
/// Excludes dismissed handles; those are only visible in the Dismissed escape
/// hatch view via [dismissedHandlesProvider].
///
/// Copied from [StrayHandles].
@ProviderFor(StrayHandles)
final strayHandlesProvider =
    AsyncNotifierProvider<StrayHandles, List<StrayHandleSummary>>.internal(
      StrayHandles.new,
      name: r'strayHandlesProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$strayHandlesHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$StrayHandles = AsyncNotifier<List<StrayHandleSummary>>;
String _$dismissedHandlesHash() => r'2a676ed35b8f3eb4a93753866713cc40d5b3ad27';

/// Returns only dismissed handles for the escape hatch view.
///
/// Copied from [DismissedHandles].
@ProviderFor(DismissedHandles)
final dismissedHandlesProvider =
    AsyncNotifierProvider<DismissedHandles, List<StrayHandleSummary>>.internal(
      DismissedHandles.new,
      name: r'dismissedHandlesProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$dismissedHandlesHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$DismissedHandles = AsyncNotifier<List<StrayHandleSummary>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
