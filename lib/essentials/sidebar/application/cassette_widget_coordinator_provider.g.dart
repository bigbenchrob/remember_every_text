// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cassette_widget_coordinator_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$cassetteWidgetCoordinatorHash() =>
    r'422c10740c26fa286c9f7252df50a7de56d2445d';

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

abstract class _$CassetteWidgetCoordinator
    extends BuildlessAutoDisposeAsyncNotifier<List<ResolvedSidebarCassette>> {
  late final SidebarMode mode;

  FutureOr<List<ResolvedSidebarCassette>> build(SidebarMode mode);
}

/// See also [CassetteWidgetCoordinator].
@ProviderFor(CassetteWidgetCoordinator)
const cassetteWidgetCoordinatorProvider = CassetteWidgetCoordinatorFamily();

/// See also [CassetteWidgetCoordinator].
class CassetteWidgetCoordinatorFamily
    extends Family<AsyncValue<List<ResolvedSidebarCassette>>> {
  /// See also [CassetteWidgetCoordinator].
  const CassetteWidgetCoordinatorFamily();

  /// See also [CassetteWidgetCoordinator].
  CassetteWidgetCoordinatorProvider call(SidebarMode mode) {
    return CassetteWidgetCoordinatorProvider(mode);
  }

  @override
  CassetteWidgetCoordinatorProvider getProviderOverride(
    covariant CassetteWidgetCoordinatorProvider provider,
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
  String? get name => r'cassetteWidgetCoordinatorProvider';
}

/// See also [CassetteWidgetCoordinator].
class CassetteWidgetCoordinatorProvider
    extends
        AutoDisposeAsyncNotifierProviderImpl<
          CassetteWidgetCoordinator,
          List<ResolvedSidebarCassette>
        > {
  /// See also [CassetteWidgetCoordinator].
  CassetteWidgetCoordinatorProvider(SidebarMode mode)
    : this._internal(
        () => CassetteWidgetCoordinator()..mode = mode,
        from: cassetteWidgetCoordinatorProvider,
        name: r'cassetteWidgetCoordinatorProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$cassetteWidgetCoordinatorHash,
        dependencies: CassetteWidgetCoordinatorFamily._dependencies,
        allTransitiveDependencies:
            CassetteWidgetCoordinatorFamily._allTransitiveDependencies,
        mode: mode,
      );

  CassetteWidgetCoordinatorProvider._internal(
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
  FutureOr<List<ResolvedSidebarCassette>> runNotifierBuild(
    covariant CassetteWidgetCoordinator notifier,
  ) {
    return notifier.build(mode);
  }

  @override
  Override overrideWith(CassetteWidgetCoordinator Function() create) {
    return ProviderOverride(
      origin: this,
      override: CassetteWidgetCoordinatorProvider._internal(
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
  AutoDisposeAsyncNotifierProviderElement<
    CassetteWidgetCoordinator,
    List<ResolvedSidebarCassette>
  >
  createElement() {
    return _CassetteWidgetCoordinatorProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CassetteWidgetCoordinatorProvider && other.mode == mode;
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
mixin CassetteWidgetCoordinatorRef
    on AutoDisposeAsyncNotifierProviderRef<List<ResolvedSidebarCassette>> {
  /// The parameter `mode` of this provider.
  SidebarMode get mode;
}

class _CassetteWidgetCoordinatorProviderElement
    extends
        AutoDisposeAsyncNotifierProviderElement<
          CassetteWidgetCoordinator,
          List<ResolvedSidebarCassette>
        >
    with CassetteWidgetCoordinatorRef {
  _CassetteWidgetCoordinatorProviderElement(super.provider);

  @override
  SidebarMode get mode => (origin as CassetteWidgetCoordinatorProvider).mode;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
