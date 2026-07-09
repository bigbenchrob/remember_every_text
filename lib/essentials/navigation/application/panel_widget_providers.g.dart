// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'panel_widget_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$effectiveCenterPanelStackHash() =>
    r'36c8b5c78216cac762ba409d8201e4cda31fe707';

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

/// See also [effectiveCenterPanelStack].
@ProviderFor(effectiveCenterPanelStack)
const effectiveCenterPanelStackProvider = EffectiveCenterPanelStackFamily();

/// See also [effectiveCenterPanelStack].
class EffectiveCenterPanelStackFamily extends Family<PanelStack> {
  /// See also [effectiveCenterPanelStack].
  const EffectiveCenterPanelStackFamily();

  /// See also [effectiveCenterPanelStack].
  EffectiveCenterPanelStackProvider call(SidebarMode mode) {
    return EffectiveCenterPanelStackProvider(mode);
  }

  @override
  EffectiveCenterPanelStackProvider getProviderOverride(
    covariant EffectiveCenterPanelStackProvider provider,
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
  String? get name => r'effectiveCenterPanelStackProvider';
}

/// See also [effectiveCenterPanelStack].
class EffectiveCenterPanelStackProvider
    extends AutoDisposeProvider<PanelStack> {
  /// See also [effectiveCenterPanelStack].
  EffectiveCenterPanelStackProvider(SidebarMode mode)
    : this._internal(
        (ref) => effectiveCenterPanelStack(
          ref as EffectiveCenterPanelStackRef,
          mode,
        ),
        from: effectiveCenterPanelStackProvider,
        name: r'effectiveCenterPanelStackProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$effectiveCenterPanelStackHash,
        dependencies: EffectiveCenterPanelStackFamily._dependencies,
        allTransitiveDependencies:
            EffectiveCenterPanelStackFamily._allTransitiveDependencies,
        mode: mode,
      );

  EffectiveCenterPanelStackProvider._internal(
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
    PanelStack Function(EffectiveCenterPanelStackRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: EffectiveCenterPanelStackProvider._internal(
        (ref) => create(ref as EffectiveCenterPanelStackRef),
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
  AutoDisposeProviderElement<PanelStack> createElement() {
    return _EffectiveCenterPanelStackProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is EffectiveCenterPanelStackProvider && other.mode == mode;
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
mixin EffectiveCenterPanelStackRef on AutoDisposeProviderRef<PanelStack> {
  /// The parameter `mode` of this provider.
  SidebarMode get mode;
}

class _EffectiveCenterPanelStackProviderElement
    extends AutoDisposeProviderElement<PanelStack>
    with EffectiveCenterPanelStackRef {
  _EffectiveCenterPanelStackProviderElement(super.provider);

  @override
  SidebarMode get mode => (origin as EffectiveCenterPanelStackProvider).mode;
}

String _$effectiveCenterPanelSpecHash() =>
    r'8d32ced3cec68de0dfa2d88c89c6c705c993b5c7';

/// See also [effectiveCenterPanelSpec].
@ProviderFor(effectiveCenterPanelSpec)
const effectiveCenterPanelSpecProvider = EffectiveCenterPanelSpecFamily();

/// See also [effectiveCenterPanelSpec].
class EffectiveCenterPanelSpecFamily extends Family<ViewSpec?> {
  /// See also [effectiveCenterPanelSpec].
  const EffectiveCenterPanelSpecFamily();

  /// See also [effectiveCenterPanelSpec].
  EffectiveCenterPanelSpecProvider call(SidebarMode mode) {
    return EffectiveCenterPanelSpecProvider(mode);
  }

  @override
  EffectiveCenterPanelSpecProvider getProviderOverride(
    covariant EffectiveCenterPanelSpecProvider provider,
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
  String? get name => r'effectiveCenterPanelSpecProvider';
}

/// See also [effectiveCenterPanelSpec].
class EffectiveCenterPanelSpecProvider extends AutoDisposeProvider<ViewSpec?> {
  /// See also [effectiveCenterPanelSpec].
  EffectiveCenterPanelSpecProvider(SidebarMode mode)
    : this._internal(
        (ref) =>
            effectiveCenterPanelSpec(ref as EffectiveCenterPanelSpecRef, mode),
        from: effectiveCenterPanelSpecProvider,
        name: r'effectiveCenterPanelSpecProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$effectiveCenterPanelSpecHash,
        dependencies: EffectiveCenterPanelSpecFamily._dependencies,
        allTransitiveDependencies:
            EffectiveCenterPanelSpecFamily._allTransitiveDependencies,
        mode: mode,
      );

  EffectiveCenterPanelSpecProvider._internal(
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
    ViewSpec? Function(EffectiveCenterPanelSpecRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: EffectiveCenterPanelSpecProvider._internal(
        (ref) => create(ref as EffectiveCenterPanelSpecRef),
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
  AutoDisposeProviderElement<ViewSpec?> createElement() {
    return _EffectiveCenterPanelSpecProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is EffectiveCenterPanelSpecProvider && other.mode == mode;
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
mixin EffectiveCenterPanelSpecRef on AutoDisposeProviderRef<ViewSpec?> {
  /// The parameter `mode` of this provider.
  SidebarMode get mode;
}

class _EffectiveCenterPanelSpecProviderElement
    extends AutoDisposeProviderElement<ViewSpec?>
    with EffectiveCenterPanelSpecRef {
  _EffectiveCenterPanelSpecProviderElement(super.provider);

  @override
  SidebarMode get mode => (origin as EffectiveCenterPanelSpecProvider).mode;
}

String _$effectiveRightPanelStackHash() =>
    r'52cbc7193e85262e3a54e3e5f9639a80ad1c3088';

/// See also [effectiveRightPanelStack].
@ProviderFor(effectiveRightPanelStack)
const effectiveRightPanelStackProvider = EffectiveRightPanelStackFamily();

/// See also [effectiveRightPanelStack].
class EffectiveRightPanelStackFamily extends Family<PanelStack> {
  /// See also [effectiveRightPanelStack].
  const EffectiveRightPanelStackFamily();

  /// See also [effectiveRightPanelStack].
  EffectiveRightPanelStackProvider call(SidebarMode mode) {
    return EffectiveRightPanelStackProvider(mode);
  }

  @override
  EffectiveRightPanelStackProvider getProviderOverride(
    covariant EffectiveRightPanelStackProvider provider,
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
  String? get name => r'effectiveRightPanelStackProvider';
}

/// See also [effectiveRightPanelStack].
class EffectiveRightPanelStackProvider extends AutoDisposeProvider<PanelStack> {
  /// See also [effectiveRightPanelStack].
  EffectiveRightPanelStackProvider(SidebarMode mode)
    : this._internal(
        (ref) =>
            effectiveRightPanelStack(ref as EffectiveRightPanelStackRef, mode),
        from: effectiveRightPanelStackProvider,
        name: r'effectiveRightPanelStackProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$effectiveRightPanelStackHash,
        dependencies: EffectiveRightPanelStackFamily._dependencies,
        allTransitiveDependencies:
            EffectiveRightPanelStackFamily._allTransitiveDependencies,
        mode: mode,
      );

  EffectiveRightPanelStackProvider._internal(
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
    PanelStack Function(EffectiveRightPanelStackRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: EffectiveRightPanelStackProvider._internal(
        (ref) => create(ref as EffectiveRightPanelStackRef),
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
  AutoDisposeProviderElement<PanelStack> createElement() {
    return _EffectiveRightPanelStackProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is EffectiveRightPanelStackProvider && other.mode == mode;
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
mixin EffectiveRightPanelStackRef on AutoDisposeProviderRef<PanelStack> {
  /// The parameter `mode` of this provider.
  SidebarMode get mode;
}

class _EffectiveRightPanelStackProviderElement
    extends AutoDisposeProviderElement<PanelStack>
    with EffectiveRightPanelStackRef {
  _EffectiveRightPanelStackProviderElement(super.provider);

  @override
  SidebarMode get mode => (origin as EffectiveRightPanelStackProvider).mode;
}

String _$effectiveRightPanelSpecHash() =>
    r'07b58eaa2007dc11cbf9aae4dcb1a99996fa0455';

/// See also [effectiveRightPanelSpec].
@ProviderFor(effectiveRightPanelSpec)
const effectiveRightPanelSpecProvider = EffectiveRightPanelSpecFamily();

/// See also [effectiveRightPanelSpec].
class EffectiveRightPanelSpecFamily extends Family<ViewSpec?> {
  /// See also [effectiveRightPanelSpec].
  const EffectiveRightPanelSpecFamily();

  /// See also [effectiveRightPanelSpec].
  EffectiveRightPanelSpecProvider call(SidebarMode mode) {
    return EffectiveRightPanelSpecProvider(mode);
  }

  @override
  EffectiveRightPanelSpecProvider getProviderOverride(
    covariant EffectiveRightPanelSpecProvider provider,
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
  String? get name => r'effectiveRightPanelSpecProvider';
}

/// See also [effectiveRightPanelSpec].
class EffectiveRightPanelSpecProvider extends AutoDisposeProvider<ViewSpec?> {
  /// See also [effectiveRightPanelSpec].
  EffectiveRightPanelSpecProvider(SidebarMode mode)
    : this._internal(
        (ref) =>
            effectiveRightPanelSpec(ref as EffectiveRightPanelSpecRef, mode),
        from: effectiveRightPanelSpecProvider,
        name: r'effectiveRightPanelSpecProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$effectiveRightPanelSpecHash,
        dependencies: EffectiveRightPanelSpecFamily._dependencies,
        allTransitiveDependencies:
            EffectiveRightPanelSpecFamily._allTransitiveDependencies,
        mode: mode,
      );

  EffectiveRightPanelSpecProvider._internal(
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
    ViewSpec? Function(EffectiveRightPanelSpecRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: EffectiveRightPanelSpecProvider._internal(
        (ref) => create(ref as EffectiveRightPanelSpecRef),
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
  AutoDisposeProviderElement<ViewSpec?> createElement() {
    return _EffectiveRightPanelSpecProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is EffectiveRightPanelSpecProvider && other.mode == mode;
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
mixin EffectiveRightPanelSpecRef on AutoDisposeProviderRef<ViewSpec?> {
  /// The parameter `mode` of this provider.
  SidebarMode get mode;
}

class _EffectiveRightPanelSpecProviderElement
    extends AutoDisposeProviderElement<ViewSpec?>
    with EffectiveRightPanelSpecRef {
  _EffectiveRightPanelSpecProviderElement(super.provider);

  @override
  SidebarMode get mode => (origin as EffectiveRightPanelSpecProvider).mode;
}

String _$isSidebarParkedHash() => r'68b5bfb67126e36b1347605de9f07193616c26d1';

/// Whether the center panel is showing content that operates independently
/// of the sidebar (e.g. maintenance, diagnostics, workbench).
///
/// When true, the sidebar should display a contextual overlay with a
/// dismiss action rather than the cassette rack.
///
/// Copied from [isSidebarParked].
@ProviderFor(isSidebarParked)
const isSidebarParkedProvider = IsSidebarParkedFamily();

/// Whether the center panel is showing content that operates independently
/// of the sidebar (e.g. maintenance, diagnostics, workbench).
///
/// When true, the sidebar should display a contextual overlay with a
/// dismiss action rather than the cassette rack.
///
/// Copied from [isSidebarParked].
class IsSidebarParkedFamily extends Family<bool> {
  /// Whether the center panel is showing content that operates independently
  /// of the sidebar (e.g. maintenance, diagnostics, workbench).
  ///
  /// When true, the sidebar should display a contextual overlay with a
  /// dismiss action rather than the cassette rack.
  ///
  /// Copied from [isSidebarParked].
  const IsSidebarParkedFamily();

  /// Whether the center panel is showing content that operates independently
  /// of the sidebar (e.g. maintenance, diagnostics, workbench).
  ///
  /// When true, the sidebar should display a contextual overlay with a
  /// dismiss action rather than the cassette rack.
  ///
  /// Copied from [isSidebarParked].
  IsSidebarParkedProvider call(SidebarMode mode) {
    return IsSidebarParkedProvider(mode);
  }

  @override
  IsSidebarParkedProvider getProviderOverride(
    covariant IsSidebarParkedProvider provider,
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
  String? get name => r'isSidebarParkedProvider';
}

/// Whether the center panel is showing content that operates independently
/// of the sidebar (e.g. maintenance, diagnostics, workbench).
///
/// When true, the sidebar should display a contextual overlay with a
/// dismiss action rather than the cassette rack.
///
/// Copied from [isSidebarParked].
class IsSidebarParkedProvider extends AutoDisposeProvider<bool> {
  /// Whether the center panel is showing content that operates independently
  /// of the sidebar (e.g. maintenance, diagnostics, workbench).
  ///
  /// When true, the sidebar should display a contextual overlay with a
  /// dismiss action rather than the cassette rack.
  ///
  /// Copied from [isSidebarParked].
  IsSidebarParkedProvider(SidebarMode mode)
    : this._internal(
        (ref) => isSidebarParked(ref as IsSidebarParkedRef, mode),
        from: isSidebarParkedProvider,
        name: r'isSidebarParkedProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$isSidebarParkedHash,
        dependencies: IsSidebarParkedFamily._dependencies,
        allTransitiveDependencies:
            IsSidebarParkedFamily._allTransitiveDependencies,
        mode: mode,
      );

  IsSidebarParkedProvider._internal(
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
  Override overrideWith(bool Function(IsSidebarParkedRef provider) create) {
    return ProviderOverride(
      origin: this,
      override: IsSidebarParkedProvider._internal(
        (ref) => create(ref as IsSidebarParkedRef),
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
  AutoDisposeProviderElement<bool> createElement() {
    return _IsSidebarParkedProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is IsSidebarParkedProvider && other.mode == mode;
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
mixin IsSidebarParkedRef on AutoDisposeProviderRef<bool> {
  /// The parameter `mode` of this provider.
  SidebarMode get mode;
}

class _IsSidebarParkedProviderElement extends AutoDisposeProviderElement<bool>
    with IsSidebarParkedRef {
  _IsSidebarParkedProviderElement(super.provider);

  @override
  SidebarMode get mode => (origin as IsSidebarParkedProvider).mode;
}

String _$centerPanelWidgetHash() => r'bc55f70ad1cc50730fb3dd953e3bdf566b8a3202';

/// Widget provider for center panel
///
/// Copied from [centerPanelWidget].
@ProviderFor(centerPanelWidget)
const centerPanelWidgetProvider = CenterPanelWidgetFamily();

/// Widget provider for center panel
///
/// Copied from [centerPanelWidget].
class CenterPanelWidgetFamily extends Family<Widget> {
  /// Widget provider for center panel
  ///
  /// Copied from [centerPanelWidget].
  const CenterPanelWidgetFamily();

  /// Widget provider for center panel
  ///
  /// Copied from [centerPanelWidget].
  CenterPanelWidgetProvider call(SidebarMode mode) {
    return CenterPanelWidgetProvider(mode);
  }

  @override
  CenterPanelWidgetProvider getProviderOverride(
    covariant CenterPanelWidgetProvider provider,
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
  String? get name => r'centerPanelWidgetProvider';
}

/// Widget provider for center panel
///
/// Copied from [centerPanelWidget].
class CenterPanelWidgetProvider extends AutoDisposeProvider<Widget> {
  /// Widget provider for center panel
  ///
  /// Copied from [centerPanelWidget].
  CenterPanelWidgetProvider(SidebarMode mode)
    : this._internal(
        (ref) => centerPanelWidget(ref as CenterPanelWidgetRef, mode),
        from: centerPanelWidgetProvider,
        name: r'centerPanelWidgetProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$centerPanelWidgetHash,
        dependencies: CenterPanelWidgetFamily._dependencies,
        allTransitiveDependencies:
            CenterPanelWidgetFamily._allTransitiveDependencies,
        mode: mode,
      );

  CenterPanelWidgetProvider._internal(
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
  Override overrideWith(Widget Function(CenterPanelWidgetRef provider) create) {
    return ProviderOverride(
      origin: this,
      override: CenterPanelWidgetProvider._internal(
        (ref) => create(ref as CenterPanelWidgetRef),
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
  AutoDisposeProviderElement<Widget> createElement() {
    return _CenterPanelWidgetProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CenterPanelWidgetProvider && other.mode == mode;
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
mixin CenterPanelWidgetRef on AutoDisposeProviderRef<Widget> {
  /// The parameter `mode` of this provider.
  SidebarMode get mode;
}

class _CenterPanelWidgetProviderElement
    extends AutoDisposeProviderElement<Widget>
    with CenterPanelWidgetRef {
  _CenterPanelWidgetProviderElement(super.provider);

  @override
  SidebarMode get mode => (origin as CenterPanelWidgetProvider).mode;
}

String _$rightPanelWidgetHash() => r'36471825d67925cbaf2b4abb38aced08cae2d989';

/// See also [rightPanelWidget].
@ProviderFor(rightPanelWidget)
const rightPanelWidgetProvider = RightPanelWidgetFamily();

/// See also [rightPanelWidget].
class RightPanelWidgetFamily extends Family<Widget> {
  /// See also [rightPanelWidget].
  const RightPanelWidgetFamily();

  /// See also [rightPanelWidget].
  RightPanelWidgetProvider call(SidebarMode mode) {
    return RightPanelWidgetProvider(mode);
  }

  @override
  RightPanelWidgetProvider getProviderOverride(
    covariant RightPanelWidgetProvider provider,
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
  String? get name => r'rightPanelWidgetProvider';
}

/// See also [rightPanelWidget].
class RightPanelWidgetProvider extends AutoDisposeProvider<Widget> {
  /// See also [rightPanelWidget].
  RightPanelWidgetProvider(SidebarMode mode)
    : this._internal(
        (ref) => rightPanelWidget(ref as RightPanelWidgetRef, mode),
        from: rightPanelWidgetProvider,
        name: r'rightPanelWidgetProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$rightPanelWidgetHash,
        dependencies: RightPanelWidgetFamily._dependencies,
        allTransitiveDependencies:
            RightPanelWidgetFamily._allTransitiveDependencies,
        mode: mode,
      );

  RightPanelWidgetProvider._internal(
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
  Override overrideWith(Widget Function(RightPanelWidgetRef provider) create) {
    return ProviderOverride(
      origin: this,
      override: RightPanelWidgetProvider._internal(
        (ref) => create(ref as RightPanelWidgetRef),
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
  AutoDisposeProviderElement<Widget> createElement() {
    return _RightPanelWidgetProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is RightPanelWidgetProvider && other.mode == mode;
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
mixin RightPanelWidgetRef on AutoDisposeProviderRef<Widget> {
  /// The parameter `mode` of this provider.
  SidebarMode get mode;
}

class _RightPanelWidgetProviderElement
    extends AutoDisposeProviderElement<Widget>
    with RightPanelWidgetRef {
  _RightPanelWidgetProviderElement(super.provider);

  @override
  SidebarMode get mode => (origin as RightPanelWidgetProvider).mode;
}

String _$shouldShowEndSidebarHash() =>
    r'720daf657d8d94671ee3503b36de1f91e5821ed0';

/// See also [shouldShowEndSidebar].
@ProviderFor(shouldShowEndSidebar)
const shouldShowEndSidebarProvider = ShouldShowEndSidebarFamily();

/// See also [shouldShowEndSidebar].
class ShouldShowEndSidebarFamily extends Family<bool> {
  /// See also [shouldShowEndSidebar].
  const ShouldShowEndSidebarFamily();

  /// See also [shouldShowEndSidebar].
  ShouldShowEndSidebarProvider call(SidebarMode mode) {
    return ShouldShowEndSidebarProvider(mode);
  }

  @override
  ShouldShowEndSidebarProvider getProviderOverride(
    covariant ShouldShowEndSidebarProvider provider,
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
  String? get name => r'shouldShowEndSidebarProvider';
}

/// See also [shouldShowEndSidebar].
class ShouldShowEndSidebarProvider extends AutoDisposeProvider<bool> {
  /// See also [shouldShowEndSidebar].
  ShouldShowEndSidebarProvider(SidebarMode mode)
    : this._internal(
        (ref) => shouldShowEndSidebar(ref as ShouldShowEndSidebarRef, mode),
        from: shouldShowEndSidebarProvider,
        name: r'shouldShowEndSidebarProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$shouldShowEndSidebarHash,
        dependencies: ShouldShowEndSidebarFamily._dependencies,
        allTransitiveDependencies:
            ShouldShowEndSidebarFamily._allTransitiveDependencies,
        mode: mode,
      );

  ShouldShowEndSidebarProvider._internal(
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
    bool Function(ShouldShowEndSidebarRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ShouldShowEndSidebarProvider._internal(
        (ref) => create(ref as ShouldShowEndSidebarRef),
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
  AutoDisposeProviderElement<bool> createElement() {
    return _ShouldShowEndSidebarProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ShouldShowEndSidebarProvider && other.mode == mode;
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
mixin ShouldShowEndSidebarRef on AutoDisposeProviderRef<bool> {
  /// The parameter `mode` of this provider.
  SidebarMode get mode;
}

class _ShouldShowEndSidebarProviderElement
    extends AutoDisposeProviderElement<bool>
    with ShouldShowEndSidebarRef {
  _ShouldShowEndSidebarProviderElement(super.provider);

  @override
  SidebarMode get mode => (origin as ShouldShowEndSidebarProvider).mode;
}

String _$contextualSidebarWidgetHash() =>
    r'abc52bff826f4fa3e83dd8672bbaeef1e6d5f3f6';

/// See also [contextualSidebarWidget].
@ProviderFor(contextualSidebarWidget)
const contextualSidebarWidgetProvider = ContextualSidebarWidgetFamily();

/// See also [contextualSidebarWidget].
class ContextualSidebarWidgetFamily extends Family<Widget?> {
  /// See also [contextualSidebarWidget].
  const ContextualSidebarWidgetFamily();

  /// See also [contextualSidebarWidget].
  ContextualSidebarWidgetProvider call(SidebarMode mode) {
    return ContextualSidebarWidgetProvider(mode);
  }

  @override
  ContextualSidebarWidgetProvider getProviderOverride(
    covariant ContextualSidebarWidgetProvider provider,
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
  String? get name => r'contextualSidebarWidgetProvider';
}

/// See also [contextualSidebarWidget].
class ContextualSidebarWidgetProvider extends AutoDisposeProvider<Widget?> {
  /// See also [contextualSidebarWidget].
  ContextualSidebarWidgetProvider(SidebarMode mode)
    : this._internal(
        (ref) =>
            contextualSidebarWidget(ref as ContextualSidebarWidgetRef, mode),
        from: contextualSidebarWidgetProvider,
        name: r'contextualSidebarWidgetProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$contextualSidebarWidgetHash,
        dependencies: ContextualSidebarWidgetFamily._dependencies,
        allTransitiveDependencies:
            ContextualSidebarWidgetFamily._allTransitiveDependencies,
        mode: mode,
      );

  ContextualSidebarWidgetProvider._internal(
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
    Widget? Function(ContextualSidebarWidgetRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ContextualSidebarWidgetProvider._internal(
        (ref) => create(ref as ContextualSidebarWidgetRef),
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
  AutoDisposeProviderElement<Widget?> createElement() {
    return _ContextualSidebarWidgetProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ContextualSidebarWidgetProvider && other.mode == mode;
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
mixin ContextualSidebarWidgetRef on AutoDisposeProviderRef<Widget?> {
  /// The parameter `mode` of this provider.
  SidebarMode get mode;
}

class _ContextualSidebarWidgetProviderElement
    extends AutoDisposeProviderElement<Widget?>
    with ContextualSidebarWidgetRef {
  _ContextualSidebarWidgetProviderElement(super.provider);

  @override
  SidebarMode get mode => (origin as ContextualSidebarWidgetProvider).mode;
}

String _$leftPanelWidgetHash() => r'928ccb41a756cb0b182ebe8412a4a459e20a2972';

/// Widget provider for the left sidebar surface.
///
/// The host reads the aggregate per-cassette resolution state for the current
/// rack and renders only when the visible rack is complete. Per-cassette
/// providers preserve previously resolved values during same-rack reloads,
/// while structural rack changes still blank until the new rack is fully
/// resolved.
///
/// Errors are logged but do not currently surface user-visible recovery UI.
///
/// Copied from [leftPanelWidget].
@ProviderFor(leftPanelWidget)
const leftPanelWidgetProvider = LeftPanelWidgetFamily();

/// Widget provider for the left sidebar surface.
///
/// The host reads the aggregate per-cassette resolution state for the current
/// rack and renders only when the visible rack is complete. Per-cassette
/// providers preserve previously resolved values during same-rack reloads,
/// while structural rack changes still blank until the new rack is fully
/// resolved.
///
/// Errors are logged but do not currently surface user-visible recovery UI.
///
/// Copied from [leftPanelWidget].
class LeftPanelWidgetFamily extends Family<Widget> {
  /// Widget provider for the left sidebar surface.
  ///
  /// The host reads the aggregate per-cassette resolution state for the current
  /// rack and renders only when the visible rack is complete. Per-cassette
  /// providers preserve previously resolved values during same-rack reloads,
  /// while structural rack changes still blank until the new rack is fully
  /// resolved.
  ///
  /// Errors are logged but do not currently surface user-visible recovery UI.
  ///
  /// Copied from [leftPanelWidget].
  const LeftPanelWidgetFamily();

  /// Widget provider for the left sidebar surface.
  ///
  /// The host reads the aggregate per-cassette resolution state for the current
  /// rack and renders only when the visible rack is complete. Per-cassette
  /// providers preserve previously resolved values during same-rack reloads,
  /// while structural rack changes still blank until the new rack is fully
  /// resolved.
  ///
  /// Errors are logged but do not currently surface user-visible recovery UI.
  ///
  /// Copied from [leftPanelWidget].
  LeftPanelWidgetProvider call(SidebarMode mode) {
    return LeftPanelWidgetProvider(mode);
  }

  @override
  LeftPanelWidgetProvider getProviderOverride(
    covariant LeftPanelWidgetProvider provider,
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
  String? get name => r'leftPanelWidgetProvider';
}

/// Widget provider for the left sidebar surface.
///
/// The host reads the aggregate per-cassette resolution state for the current
/// rack and renders only when the visible rack is complete. Per-cassette
/// providers preserve previously resolved values during same-rack reloads,
/// while structural rack changes still blank until the new rack is fully
/// resolved.
///
/// Errors are logged but do not currently surface user-visible recovery UI.
///
/// Copied from [leftPanelWidget].
class LeftPanelWidgetProvider extends AutoDisposeProvider<Widget> {
  /// Widget provider for the left sidebar surface.
  ///
  /// The host reads the aggregate per-cassette resolution state for the current
  /// rack and renders only when the visible rack is complete. Per-cassette
  /// providers preserve previously resolved values during same-rack reloads,
  /// while structural rack changes still blank until the new rack is fully
  /// resolved.
  ///
  /// Errors are logged but do not currently surface user-visible recovery UI.
  ///
  /// Copied from [leftPanelWidget].
  LeftPanelWidgetProvider(SidebarMode mode)
    : this._internal(
        (ref) => leftPanelWidget(ref as LeftPanelWidgetRef, mode),
        from: leftPanelWidgetProvider,
        name: r'leftPanelWidgetProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$leftPanelWidgetHash,
        dependencies: LeftPanelWidgetFamily._dependencies,
        allTransitiveDependencies:
            LeftPanelWidgetFamily._allTransitiveDependencies,
        mode: mode,
      );

  LeftPanelWidgetProvider._internal(
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
  Override overrideWith(Widget Function(LeftPanelWidgetRef provider) create) {
    return ProviderOverride(
      origin: this,
      override: LeftPanelWidgetProvider._internal(
        (ref) => create(ref as LeftPanelWidgetRef),
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
  AutoDisposeProviderElement<Widget> createElement() {
    return _LeftPanelWidgetProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is LeftPanelWidgetProvider && other.mode == mode;
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
mixin LeftPanelWidgetRef on AutoDisposeProviderRef<Widget> {
  /// The parameter `mode` of this provider.
  SidebarMode get mode;
}

class _LeftPanelWidgetProviderElement extends AutoDisposeProviderElement<Widget>
    with LeftPanelWidgetRef {
  _LeftPanelWidgetProviderElement(super.provider);

  @override
  SidebarMode get mode => (origin as LeftPanelWidgetProvider).mode;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
