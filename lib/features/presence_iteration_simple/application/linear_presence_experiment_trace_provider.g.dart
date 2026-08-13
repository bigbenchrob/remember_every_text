// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'linear_presence_experiment_trace_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$linearPresenceExperimentTraceHash() =>
    r'bd5e3a1022da34463a433a5fea8c6e264b845190';

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

abstract class _$LinearPresenceExperimentTrace
    extends BuildlessAutoDisposeAsyncNotifier<List<ExecutionTraceEvent>> {
  late final int scheduleRunId;

  FutureOr<List<ExecutionTraceEvent>> build(int scheduleRunId);
}

/// See also [LinearPresenceExperimentTrace].
@ProviderFor(LinearPresenceExperimentTrace)
const linearPresenceExperimentTraceProvider =
    LinearPresenceExperimentTraceFamily();

/// See also [LinearPresenceExperimentTrace].
class LinearPresenceExperimentTraceFamily
    extends Family<AsyncValue<List<ExecutionTraceEvent>>> {
  /// See also [LinearPresenceExperimentTrace].
  const LinearPresenceExperimentTraceFamily();

  /// See also [LinearPresenceExperimentTrace].
  LinearPresenceExperimentTraceProvider call(int scheduleRunId) {
    return LinearPresenceExperimentTraceProvider(scheduleRunId);
  }

  @override
  LinearPresenceExperimentTraceProvider getProviderOverride(
    covariant LinearPresenceExperimentTraceProvider provider,
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
  String? get name => r'linearPresenceExperimentTraceProvider';
}

/// See also [LinearPresenceExperimentTrace].
class LinearPresenceExperimentTraceProvider
    extends
        AutoDisposeAsyncNotifierProviderImpl<
          LinearPresenceExperimentTrace,
          List<ExecutionTraceEvent>
        > {
  /// See also [LinearPresenceExperimentTrace].
  LinearPresenceExperimentTraceProvider(int scheduleRunId)
    : this._internal(
        () => LinearPresenceExperimentTrace()..scheduleRunId = scheduleRunId,
        from: linearPresenceExperimentTraceProvider,
        name: r'linearPresenceExperimentTraceProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$linearPresenceExperimentTraceHash,
        dependencies: LinearPresenceExperimentTraceFamily._dependencies,
        allTransitiveDependencies:
            LinearPresenceExperimentTraceFamily._allTransitiveDependencies,
        scheduleRunId: scheduleRunId,
      );

  LinearPresenceExperimentTraceProvider._internal(
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
  FutureOr<List<ExecutionTraceEvent>> runNotifierBuild(
    covariant LinearPresenceExperimentTrace notifier,
  ) {
    return notifier.build(scheduleRunId);
  }

  @override
  Override overrideWith(LinearPresenceExperimentTrace Function() create) {
    return ProviderOverride(
      origin: this,
      override: LinearPresenceExperimentTraceProvider._internal(
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
    LinearPresenceExperimentTrace,
    List<ExecutionTraceEvent>
  >
  createElement() {
    return _LinearPresenceExperimentTraceProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is LinearPresenceExperimentTraceProvider &&
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
mixin LinearPresenceExperimentTraceRef
    on AutoDisposeAsyncNotifierProviderRef<List<ExecutionTraceEvent>> {
  /// The parameter `scheduleRunId` of this provider.
  int get scheduleRunId;
}

class _LinearPresenceExperimentTraceProviderElement
    extends
        AutoDisposeAsyncNotifierProviderElement<
          LinearPresenceExperimentTrace,
          List<ExecutionTraceEvent>
        >
    with LinearPresenceExperimentTraceRef {
  _LinearPresenceExperimentTraceProviderElement(super.provider);

  @override
  int get scheduleRunId =>
      (origin as LinearPresenceExperimentTraceProvider).scheduleRunId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
