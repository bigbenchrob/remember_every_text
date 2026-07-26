// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'handle_source_presentation_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$handleSourcePresentationHash() =>
    r'b8982a916843f8659c1b39ec71442761a5248c65';

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

/// Provides the canonical identity projection for one source.
///
/// Messages owns the complete handle-lens ViewSpec presentation. Handles owns
/// this source identity projection so collaborating presentations cannot invent
/// different fallback labels or source-review wording.
///
/// Copied from [handleSourcePresentation].
@ProviderFor(handleSourcePresentation)
const handleSourcePresentationProvider = HandleSourcePresentationFamily();

/// Provides the canonical identity projection for one source.
///
/// Messages owns the complete handle-lens ViewSpec presentation. Handles owns
/// this source identity projection so collaborating presentations cannot invent
/// different fallback labels or source-review wording.
///
/// Copied from [handleSourcePresentation].
class HandleSourcePresentationFamily
    extends Family<AsyncValue<HandleSourcePresentation>> {
  /// Provides the canonical identity projection for one source.
  ///
  /// Messages owns the complete handle-lens ViewSpec presentation. Handles owns
  /// this source identity projection so collaborating presentations cannot invent
  /// different fallback labels or source-review wording.
  ///
  /// Copied from [handleSourcePresentation].
  const HandleSourcePresentationFamily();

  /// Provides the canonical identity projection for one source.
  ///
  /// Messages owns the complete handle-lens ViewSpec presentation. Handles owns
  /// this source identity projection so collaborating presentations cannot invent
  /// different fallback labels or source-review wording.
  ///
  /// Copied from [handleSourcePresentation].
  HandleSourcePresentationProvider call({required int handleId}) {
    return HandleSourcePresentationProvider(handleId: handleId);
  }

  @override
  HandleSourcePresentationProvider getProviderOverride(
    covariant HandleSourcePresentationProvider provider,
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
  String? get name => r'handleSourcePresentationProvider';
}

/// Provides the canonical identity projection for one source.
///
/// Messages owns the complete handle-lens ViewSpec presentation. Handles owns
/// this source identity projection so collaborating presentations cannot invent
/// different fallback labels or source-review wording.
///
/// Copied from [handleSourcePresentation].
class HandleSourcePresentationProvider
    extends AutoDisposeFutureProvider<HandleSourcePresentation> {
  /// Provides the canonical identity projection for one source.
  ///
  /// Messages owns the complete handle-lens ViewSpec presentation. Handles owns
  /// this source identity projection so collaborating presentations cannot invent
  /// different fallback labels or source-review wording.
  ///
  /// Copied from [handleSourcePresentation].
  HandleSourcePresentationProvider({required int handleId})
    : this._internal(
        (ref) => handleSourcePresentation(
          ref as HandleSourcePresentationRef,
          handleId: handleId,
        ),
        from: handleSourcePresentationProvider,
        name: r'handleSourcePresentationProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$handleSourcePresentationHash,
        dependencies: HandleSourcePresentationFamily._dependencies,
        allTransitiveDependencies:
            HandleSourcePresentationFamily._allTransitiveDependencies,
        handleId: handleId,
      );

  HandleSourcePresentationProvider._internal(
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
    FutureOr<HandleSourcePresentation> Function(
      HandleSourcePresentationRef provider,
    )
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: HandleSourcePresentationProvider._internal(
        (ref) => create(ref as HandleSourcePresentationRef),
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
  AutoDisposeFutureProviderElement<HandleSourcePresentation> createElement() {
    return _HandleSourcePresentationProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is HandleSourcePresentationProvider &&
        other.handleId == handleId;
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
mixin HandleSourcePresentationRef
    on AutoDisposeFutureProviderRef<HandleSourcePresentation> {
  /// The parameter `handleId` of this provider.
  int get handleId;
}

class _HandleSourcePresentationProviderElement
    extends AutoDisposeFutureProviderElement<HandleSourcePresentation>
    with HandleSourcePresentationRef {
  _HandleSourcePresentationProviderElement(super.provider);

  @override
  int get handleId => (origin as HandleSourcePresentationProvider).handleId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
