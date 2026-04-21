// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'renderable_sidebar_cassette_specs_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$renderableSidebarCassetteSpecsHash() =>
    r'218dfffa4c9895ac50a91b4b1d3818f6f656525f';

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

/// See also [renderableSidebarCassetteSpecs].
@ProviderFor(renderableSidebarCassetteSpecs)
const renderableSidebarCassetteSpecsProvider =
    RenderableSidebarCassetteSpecsFamily();

/// See also [renderableSidebarCassetteSpecs].
class RenderableSidebarCassetteSpecsFamily
    extends Family<List<RenderableSidebarCassetteSpec>> {
  /// See also [renderableSidebarCassetteSpecs].
  const RenderableSidebarCassetteSpecsFamily();

  /// See also [renderableSidebarCassetteSpecs].
  RenderableSidebarCassetteSpecsProvider call(SidebarMode mode) {
    return RenderableSidebarCassetteSpecsProvider(mode);
  }

  @override
  RenderableSidebarCassetteSpecsProvider getProviderOverride(
    covariant RenderableSidebarCassetteSpecsProvider provider,
  ) {
    return call(provider.mode);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'renderableSidebarCassetteSpecsProvider';
}

/// See also [renderableSidebarCassetteSpecs].
class RenderableSidebarCassetteSpecsProvider
    extends AutoDisposeProvider<List<RenderableSidebarCassetteSpec>> {
  /// See also [renderableSidebarCassetteSpecs].
  RenderableSidebarCassetteSpecsProvider(SidebarMode mode)
    : this._internal(
        (ref) => renderableSidebarCassetteSpecs(
          ref as RenderableSidebarCassetteSpecsRef,
          mode,
        ),
        from: renderableSidebarCassetteSpecsProvider,
        name: r'renderableSidebarCassetteSpecsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$renderableSidebarCassetteSpecsHash,
        dependencies: RenderableSidebarCassetteSpecsFamily._dependencies,
        allTransitiveDependencies:
            RenderableSidebarCassetteSpecsFamily._allTransitiveDependencies,
        mode: mode,
      );

  RenderableSidebarCassetteSpecsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.mode,
  }) : super.internal();

  final SidebarMode mode;

  @override
  Override overrideWith(
    List<RenderableSidebarCassetteSpec> Function(
      RenderableSidebarCassetteSpecsRef provider,
    )
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: RenderableSidebarCassetteSpecsProvider._internal(
        (ref) => create(ref as RenderableSidebarCassetteSpecsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        mode: mode,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<List<RenderableSidebarCassetteSpec>>
  createElement() {
    return _RenderableSidebarCassetteSpecsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is RenderableSidebarCassetteSpecsProvider &&
        other.mode == mode;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, mode.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin RenderableSidebarCassetteSpecsRef
    on AutoDisposeProviderRef<List<RenderableSidebarCassetteSpec>> {
  /// The parameter `mode` of this provider.
  SidebarMode get mode;
}

class _RenderableSidebarCassetteSpecsProviderElement
    extends AutoDisposeProviderElement<List<RenderableSidebarCassetteSpec>>
    with RenderableSidebarCassetteSpecsRef {
  _RenderableSidebarCassetteSpecsProviderElement(super.provider);

  @override
  SidebarMode get mode =>
      (origin as RenderableSidebarCassetteSpecsProvider).mode;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
