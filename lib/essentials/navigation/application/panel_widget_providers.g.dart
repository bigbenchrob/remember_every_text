// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'panel_widget_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$reconcileSidebarPanelsHash() =>
    r'dc296ad7386312e27191fb85f1f096157f79805e';

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

/// See also [reconcileSidebarPanels].
@ProviderFor(reconcileSidebarPanels)
const reconcileSidebarPanelsProvider = ReconcileSidebarPanelsFamily();

/// See also [reconcileSidebarPanels].
class ReconcileSidebarPanelsFamily extends Family<void> {
  /// See also [reconcileSidebarPanels].
  const ReconcileSidebarPanelsFamily();

  /// See also [reconcileSidebarPanels].
  ReconcileSidebarPanelsProvider call(SidebarMode mode) {
    return ReconcileSidebarPanelsProvider(mode);
  }

  @override
  ReconcileSidebarPanelsProvider getProviderOverride(
    covariant ReconcileSidebarPanelsProvider provider,
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
  String? get name => r'reconcileSidebarPanelsProvider';
}

/// See also [reconcileSidebarPanels].
class ReconcileSidebarPanelsProvider extends AutoDisposeProvider<void> {
  /// See also [reconcileSidebarPanels].
  ReconcileSidebarPanelsProvider(SidebarMode mode)
    : this._internal(
        (ref) => reconcileSidebarPanels(ref as ReconcileSidebarPanelsRef, mode),
        from: reconcileSidebarPanelsProvider,
        name: r'reconcileSidebarPanelsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$reconcileSidebarPanelsHash,
        dependencies: ReconcileSidebarPanelsFamily._dependencies,
        allTransitiveDependencies:
            ReconcileSidebarPanelsFamily._allTransitiveDependencies,
        mode: mode,
      );

