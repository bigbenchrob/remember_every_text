// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feature_level_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$handleVisibilityStoreHash() =>
    r'4dc6fe44329ef504519d470d539d1439aa896ed5';

/// See also [handleVisibilityStore].
@ProviderFor(handleVisibilityStore)
final handleVisibilityStoreProvider =
    AutoDisposeFutureProvider<HandleVisibilityStore>.internal(
      handleVisibilityStore,
      name: r'handleVisibilityStoreProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$handleVisibilityStoreHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef HandleVisibilityStoreRef =
    AutoDisposeFutureProviderRef<HandleVisibilityStore>;
String _$handleReviewStoreHash() => r'14962c581229d4ee1094826a2710bb64c88a6a49';

/// See also [handleReviewStore].
@ProviderFor(handleReviewStore)
final handleReviewStoreProvider =
    AutoDisposeFutureProvider<HandleReviewStore>.internal(
      handleReviewStore,
      name: r'handleReviewStoreProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$handleReviewStoreHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef HandleReviewStoreRef = AutoDisposeFutureProviderRef<HandleReviewStore>;
String _$manualLinkingReadRepositoryHash() =>
    r'136908eecf3fe530dc937115bfb573fcf6b54317';

/// See also [manualLinkingReadRepository].
@ProviderFor(manualLinkingReadRepository)
final manualLinkingReadRepositoryProvider =
    AutoDisposeFutureProvider<ManualLinkingReadRepository>.internal(
      manualLinkingReadRepository,
      name: r'manualLinkingReadRepositoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$manualLinkingReadRepositoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ManualLinkingReadRepositoryRef =
    AutoDisposeFutureProviderRef<ManualLinkingReadRepository>;
String _$spamHandlesRepositoryHash() =>
    r'01e5c577796a3bc5e2412d3a5dce1fa75f7b673b';

/// See also [spamHandlesRepository].
@ProviderFor(spamHandlesRepository)
final spamHandlesRepositoryProvider =
    AutoDisposeFutureProvider<SpamHandlesRepository>.internal(
      spamHandlesRepository,
      name: r'spamHandlesRepositoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$spamHandlesRepositoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SpamHandlesRepositoryRef =
    AutoDisposeFutureProviderRef<SpamHandlesRepository>;
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
String _$handleDisplayNameReaderHash() =>
    r'51bbb68ccdc067ef0bbd425a7cbdf9ba6bcde86a';

/// See also [handleDisplayNameReader].
@ProviderFor(handleDisplayNameReader)
final handleDisplayNameReaderProvider =
    AutoDisposeFutureProvider<HandleDisplayNameReader>.internal(
      handleDisplayNameReader,
      name: r'handleDisplayNameReaderProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$handleDisplayNameReaderHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef HandleDisplayNameReaderRef =
    AutoDisposeFutureProviderRef<HandleDisplayNameReader>;
String _$handleDisplayNameHash() => r'f6685677a3f13d53d52bf64bc8f48ca41c82000e';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [handleDisplayName].
@ProviderFor(handleDisplayName)
const handleDisplayNameProvider = HandleDisplayNameFamily();

/// See also [handleDisplayName].
class HandleDisplayNameFamily extends Family<AsyncValue<String>> {
  /// See also [handleDisplayName].
  const HandleDisplayNameFamily();

  /// See also [handleDisplayName].
  HandleDisplayNameProvider call({required int handleId}) {
    return HandleDisplayNameProvider(handleId: handleId);
  }

  @override
  HandleDisplayNameProvider getProviderOverride(
    covariant HandleDisplayNameProvider provider,
  ) {
    return call(handleId: provider.handleId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'handleDisplayNameProvider';
}

/// See also [handleDisplayName].
class HandleDisplayNameProvider extends AutoDisposeFutureProvider<String> {
  /// See also [handleDisplayName].
  HandleDisplayNameProvider({required int handleId})
    : this._internal(
        (ref) =>
            handleDisplayName(ref as HandleDisplayNameRef, handleId: handleId),
        from: handleDisplayNameProvider,
        name: r'handleDisplayNameProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$handleDisplayNameHash,
        dependencies: HandleDisplayNameFamily._dependencies,
        allTransitiveDependencies:
            HandleDisplayNameFamily._allTransitiveDependencies,
        handleId: handleId,
      );

  HandleDisplayNameProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.handleId,
  }) : super.internal();

  final int handleId;

  @override
  Override overrideWith(
    FutureOr<String> Function(HandleDisplayNameRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: HandleDisplayNameProvider._internal(
        (ref) => create(ref as HandleDisplayNameRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        handleId: handleId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<String> createElement() {
    return _HandleDisplayNameProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is HandleDisplayNameProvider && other.handleId == handleId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, handleId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin HandleDisplayNameRef on AutoDisposeFutureProviderRef<String> {
  /// The parameter `handleId` of this provider.
  int get handleId;
}

class _HandleDisplayNameProviderElement
    extends AutoDisposeFutureProviderElement<String>
    with HandleDisplayNameRef {
  _HandleDisplayNameProviderElement(super.provider);

  @override
  int get handleId => (origin as HandleDisplayNameProvider).handleId;
}

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
String _$handleReviewActionsHash() =>
    r'ef49c7e52dd93bdd6f42c80a8b0a58be24bed9b9';

/// See also [HandleReviewActions].
@ProviderFor(HandleReviewActions)
final handleReviewActionsProvider =
    AutoDisposeAsyncNotifierProvider<HandleReviewActions, void>.internal(
      HandleReviewActions.new,
      name: r'handleReviewActionsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$handleReviewActionsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$HandleReviewActions = AutoDisposeAsyncNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
