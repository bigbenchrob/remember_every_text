// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'current_visible_month_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$currentVisibleMonthForScopeHash() =>
    r'626005d7e26b44821bf00a1e74095b5df03f55dc';

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

abstract class _$CurrentVisibleMonthForScope
    extends BuildlessAutoDisposeAsyncNotifier<String?> {
  late final MessageTimelineScope scope;

  FutureOr<String?> build({required MessageTimelineScope scope});
}

/// Provides the currently visible month key for a given timeline scope.
///
/// The month key is in 'yyyy-MM' format (e.g., '2023-06').
/// This is used by the heatmap widget to highlight the current scroll position.
///
/// Returns null if the ordinal state is not yet loaded.
///
/// Copied from [CurrentVisibleMonthForScope].
@ProviderFor(CurrentVisibleMonthForScope)
const currentVisibleMonthForScopeProvider = CurrentVisibleMonthForScopeFamily();

/// Provides the currently visible month key for a given timeline scope.
///
/// The month key is in 'yyyy-MM' format (e.g., '2023-06').
/// This is used by the heatmap widget to highlight the current scroll position.
///
/// Returns null if the ordinal state is not yet loaded.
///
/// Copied from [CurrentVisibleMonthForScope].
class CurrentVisibleMonthForScopeFamily extends Family<AsyncValue<String?>> {
  /// Provides the currently visible month key for a given timeline scope.
  ///
  /// The month key is in 'yyyy-MM' format (e.g., '2023-06').
  /// This is used by the heatmap widget to highlight the current scroll position.
  ///
  /// Returns null if the ordinal state is not yet loaded.
  ///
  /// Copied from [CurrentVisibleMonthForScope].
  const CurrentVisibleMonthForScopeFamily();

  /// Provides the currently visible month key for a given timeline scope.
  ///
  /// The month key is in 'yyyy-MM' format (e.g., '2023-06').
  /// This is used by the heatmap widget to highlight the current scroll position.
  ///
  /// Returns null if the ordinal state is not yet loaded.
  ///
  /// Copied from [CurrentVisibleMonthForScope].
  CurrentVisibleMonthForScopeProvider call({
    required MessageTimelineScope scope,
  }) {
    return CurrentVisibleMonthForScopeProvider(scope: scope);
  }

  @override
  CurrentVisibleMonthForScopeProvider getProviderOverride(
    covariant CurrentVisibleMonthForScopeProvider provider,
  ) {
    return call(scope: provider.scope);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'currentVisibleMonthForScopeProvider';
}

/// Provides the currently visible month key for a given timeline scope.
///
/// The month key is in 'yyyy-MM' format (e.g., '2023-06').
/// This is used by the heatmap widget to highlight the current scroll position.
///
/// Returns null if the ordinal state is not yet loaded.
///
/// Copied from [CurrentVisibleMonthForScope].
class CurrentVisibleMonthForScopeProvider
    extends
        AutoDisposeAsyncNotifierProviderImpl<
          CurrentVisibleMonthForScope,
          String?
        > {
  /// Provides the currently visible month key for a given timeline scope.
  ///
  /// The month key is in 'yyyy-MM' format (e.g., '2023-06').
  /// This is used by the heatmap widget to highlight the current scroll position.
  ///
  /// Returns null if the ordinal state is not yet loaded.
  ///
  /// Copied from [CurrentVisibleMonthForScope].
  CurrentVisibleMonthForScopeProvider({required MessageTimelineScope scope})
    : this._internal(
        () => CurrentVisibleMonthForScope()..scope = scope,
        from: currentVisibleMonthForScopeProvider,
        name: r'currentVisibleMonthForScopeProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$currentVisibleMonthForScopeHash,
        dependencies: CurrentVisibleMonthForScopeFamily._dependencies,
        allTransitiveDependencies:
            CurrentVisibleMonthForScopeFamily._allTransitiveDependencies,
        scope: scope,
      );

  CurrentVisibleMonthForScopeProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.scope,
  }) : super.internal();

  final MessageTimelineScope scope;

  @override
  FutureOr<String?> runNotifierBuild(
    covariant CurrentVisibleMonthForScope notifier,
  ) {
    return notifier.build(scope: scope);
  }

  @override
  Override overrideWith(CurrentVisibleMonthForScope Function() create) {
    return ProviderOverride(
      origin: this,
      override: CurrentVisibleMonthForScopeProvider._internal(
        () => create()..scope = scope,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        scope: scope,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<CurrentVisibleMonthForScope, String?>
  createElement() {
    return _CurrentVisibleMonthForScopeProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CurrentVisibleMonthForScopeProvider && other.scope == scope;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, scope.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin CurrentVisibleMonthForScopeRef
    on AutoDisposeAsyncNotifierProviderRef<String?> {
  /// The parameter `scope` of this provider.
  MessageTimelineScope get scope;
}

class _CurrentVisibleMonthForScopeProviderElement
    extends
        AutoDisposeAsyncNotifierProviderElement<
          CurrentVisibleMonthForScope,
          String?
        >
    with CurrentVisibleMonthForScopeRef {
  _CurrentVisibleMonthForScopeProviderElement(super.provider);

  @override
  MessageTimelineScope get scope =>
      (origin as CurrentVisibleMonthForScopeProvider).scope;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