  ReconcileSidebarPanelsProvider._internal(
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
    void Function(ReconcileSidebarPanelsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ReconcileSidebarPanelsProvider._internal(
        (ref) => create(ref as ReconcileSidebarPanelsRef),
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
  AutoDisposeProviderElement<void> createElement() {
    return _ReconcileSidebarPanelsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ReconcileSidebarPanelsProvider && other.mode == mode;
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
mixin ReconcileSidebarPanelsRef on AutoDisposeProviderRef<void> {
  /// The parameter `mode` of this provider.
  SidebarMode get mode;
}

class _ReconcileSidebarPanelsProviderElement
    extends AutoDisposeProviderElement<void>
    with ReconcileSidebarPanelsRef {
  _ReconcileSidebarPanelsProviderElement(super.provider);

  @override
  SidebarMode get mode => (origin as ReconcileSidebarPanelsProvider).mode;
}

String _$isSidebarParkedHash() => r'3e78e9ac13a4c1f0fc2151cde86b0a68f04f3516';

/// Whether the center panel is showing content that operates independently
/// of the sidebar (e.g. import/migration, workbench).
///
/// When true, the sidebar should display a contextual overlay with a
/// dismiss action rather than the cassette rack.
///
/// Copied from [isSidebarParked].
@ProviderFor(isSidebarParked)
const isSidebarParkedProvider = IsSidebarParkedFamily();

/// Whether the center panel is showing content that operates independently
/// of the sidebar (e.g. import/migration, workbench).
///
/// When true, the sidebar should display a contextual overlay with a
/// dismiss action rather than the cassette rack.
///
/// Copied from [isSidebarParked].
class IsSidebarParkedFamily extends Family<bool> {
  /// Whether the center panel is showing content that operates independently
  /// of the sidebar (e.g. import/migration, workbench).
  ///
  /// When true, the sidebar should display a contextual overlay with a
  /// dismiss action rather than the cassette rack.
  ///
  /// Copied from [isSidebarParked].
  const IsSidebarParkedFamily();

  /// Whether the center panel is showing content that operates independently
  /// of the sidebar (e.g. import/migration, workbench).
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
/// of the sidebar (e.g. import/migration, workbench).
///
/// When true, the sidebar should display a contextual overlay with a
/// dismiss action rather than the cassette rack.
///
/// Copied from [isSidebarParked].
class IsSidebarParkedProvider extends AutoDisposeProvider<bool> {
  /// Whether the center panel is showing content that operates independently
  /// of the sidebar (e.g. import/migration, workbench).
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

String _$centerPanelWidgetHash() => r'cc418e5ac3e6dfdf48fff5e47b7b80c95e8438bb';

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

String _$rightPanelWidgetHash() => r'5cbd207bc7cbd9c0d172adcf9b882a038118037b';

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
    r'd77dc4076f2b8fa4317db7e77d21527752921f40';

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
    r'cb05193bd9e58fcc04232065c54ed8e6f0de10c7';

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

String _$leftPanelWidgetHash() => r'06804b704050c8e571c92877f43b40b1051ca9db';

/// Widget provider for left panel (sidebar).
///
/// This provider builds the left panel by reading the current list of
/// cassette widgets from [CassetteWidgetCoordinator].  The resulting list
/// is wrapped in a [Column] so that the cassettes are laid out vertically.
///
/// ## Async Handling Strategy
///
/// The [CassetteWidgetCoordinator] returns `AsyncValue<List<Widget>>` because
/// feature-side spec coordinators may need to fetch data from repositories
/// (e.g., contact counts, derived values, async formatting).
///
/// We use a **stale-while-revalidate** pattern here:
///
/// 1. **Initial load**: Show a loading indicator until the first cassette list
///    resolves. This only happens once per sidebar mode on app startup or when
///    the mode changes.
///
/// 2. **Subsequent updates**: Keep displaying the previous cassette list while
///    the new list builds asynchronously. This prevents jarring full-sidebar
///    reloads when the user interacts with a cassette (e.g., toggles a setting,
///    selects a filter).
///
/// 3. **Errors**: Currently logged but not displayed. The previous valid state
///    is preserved. Future enhancement: consider a subtle error toast or badge.
///
/// ## Why `valueOrNull` instead of `when()`?
///
/// Using `asyncCassettes.valueOrNull` with explicit state checks gives us more
/// control than `AsyncValue.when()`:
///
/// - **Easier to add loading overlays**: We can later add a subtle progress
///   indicator (e.g., a thin bar at the top) without restructuring the code.
///
/// - **Partial update support**: If we ever want to show incremental cassette
///   updates (e.g., stream-based), this pattern accommodates that.
///
/// - **Cleaner error handling**: We can log errors and preserve the UI without
///   forcing an error widget into the layout.
///
/// - **No callback nesting**: The linear flow is easier to read and extend.
///
/// ## Future Extension Points
///
/// - **Loading indicator overlay**: Add a `Stack` with an `AnimatedOpacity`
///   progress bar that fades in during `isLoading && hasValue`.
///
/// - **Per-cassette loading**: If individual cassettes need independent async
///   states, consider returning `List<AsyncValue<Widget>>` from the coordinator
///   and handling loading per-slot.
///
/// - **Error recovery UI**: Add a "Retry" affordance or error badge that
///   appears when `hasError` is true but we're still showing stale data.
///
/// - **Optimistic updates**: For user-initiated changes (e.g., toggling a
///   setting), consider updating the UI optimistically before the async
///   operation completes.
///
/// Copied from [leftPanelWidget].
@ProviderFor(leftPanelWidget)
const leftPanelWidgetProvider = LeftPanelWidgetFamily();

/// Widget provider for left panel (sidebar).
///
/// This provider builds the left panel by reading the current list of
/// cassette widgets from [CassetteWidgetCoordinator].  The resulting list
/// is wrapped in a [Column] so that the cassettes are laid out vertically.
///
/// ## Async Handling Strategy
///
/// The [CassetteWidgetCoordinator] returns `AsyncValue<List<Widget>>` because
/// feature-side spec coordinators may need to fetch data from repositories
/// (e.g., contact counts, derived values, async formatting).
///
/// We use a **stale-while-revalidate** pattern here:
///
/// 1. **Initial load**: Show a loading indicator until the first cassette list
///    resolves. This only happens once per sidebar mode on app startup or when
///    the mode changes.
///
/// 2. **Subsequent updates**: Keep displaying the previous cassette list while
///    the new list builds asynchronously. This prevents jarring full-sidebar
///    reloads when the user interacts with a cassette (e.g., toggles a setting,
///    selects a filter).
///
/// 3. **Errors**: Currently logged but not displayed. The previous valid state
///    is preserved. Future enhancement: consider a subtle error toast or badge.
///
/// ## Why `valueOrNull` instead of `when()`?
///
/// Using `asyncCassettes.valueOrNull` with explicit state checks gives us more
/// control than `AsyncValue.when()`:
///
/// - **Easier to add loading overlays**: We can later add a subtle progress
///   indicator (e.g., a thin bar at the top) without restructuring the code.
///
/// - **Partial update support**: If we ever want to show incremental cassette
///   updates (e.g., stream-based), this pattern accommodates that.
///
/// - **Cleaner error handling**: We can log errors and preserve the UI without
///   forcing an error widget into the layout.
///
/// - **No callback nesting**: The linear flow is easier to read and extend.
///
/// ## Future Extension Points
///
/// - **Loading indicator overlay**: Add a `Stack` with an `AnimatedOpacity`
///   progress bar that fades in during `isLoading && hasValue`.
///
/// - **Per-cassette loading**: If individual cassettes need independent async
///   states, consider returning `List<AsyncValue<Widget>>` from the coordinator
///   and handling loading per-slot.
///
/// - **Error recovery UI**: Add a "Retry" affordance or error badge that
///   appears when `hasError` is true but we're still showing stale data.
///
/// - **Optimistic updates**: For user-initiated changes (e.g., toggling a
///   setting), consider updating the UI optimistically before the async
///   operation completes.
///
/// Copied from [leftPanelWidget].
class LeftPanelWidgetFamily extends Family<Widget> {
  /// Widget provider for left panel (sidebar).
  ///
  /// This provider builds the left panel by reading the current list of
  /// cassette widgets from [CassetteWidgetCoordinator].  The resulting list
  /// is wrapped in a [Column] so that the cassettes are laid out vertically.
  ///
  /// ## Async Handling Strategy
  ///
  /// The [CassetteWidgetCoordinator] returns `AsyncValue<List<Widget>>` because
  /// feature-side spec coordinators may need to fetch data from repositories
  /// (e.g., contact counts, derived values, async formatting).
  ///
  /// We use a **stale-while-revalidate** pattern here:
  ///
  /// 1. **Initial load**: Show a loading indicator until the first cassette list
  ///    resolves. This only happens once per sidebar mode on app startup or when
  ///    the mode changes.
  ///
  /// 2. **Subsequent updates**: Keep displaying the previous cassette list while
  ///    the new list builds asynchronously. This prevents jarring full-sidebar
  ///    reloads when the user interacts with a cassette (e.g., toggles a setting,
  ///    selects a filter).
  ///
  /// 3. **Errors**: Currently logged but not displayed. The previous valid state
  ///    is preserved. Future enhancement: consider a subtle error toast or badge.
  ///
  /// ## Why `valueOrNull` instead of `when()`?
  ///
  /// Using `asyncCassettes.valueOrNull` with explicit state checks gives us more
  /// control than `AsyncValue.when()`:
  ///
  /// - **Easier to add loading overlays**: We can later add a subtle progress
  ///   indicator (e.g., a thin bar at the top) without restructuring the code.
  ///
  /// - **Partial update support**: If we ever want to show incremental cassette
  ///   updates (e.g., stream-based), this pattern accommodates that.
  ///
  /// - **Cleaner error handling**: We can log errors and preserve the UI without
  ///   forcing an error widget into the layout.
  ///
  /// - **No callback nesting**: The linear flow is easier to read and extend.
  ///
  /// ## Future Extension Points
  ///
  /// - **Loading indicator overlay**: Add a `Stack` with an `AnimatedOpacity`
  ///   progress bar that fades in during `isLoading && hasValue`.
  ///
  /// - **Per-cassette loading**: If individual cassettes need independent async
  ///   states, consider returning `List<AsyncValue<Widget>>` from the coordinator
  ///   and handling loading per-slot.
  ///
  /// - **Error recovery UI**: Add a "Retry" affordance or error badge that
  ///   appears when `hasError` is true but we're still showing stale data.
  ///
  /// - **Optimistic updates**: For user-initiated changes (e.g., toggling a
  ///   setting), consider updating the UI optimistically before the async
  ///   operation completes.
  ///
  /// Copied from [leftPanelWidget].
  const LeftPanelWidgetFamily();

  /// Widget provider for left panel (sidebar).
  ///
  /// This provider builds the left panel by reading the current list of
  /// cassette widgets from [CassetteWidgetCoordinator].  The resulting list
  /// is wrapped in a [Column] so that the cassettes are laid out vertically.
  ///
  /// ## Async Handling Strategy
  ///
  /// The [CassetteWidgetCoordinator] returns `AsyncValue<List<Widget>>` because
  /// feature-side spec coordinators may need to fetch data from repositories
  /// (e.g., contact counts, derived values, async formatting).
  ///
  /// We use a **stale-while-revalidate** pattern here:
  ///
  /// 1. **Initial load**: Show a loading indicator until the first cassette list
  ///    resolves. This only happens once per sidebar mode on app startup or when
  ///    the mode changes.
  ///
  /// 2. **Subsequent updates**: Keep displaying the previous cassette list while
  ///    the new list builds asynchronously. This prevents jarring full-sidebar
  ///    reloads when the user interacts with a cassette (e.g., toggles a setting,
  ///    selects a filter).
  ///
  /// 3. **Errors**: Currently logged but not displayed. The previous valid state
  ///    is preserved. Future enhancement: consider a subtle error toast or badge.
  ///
  /// ## Why `valueOrNull` instead of `when()`?
  ///
  /// Using `asyncCassettes.valueOrNull` with explicit state checks gives us more
  /// control than `AsyncValue.when()`:
  ///
  /// - **Easier to add loading overlays**: We can later add a subtle progress
  ///   indicator (e.g., a thin bar at the top) without restructuring the code.
  ///
  /// - **Partial update support**: If we ever want to show incremental cassette
  ///   updates (e.g., stream-based), this pattern accommodates that.
  ///
  /// - **Cleaner error handling**: We can log errors and preserve the UI without
  ///   forcing an error widget into the layout.
  ///
  /// - **No callback nesting**: The linear flow is easier to read and extend.
  ///
  /// ## Future Extension Points
  ///
  /// - **Loading indicator overlay**: Add a `Stack` with an `AnimatedOpacity`
  ///   progress bar that fades in during `isLoading && hasValue`.
  ///
  /// - **Per-cassette loading**: If individual cassettes need independent async
  ///   states, consider returning `List<AsyncValue<Widget>>` from the coordinator
  ///   and handling loading per-slot.
  ///
  /// - **Error recovery UI**: Add a "Retry" affordance or error badge that
  ///   appears when `hasError` is true but we're still showing stale data.
  ///
  /// - **Optimistic updates**: For user-initiated changes (e.g., toggling a
  ///   setting), consider updating the UI optimistically before the async
  ///   operation completes.
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

/// Widget provider for left panel (sidebar).
///
/// This provider builds the left panel by reading the current list of
/// cassette widgets from [CassetteWidgetCoordinator].  The resulting list
/// is wrapped in a [Column] so that the cassettes are laid out vertically.
///
/// ## Async Handling Strategy
///
/// The [CassetteWidgetCoordinator] returns `AsyncValue<List<Widget>>` because
/// feature-side spec coordinators may need to fetch data from repositories
/// (e.g., contact counts, derived values, async formatting).
///
/// We use a **stale-while-revalidate** pattern here:
///
/// 1. **Initial load**: Show a loading indicator until the first cassette list
///    resolves. This only happens once per sidebar mode on app startup or when
///    the mode changes.
///
/// 2. **Subsequent updates**: Keep displaying the previous cassette list while
///    the new list builds asynchronously. This prevents jarring full-sidebar
///    reloads when the user interacts with a cassette (e.g., toggles a setting,
///    selects a filter).
///
/// 3. **Errors**: Currently logged but not displayed. The previous valid state
///    is preserved. Future enhancement: consider a subtle error toast or badge.
///
/// ## Why `valueOrNull` instead of `when()`?
///
/// Using `asyncCassettes.valueOrNull` with explicit state checks gives us more
/// control than `AsyncValue.when()`:
///
/// - **Easier to add loading overlays**: We can later add a subtle progress
///   indicator (e.g., a thin bar at the top) without restructuring the code.
///
/// - **Partial update support**: If we ever want to show incremental cassette
///   updates (e.g., stream-based), this pattern accommodates that.
///
/// - **Cleaner error handling**: We can log errors and preserve the UI without
///   forcing an error widget into the layout.
///
/// - **No callback nesting**: The linear flow is easier to read and extend.
///
/// ## Future Extension Points
///
/// - **Loading indicator overlay**: Add a `Stack` with an `AnimatedOpacity`
///   progress bar that fades in during `isLoading && hasValue`.
///
/// - **Per-cassette loading**: If individual cassettes need independent async
///   states, consider returning `List<AsyncValue<Widget>>` from the coordinator
///   and handling loading per-slot.
///
/// - **Error recovery UI**: Add a "Retry" affordance or error badge that
///   appears when `hasError` is true but we're still showing stale data.
///
/// - **Optimistic updates**: For user-initiated changes (e.g., toggling a
///   setting), consider updating the UI optimistically before the async
///   operation completes.
///
/// Copied from [leftPanelWidget].
class LeftPanelWidgetProvider extends AutoDisposeProvider<Widget> {
  /// Widget provider for left panel (sidebar).
  ///
  /// This provider builds the left panel by reading the current list of
  /// cassette widgets from [CassetteWidgetCoordinator].  The resulting list
  /// is wrapped in a [Column] so that the cassettes are laid out vertically.
  ///
  /// ## Async Handling Strategy
  ///
  /// The [CassetteWidgetCoordinator] returns `AsyncValue<List<Widget>>` because
  /// feature-side spec coordinators may need to fetch data from repositories
  /// (e.g., contact counts, derived values, async formatting).
  ///
  /// We use a **stale-while-revalidate** pattern here:
  ///
  /// 1. **Initial load**: Show a loading indicator until the first cassette list
  ///    resolves. This only happens once per sidebar mode on app startup or when
  ///    the mode changes.
  ///
  /// 2. **Subsequent updates**: Keep displaying the previous cassette list while
  ///    the new list builds asynchronously. This prevents jarring full-sidebar
  ///    reloads when the user interacts with a cassette (e.g., toggles a setting,
  ///    selects a filter).
  ///
  /// 3. **Errors**: Currently logged but not displayed. The previous valid state
  ///    is preserved. Future enhancement: consider a subtle error toast or badge.
  ///
  /// ## Why `valueOrNull` instead of `when()`?
  ///
  /// Using `asyncCassettes.valueOrNull` with explicit state checks gives us more
  /// control than `AsyncValue.when()`:
  ///
  /// - **Easier to add loading overlays**: We can later add a subtle progress
  ///   indicator (e.g., a thin bar at the top) without restructuring the code.
  ///
  /// - **Partial update support**: If we ever want to show incremental cassette
  ///   updates (e.g., stream-based), this pattern accommodates that.
  ///
  /// - **Cleaner error handling**: We can log errors and preserve the UI without
  ///   forcing an error widget into the layout.
  ///
  /// - **No callback nesting**: The linear flow is easier to read and extend.
  ///
  /// ## Future Extension Points
  ///
  /// - **Loading indicator overlay**: Add a `Stack` with an `AnimatedOpacity`
  ///   progress bar that fades in during `isLoading && hasValue`.
  ///
  /// - **Per-cassette loading**: If individual cassettes need independent async
  ///   states, consider returning `List<AsyncValue<Widget>>` from the coordinator
  ///   and handling loading per-slot.
  ///
  /// - **Error recovery UI**: Add a "Retry" affordance or error badge that
  ///   appears when `hasError` is true but we're still showing stale data.
  ///
  /// - **Optimistic updates**: For user-initiated changes (e.g., toggling a
  ///   setting), consider updating the UI optimistically before the async
  ///   operation completes.
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
