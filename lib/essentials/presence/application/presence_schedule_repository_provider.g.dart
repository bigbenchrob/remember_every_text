// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'presence_schedule_repository_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$presenceScheduleRepositoryHash() =>
    r'b0684cc59259ba480c87953432681037090cda85';

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

/// See also [presenceScheduleRepository].
@ProviderFor(presenceScheduleRepository)
const presenceScheduleRepositoryProvider = PresenceScheduleRepositoryFamily();

/// See also [presenceScheduleRepository].
class PresenceScheduleRepositoryFamily
    extends Family<AsyncValue<PresenceScheduleRepository>> {
  /// See also [presenceScheduleRepository].
  const PresenceScheduleRepositoryFamily();

  /// See also [presenceScheduleRepository].
  PresenceScheduleRepositoryProvider call(
    TestAgentResolver testAgentResolver,
    FdaSettingsOpeningAuthority fdaSettingsOpeningAuthority,
  ) {
    return PresenceScheduleRepositoryProvider(
      testAgentResolver,
      fdaSettingsOpeningAuthority,
    );
  }

  @override
  PresenceScheduleRepositoryProvider getProviderOverride(
    covariant PresenceScheduleRepositoryProvider provider,
  ) {
    return call(
      provider.testAgentResolver,
      provider.fdaSettingsOpeningAuthority,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'presenceScheduleRepositoryProvider';
}

/// See also [presenceScheduleRepository].
class PresenceScheduleRepositoryProvider
    extends FutureProvider<PresenceScheduleRepository> {
  /// See also [presenceScheduleRepository].
  PresenceScheduleRepositoryProvider(
    TestAgentResolver testAgentResolver,
    FdaSettingsOpeningAuthority fdaSettingsOpeningAuthority,
  ) : this._internal(
        (ref) => presenceScheduleRepository(
          ref as PresenceScheduleRepositoryRef,
          testAgentResolver,
          fdaSettingsOpeningAuthority,
        ),
        from: presenceScheduleRepositoryProvider,
        name: r'presenceScheduleRepositoryProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$presenceScheduleRepositoryHash,
        dependencies: PresenceScheduleRepositoryFamily._dependencies,
        allTransitiveDependencies:
            PresenceScheduleRepositoryFamily._allTransitiveDependencies,
        testAgentResolver: testAgentResolver,
        fdaSettingsOpeningAuthority: fdaSettingsOpeningAuthority,
      );

  PresenceScheduleRepositoryProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.testAgentResolver,
    required this.fdaSettingsOpeningAuthority,
  }) : super.internal();

  final TestAgentResolver testAgentResolver;
  final FdaSettingsOpeningAuthority fdaSettingsOpeningAuthority;

  @override
  Override overrideWith(
    FutureOr<PresenceScheduleRepository> Function(
      PresenceScheduleRepositoryRef provider,
    )
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: PresenceScheduleRepositoryProvider._internal(
        (ref) => create(ref as PresenceScheduleRepositoryRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        testAgentResolver: testAgentResolver,
        fdaSettingsOpeningAuthority: fdaSettingsOpeningAuthority,
      ),
    );
  }

  @override
  FutureProviderElement<PresenceScheduleRepository> createElement() {
    return _PresenceScheduleRepositoryProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PresenceScheduleRepositoryProvider &&
        other.testAgentResolver == testAgentResolver &&
        other.fdaSettingsOpeningAuthority == fdaSettingsOpeningAuthority;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, testAgentResolver.hashCode);
    hash = _SystemHash.combine(hash, fdaSettingsOpeningAuthority.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin PresenceScheduleRepositoryRef
    on FutureProviderRef<PresenceScheduleRepository> {
  /// The parameter `testAgentResolver` of this provider.
  TestAgentResolver get testAgentResolver;

  /// The parameter `fdaSettingsOpeningAuthority` of this provider.
  FdaSettingsOpeningAuthority get fdaSettingsOpeningAuthority;
}

class _PresenceScheduleRepositoryProviderElement
    extends FutureProviderElement<PresenceScheduleRepository>
    with PresenceScheduleRepositoryRef {
  _PresenceScheduleRepositoryProviderElement(super.provider);

  @override
  TestAgentResolver get testAgentResolver =>
      (origin as PresenceScheduleRepositoryProvider).testAgentResolver;
  @override
  FdaSettingsOpeningAuthority get fdaSettingsOpeningAuthority =>
      (origin as PresenceScheduleRepositoryProvider)
          .fdaSettingsOpeningAuthority;
}

String _$presenceScheduleMaintenanceRepositoryHash() =>
    r'badf367c25552ea1732557ed30cc6a830cee6ad5';

/// Repository composition for archive-owned maintenance of Schedule runs.
///
/// Copied from [presenceScheduleMaintenanceRepository].
@ProviderFor(presenceScheduleMaintenanceRepository)
final presenceScheduleMaintenanceRepositoryProvider =
    FutureProvider<PresenceScheduleRunMaintenance>.internal(
      presenceScheduleMaintenanceRepository,
      name: r'presenceScheduleMaintenanceRepositoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$presenceScheduleMaintenanceRepositoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PresenceScheduleMaintenanceRepositoryRef =
    FutureProviderRef<PresenceScheduleRunMaintenance>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
