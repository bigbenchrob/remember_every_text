// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ephemeral_cassette_projection_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$ephemeralCassetteProjectionHash() =>
    r'02f5dd090dfa5a7289f14105f0d3a49e1d6452bb';

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

abstract class _$EphemeralCassetteProjection
    extends BuildlessAutoDisposeNotifier<CassetteRack> {
  late final SidebarMode mode;

  CassetteRack build(SidebarMode mode);
}

/// See also [EphemeralCassetteProjection].
@ProviderFor(EphemeralCassetteProjection)
const ephemeralCassetteProjectionProvider = EphemeralCassetteProjectionFamily();

/// See also [EphemeralCassetteProjection].
class EphemeralCassetteProjectionFamily extends Family<CassetteRack> {
  /// See also [EphemeralCassetteProjection].
  const EphemeralCassetteProjectionFamily();

  /// See also [EphemeralCassetteProjection].
  EphemeralCassetteProjectionProvider call(SidebarMode mode) {
    return EphemeralCassetteProjectionProvider(mode);
  }

  @override
  EphemeralCassetteProjectionProvider getProviderOverride(
    covariant EphemeralCassetteProjectionProvider provider,
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
  String? get name => r'ephemeralCassetteProjectionProvider';
}

/// See also [EphemeralCassetteProjection].
class EphemeralCassetteProjectionProvider
    extends
        AutoDisposeNotifierProviderImpl<
          EphemeralCassetteProjection,
          CassetteRack
        > {
  /// See also [EphemeralCassetteProjection].
  EphemeralCassetteProjectionProvider(SidebarMode mode)
    : this._internal(
        () => EphemeralCassetteProjection()..mode = mode,
        from: ephemeralCassetteProjectionProvider,
        name: r'ephemeralCassetteProjectionProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$ephemeralCassetteProjectionHash,
        dependencies: EphemeralCassetteProjectionFamily._dependencies,
        allTransitiveDependencies:
            EphemeralCassetteProjectionFamily._allTransitiveDependencies,
        mode: mode,
      );

  EphemeralCassetteProjectionProvider._internal(
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
  CassetteRack runNotifierBuild(
    covariant EphemeralCassetteProjection notifier,
  ) {
    return notifier.build(mode);
  }

  @override
  Override overrideWith(EphemeralCassetteProjection Function() create) {
    return ProviderOverride(
      origin: this,
      override: EphemeralCassetteProjectionProvider._internal(
        () => create()..mode = mode,
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
  AutoDisposeNotifierProviderElement<EphemeralCassetteProjection, CassetteRack>
  createElement() {
    return _EphemeralCassetteProjectionProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is EphemeralCassetteProjectionProvider && other.mode == mode;
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
mixin EphemeralCassetteProjectionRef
    on AutoDisposeNotifierProviderRef<CassetteRack> {
  /// The parameter `mode` of this provider.
  SidebarMode get mode;
}

class _EphemeralCassetteProjectionProviderElement
    extends
        AutoDisposeNotifierProviderElement<
          EphemeralCassetteProjection,
          CassetteRack
        >
    with EphemeralCassetteProjectionRef {
  _EphemeralCassetteProjectionProviderElement(super.provider);

  @override
  SidebarMode get mode => (origin as EphemeralCassetteProjectionProvider).mode;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
