// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'linear_presence_experiment_visualization_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$linearPresenceExperimentVisualizationHash() =>
    r'aef58be090a1872c44bfa658c3c57f1e5eaab84a';

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

abstract class _$LinearPresenceExperimentVisualization
    extends BuildlessAutoDisposeAsyncNotifier<PresenceRunVisualization> {
  late final int scheduleRunId;

  FutureOr<PresenceRunVisualization> build(int scheduleRunId);
}

/// See also [LinearPresenceExperimentVisualization].
@ProviderFor(LinearPresenceExperimentVisualization)
const linearPresenceExperimentVisualizationProvider =
    LinearPresenceExperimentVisualizationFamily();

/// See also [LinearPresenceExperimentVisualization].
class LinearPresenceExperimentVisualizationFamily
    extends Family<AsyncValue<PresenceRunVisualization>> {
  /// See also [LinearPresenceExperimentVisualization].
  const LinearPresenceExperimentVisualizationFamily();

  /// See also [LinearPresenceExperimentVisualization].
  LinearPresenceExperimentVisualizationProvider call(int scheduleRunId) {
    return LinearPresenceExperimentVisualizationProvider(scheduleRunId);
  }

  @override
  LinearPresenceExperimentVisualizationProvider getProviderOverride(
    covariant LinearPresenceExperimentVisualizationProvider provider,
  ) {
    return call(provider.scheduleRunId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'linearPresenceExperimentVisualizationProvider';
}

/// See also [LinearPresenceExperimentVisualization].
class LinearPresenceExperimentVisualizationProvider
    extends
        AutoDisposeAsyncNotifierProviderImpl<
          LinearPresenceExperimentVisualization,
          PresenceRunVisualization
        > {
  /// See also [LinearPresenceExperimentVisualization].
  LinearPresenceExperimentVisualizationProvider(int scheduleRunId)
    : this._internal(
        () =>
            LinearPresenceExperimentVisualization()
              ..scheduleRunId = scheduleRunId,
        from: linearPresenceExperimentVisualizationProvider,
        name: r'linearPresenceExperimentVisualizationProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$linearPresenceExperimentVisualizationHash,
        dependencies: LinearPresenceExperimentVisualizationFamily._dependencies,
        allTransitiveDependencies: LinearPresenceExperimentVisualizationFamily
            ._allTransitiveDependencies,
        scheduleRunId: scheduleRunId,
      );

  LinearPresenceExperimentVisualizationProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.scheduleRunId,
  }) : super.internal();

  final int scheduleRunId;

  @override
  FutureOr<PresenceRunVisualization> runNotifierBuild(
    covariant LinearPresenceExperimentVisualization notifier,
  ) {
    return notifier.build(scheduleRunId);
  }

  @override
  Override overrideWith(
    LinearPresenceExperimentVisualization Function() create,
  ) {
    return ProviderOverride(
      origin: this,
      override: LinearPresenceExperimentVisualizationProvider._internal(
        () => create()..scheduleRunId = scheduleRunId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        scheduleRunId: scheduleRunId,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<
    LinearPresenceExperimentVisualization,
    PresenceRunVisualization
  >
  createElement() {
    return _LinearPresenceExperimentVisualizationProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is LinearPresenceExperimentVisualizationProvider &&
        other.scheduleRunId == scheduleRunId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, scheduleRunId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin LinearPresenceExperimentVisualizationRef
    on AutoDisposeAsyncNotifierProviderRef<PresenceRunVisualization> {
  /// The parameter `scheduleRunId` of this provider.
  int get scheduleRunId;
}

class _LinearPresenceExperimentVisualizationProviderElement
    extends
        AutoDisposeAsyncNotifierProviderElement<
          LinearPresenceExperimentVisualization,
          PresenceRunVisualization
        >
    with LinearPresenceExperimentVisualizationRef {
  _LinearPresenceExperimentVisualizationProviderElement(super.provider);

  @override
  int get scheduleRunId =>
      (origin as LinearPresenceExperimentVisualizationProvider).scheduleRunId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
